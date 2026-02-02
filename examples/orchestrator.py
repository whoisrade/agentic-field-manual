"""
Production Multi-Agent Orchestrator
====================================

A supervisor-based orchestrator for multi-agent systems. This is the pattern
used in production agentic applications - not the "let agents figure it out"
approach that breaks in prod.

Architecture:
    User Request -> Supervisor -> [Specialist Agents] -> Supervisor -> Response

Key design decisions:
    1. Supervisor owns the plan (agents don't self-direct)
    2. State is centralized (agents read/write to shared store)
    3. Checkpoints after each step (resumable on failure)
    4. Circuit breakers per agent (prevent cascade failures)
    5. Cost tracking at orchestration layer (global budget enforcement)

This is NOT:
    - A framework to import (adapt to your stack)
    - Production-ready code (missing auth, proper logging, etc.)
    - The only way to do it (but it's battle-tested)

Usage:
    orchestrator = Orchestrator(agents, state_store, config)
    result = await orchestrator.execute(task, context)
"""

from __future__ import annotations

import asyncio
import time
import uuid
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable, Optional

# =============================================================================
# Core Types
# =============================================================================


class TaskStatus(Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class StepStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    SKIPPED = "skipped"


@dataclass
class ExecutionContext:
    """Context that flows through the entire execution."""

    trace_id: str
    tenant_id: str
    user_id: str
    session_id: str

    # Budget tracking
    cost_budget: float = 10.0  # USD
    cost_spent: float = 0.0
    token_budget: int = 100_000
    tokens_used: int = 0

    # Timing
    start_time: float = field(default_factory=time.time)
    timeout_seconds: float = 300.0  # 5 minutes max

    # Metadata
    metadata: dict = field(default_factory=dict)

    @property
    def budget_remaining(self) -> float:
        return self.cost_budget - self.cost_spent

    @property
    def time_remaining(self) -> float:
        return self.timeout_seconds - (time.time() - self.start_time)

    @property
    def is_timed_out(self) -> bool:
        return self.time_remaining <= 0

    @property
    def is_over_budget(self) -> bool:
        return self.cost_spent >= self.cost_budget


@dataclass
class Step:
    """A single step in the execution plan."""

    id: str
    agent_name: str
    action: str
    inputs: dict
    status: StepStatus = StepStatus.PENDING
    result: Optional[dict] = None
    error: Optional[str] = None
    cost: float = 0.0
    latency_ms: float = 0.0
    retries: int = 0


@dataclass
class Plan:
    """The execution plan created by the supervisor."""

    id: str
    task_description: str
    steps: list[Step]
    status: TaskStatus = TaskStatus.PENDING
    current_step_index: int = 0

    @property
    def current_step(self) -> Optional[Step]:
        if self.current_step_index < len(self.steps):
            return self.steps[self.current_step_index]
        return None

    @property
    def completed_steps(self) -> list[Step]:
        return [s for s in self.steps if s.status == StepStatus.COMPLETED]

    @property
    def is_complete(self) -> bool:
        return all(s.status in (StepStatus.COMPLETED, StepStatus.SKIPPED) for s in self.steps)


@dataclass
class AgentResult:
    """Result from an agent execution."""

    success: bool
    output: dict
    cost: float = 0.0
    tokens_used: int = 0
    latency_ms: float = 0.0
    error: Optional[str] = None


# =============================================================================
# State Store Interface
# =============================================================================


class StateStore(ABC):
    """
    Centralized state store for the orchestrator.

    All agents read from and write to this store.
    This is the single source of truth.
    """

    @abstractmethod
    async def get(self, key: str) -> Optional[dict]:
        pass

    @abstractmethod
    async def set(self, key: str, value: dict, trace_id: str) -> None:
        pass

    @abstractmethod
    async def get_checkpoint(self, plan_id: str) -> Optional[int]:
        """Get the last completed step index for resumption."""
        pass

    @abstractmethod
    async def save_checkpoint(self, plan_id: str, step_index: int) -> None:
        """Save checkpoint after successful step."""
        pass


class InMemoryStateStore(StateStore):
    """Simple in-memory implementation for testing."""

    def __init__(self):
        self.data: dict[str, dict] = {}
        self.checkpoints: dict[str, int] = {}
        self.history: list[dict] = []

    async def get(self, key: str) -> Optional[dict]:
        return self.data.get(key)

    async def set(self, key: str, value: dict, trace_id: str) -> None:
        self.data[key] = value
        self.history.append({
            "trace_id": trace_id,
            "key": key,
            "value": value,
            "timestamp": time.time(),
        })

    async def get_checkpoint(self, plan_id: str) -> Optional[int]:
        return self.checkpoints.get(plan_id)

    async def save_checkpoint(self, plan_id: str, step_index: int) -> None:
        self.checkpoints[plan_id] = step_index


# =============================================================================
# Agent Interface
# =============================================================================


class Agent(ABC):
    """
    Base class for all agents.

    Agents are specialists that perform specific tasks.
    They don't self-direct - the supervisor tells them what to do.
    """

    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.enabled = True

    @abstractmethod
    async def execute(
        self,
        action: str,
        inputs: dict,
        state: StateStore,
        context: ExecutionContext,
    ) -> AgentResult:
        """Execute an action with given inputs."""
        pass

    @property
    @abstractmethod
    def capabilities(self) -> list[str]:
        """List of actions this agent can perform."""
        pass


# =============================================================================
# Circuit Breaker
# =============================================================================


@dataclass
class CircuitBreakerConfig:
    failure_threshold: int = 3  # Failures before opening
    reset_timeout_seconds: float = 60.0  # Time before half-open
    half_open_max_calls: int = 1  # Calls allowed in half-open


class CircuitBreaker:
    """
    Circuit breaker for agent reliability.

    States:
        CLOSED: Normal operation
        OPEN: Failing, reject calls immediately
        HALF_OPEN: Testing if agent recovered
    """

    def __init__(self, config: CircuitBreakerConfig):
        self.config = config
        self.failure_count = 0
        self.last_failure_time: Optional[float] = None
        self.state = "closed"
        self.half_open_calls = 0

    def record_success(self) -> None:
        self.failure_count = 0
        self.state = "closed"
        self.half_open_calls = 0

    def record_failure(self) -> None:
        self.failure_count += 1
        self.last_failure_time = time.time()

        if self.failure_count >= self.config.failure_threshold:
            self.state = "open"

    def should_allow(self) -> bool:
        if self.state == "closed":
            return True

        if self.state == "open":
            # Check if we should transition to half-open
            if self.last_failure_time is None:
                return False
            if time.time() - self.last_failure_time > self.config.reset_timeout_seconds:
                self.state = "half_open"
                self.half_open_calls = 0
                return True
            return False

        if self.state == "half_open":
            if self.half_open_calls < self.config.half_open_max_calls:
                self.half_open_calls += 1
                return True
            return False

        return False


# =============================================================================
# Supervisor
# =============================================================================


class Supervisor:
    """
    The supervisor creates and manages execution plans.

    This is where the "thinking" happens - but it's controlled thinking,
    not emergent agent behavior.
    """

    def __init__(self, planning_model: str = "gpt-4o"):
        self.planning_model = planning_model

    async def create_plan(
        self,
        task: str,
        available_agents: list[Agent],
        context: ExecutionContext,
        state: StateStore,
    ) -> Plan:
        """
        Create an execution plan for the task.

        In production, this calls an LLM to decompose the task.
        Here we show the interface and a simple implementation.
        """
        # Build agent capability map
        agent_capabilities = {
            agent.name: {
                "description": agent.description,
                "capabilities": agent.capabilities,
            }
            for agent in available_agents
        }

        # In production: call LLM to create plan
        # plan_response = await self._call_planner(task, agent_capabilities)

        # For demonstration: simple task decomposition
        steps = await self._decompose_task(task, agent_capabilities)

        return Plan(
            id=str(uuid.uuid4()),
            task_description=task,
            steps=steps,
        )

    async def _decompose_task(
        self, task: str, agent_capabilities: dict
    ) -> list[Step]:
        """
        Decompose task into steps.

        In production, this is an LLM call with structured output.
        """
        # Placeholder: return a simple plan
        # Real implementation calls planning LLM
        return [
            Step(
                id=str(uuid.uuid4()),
                agent_name="research",
                action="search",
                inputs={"query": task},
            ),
            Step(
                id=str(uuid.uuid4()),
                agent_name="synthesis",
                action="summarize",
                inputs={"context": "{{research.output}}"},
            ),
        ]

    async def validate_result(
        self,
        plan: Plan,
        context: ExecutionContext,
    ) -> tuple[bool, Optional[str]]:
        """
        Validate the execution result.

        Returns (is_valid, error_message)
        """
        # Check all steps completed
        if not plan.is_complete:
            failed_steps = [s for s in plan.steps if s.status == StepStatus.FAILED]
            return False, f"Steps failed: {[s.id for s in failed_steps]}"

        # In production: LLM validates output quality
        return True, None


# =============================================================================
# Orchestrator
# =============================================================================


@dataclass
class OrchestratorConfig:
    max_retries_per_step: int = 3
    retry_delay_seconds: float = 1.0
    circuit_breaker_config: CircuitBreakerConfig = field(
        default_factory=CircuitBreakerConfig
    )
    enable_checkpointing: bool = True


class Orchestrator:
    """
    The main orchestrator that coordinates everything.

    Responsibilities:
        1. Manage the supervisor (planning)
        2. Execute steps via agents
        3. Track state and checkpoints
        4. Enforce budgets and timeouts
        5. Handle failures gracefully
    """

    def __init__(
        self,
        agents: list[Agent],
        state_store: StateStore,
        config: OrchestratorConfig,
        supervisor: Optional[Supervisor] = None,
    ):
        self.agents = {agent.name: agent for agent in agents}
        self.state = state_store
        self.config = config
        self.supervisor = supervisor or Supervisor()

        # Circuit breakers per agent
        self.circuit_breakers: dict[str, CircuitBreaker] = {
            name: CircuitBreaker(config.circuit_breaker_config)
            for name in self.agents
        }

    async def execute(
        self,
        task: str,
        context: ExecutionContext,
    ) -> dict:
        """
        Execute a task end-to-end.

        Returns the final result or error information.
        """
        start_time = time.time()

        # 1. Create or resume plan
        plan = await self._get_or_create_plan(task, context)

        # 2. Execute steps
        try:
            await self._execute_plan(plan, context)
        except Exception as e:
            plan.status = TaskStatus.FAILED
            return {
                "success": False,
                "error": str(e),
                "plan_id": plan.id,
                "completed_steps": len(plan.completed_steps),
                "total_steps": len(plan.steps),
                "cost": context.cost_spent,
                "latency_ms": (time.time() - start_time) * 1000,
            }

        # 3. Validate result
        is_valid, error = await self.supervisor.validate_result(plan, context)

        if not is_valid:
            plan.status = TaskStatus.FAILED
            return {
                "success": False,
                "error": f"Validation failed: {error}",
                "plan_id": plan.id,
                "cost": context.cost_spent,
                "latency_ms": (time.time() - start_time) * 1000,
            }

        # 4. Collect results
        plan.status = TaskStatus.COMPLETED
        return {
            "success": True,
            "plan_id": plan.id,
            "results": {step.id: step.result for step in plan.steps},
            "cost": context.cost_spent,
            "tokens_used": context.tokens_used,
            "latency_ms": (time.time() - start_time) * 1000,
        }

    async def _get_or_create_plan(
        self, task: str, context: ExecutionContext
    ) -> Plan:
        """Get existing plan from checkpoint or create new one."""
        # Check for existing checkpoint
        # In production, you'd look up by task hash or session
        plan = await self.supervisor.create_plan(
            task,
            list(self.agents.values()),
            context,
            self.state,
        )

        # Check if we can resume from checkpoint
        if self.config.enable_checkpointing:
            checkpoint = await self.state.get_checkpoint(plan.id)
            if checkpoint is not None:
                plan.current_step_index = checkpoint + 1
                # Mark previous steps as completed
                for i in range(checkpoint + 1):
                    plan.steps[i].status = StepStatus.COMPLETED

        return plan

    async def _execute_plan(
        self, plan: Plan, context: ExecutionContext
    ) -> None:
        """Execute all steps in the plan."""
        plan.status = TaskStatus.IN_PROGRESS

        while plan.current_step is not None:
            # Budget check
            if context.is_over_budget:
                raise RuntimeError(
                    f"Cost budget exceeded: ${context.cost_spent:.2f} / ${context.cost_budget:.2f}"
                )

            # Timeout check
            if context.is_timed_out:
                raise RuntimeError(
                    f"Execution timeout: {context.timeout_seconds}s"
                )

            step = plan.current_step
            await self._execute_step(step, plan, context)

            # Checkpoint after successful step
            if step.status == StepStatus.COMPLETED and self.config.enable_checkpointing:
                await self.state.save_checkpoint(plan.id, plan.current_step_index)

            plan.current_step_index += 1

    async def _execute_step(
        self, step: Step, plan: Plan, context: ExecutionContext
    ) -> None:
        """Execute a single step with retries."""
        step.status = StepStatus.RUNNING

        agent = self.agents.get(step.agent_name)
        if agent is None:
            step.status = StepStatus.FAILED
            step.error = f"Agent not found: {step.agent_name}"
            raise RuntimeError(step.error)

        # Circuit breaker check
        circuit_breaker = self.circuit_breakers[step.agent_name]
        if not circuit_breaker.should_allow():
            step.status = StepStatus.FAILED
            step.error = f"Circuit breaker open for agent: {step.agent_name}"
            raise RuntimeError(step.error)

        # Resolve input references ({{step_id.output}})
        resolved_inputs = self._resolve_inputs(step.inputs, plan)

        # Execute with retries
        last_error: Optional[str] = None
        for attempt in range(self.config.max_retries_per_step):
            try:
                start = time.time()
                result = await agent.execute(
                    step.action,
                    resolved_inputs,
                    self.state,
                    context,
                )
                step.latency_ms = (time.time() - start) * 1000

                if result.success:
                    step.status = StepStatus.COMPLETED
                    step.result = result.output
                    step.cost = result.cost
                    context.cost_spent += result.cost
                    context.tokens_used += result.tokens_used
                    circuit_breaker.record_success()
                    return
                else:
                    last_error = result.error
                    step.retries += 1

            except Exception as e:
                last_error = str(e)
                step.retries += 1

            # Wait before retry
            if attempt < self.config.max_retries_per_step - 1:
                await asyncio.sleep(self.config.retry_delay_seconds)

        # All retries exhausted
        step.status = StepStatus.FAILED
        step.error = last_error
        circuit_breaker.record_failure()
        raise RuntimeError(f"Step {step.id} failed after {step.retries} retries: {last_error}")

    def _resolve_inputs(self, inputs: dict, plan: Plan) -> dict:
        """
        Resolve references like {{step_id.output}} to actual values.
        """
        resolved = {}
        for key, value in inputs.items():
            if isinstance(value, str) and "{{" in value:
                # Simple template resolution
                for step in plan.completed_steps:
                    placeholder = f"{{{{{step.agent_name}.output}}}}"
                    if placeholder in value and step.result:
                        value = str(step.result)
            resolved[key] = value
        return resolved


# =============================================================================
# Example Agents
# =============================================================================


class ResearchAgent(Agent):
    """Example agent that performs research."""

    def __init__(self):
        super().__init__(
            name="research",
            description="Searches for information and retrieves relevant context",
        )

    @property
    def capabilities(self) -> list[str]:
        return ["search", "retrieve", "fact_check"]

    async def execute(
        self,
        action: str,
        inputs: dict,
        state: StateStore,
        context: ExecutionContext,
    ) -> AgentResult:
        start = time.time()

        if action == "search":
            # In production: call search API, RAG system, etc.
            await asyncio.sleep(0.1)  # Simulate latency

            result = {
                "query": inputs.get("query"),
                "results": [
                    {"title": "Result 1", "snippet": "..."},
                    {"title": "Result 2", "snippet": "..."},
                ],
                "sources": ["source1.com", "source2.com"],
            }

            # Store in state for other agents
            await state.set(f"research:{context.trace_id}", result, context.trace_id)

            return AgentResult(
                success=True,
                output=result,
                cost=0.001,  # Example cost
                tokens_used=500,
                latency_ms=(time.time() - start) * 1000,
            )

        return AgentResult(
            success=False,
            output={},
            error=f"Unknown action: {action}",
        )


class SynthesisAgent(Agent):
    """Example agent that synthesizes information."""

    def __init__(self):
        super().__init__(
            name="synthesis",
            description="Synthesizes information into coherent responses",
        )

    @property
    def capabilities(self) -> list[str]:
        return ["summarize", "analyze", "format"]

    async def execute(
        self,
        action: str,
        inputs: dict,
        state: StateStore,
        context: ExecutionContext,
    ) -> AgentResult:
        start = time.time()

        if action == "summarize":
            # In production: call LLM to synthesize
            await asyncio.sleep(0.2)  # Simulate latency

            result = {
                "summary": "This is a synthesized summary based on the research.",
                "key_points": ["Point 1", "Point 2", "Point 3"],
                "confidence": 0.85,
            }

            return AgentResult(
                success=True,
                output=result,
                cost=0.01,  # Example cost
                tokens_used=1000,
                latency_ms=(time.time() - start) * 1000,
            )

        return AgentResult(
            success=False,
            output={},
            error=f"Unknown action: {action}",
        )


# =============================================================================
# Observability
# =============================================================================


@dataclass
class ExecutionMetrics:
    """Metrics from an orchestrator execution."""

    trace_id: str
    plan_id: str
    success: bool
    total_latency_ms: float
    total_cost: float
    total_tokens: int
    steps_completed: int
    steps_failed: int
    steps_retried: int

    # Per-agent breakdown
    agent_latencies: dict[str, float] = field(default_factory=dict)
    agent_costs: dict[str, float] = field(default_factory=dict)

    @classmethod
    def from_plan(cls, plan: Plan, context: ExecutionContext) -> "ExecutionMetrics":
        agent_latencies = {}
        agent_costs = {}
        steps_retried = 0

        for step in plan.steps:
            if step.agent_name not in agent_latencies:
                agent_latencies[step.agent_name] = 0
                agent_costs[step.agent_name] = 0

            agent_latencies[step.agent_name] += step.latency_ms
            agent_costs[step.agent_name] += step.cost

            if step.retries > 0:
                steps_retried += 1

        return cls(
            trace_id=context.trace_id,
            plan_id=plan.id,
            success=plan.status == TaskStatus.COMPLETED,
            total_latency_ms=sum(s.latency_ms for s in plan.steps),
            total_cost=context.cost_spent,
            total_tokens=context.tokens_used,
            steps_completed=len([s for s in plan.steps if s.status == StepStatus.COMPLETED]),
            steps_failed=len([s for s in plan.steps if s.status == StepStatus.FAILED]),
            steps_retried=steps_retried,
            agent_latencies=agent_latencies,
            agent_costs=agent_costs,
        )


# =============================================================================
# Usage Example
# =============================================================================


async def main():
    """Example usage of the orchestrator."""

    # Set up agents
    agents = [
        ResearchAgent(),
        SynthesisAgent(),
    ]

    # Set up state store
    state_store = InMemoryStateStore()

    # Configure orchestrator
    config = OrchestratorConfig(
        max_retries_per_step=3,
        retry_delay_seconds=0.5,
        enable_checkpointing=True,
    )

    # Create orchestrator
    orchestrator = Orchestrator(agents, state_store, config)

    # Create execution context
    context = ExecutionContext(
        trace_id=str(uuid.uuid4()),
        tenant_id="tenant_123",
        user_id="user_456",
        session_id="session_789",
        cost_budget=1.0,
        timeout_seconds=30.0,
    )

    # Execute a task
    print("=" * 60)
    print("Orchestrator Execution")
    print("=" * 60)

    task = "Research the latest developments in AI safety and summarize the key findings"

    result = await orchestrator.execute(task, context)

    print(f"\nResult: {'SUCCESS' if result['success'] else 'FAILED'}")
    print(f"Cost: ${result['cost']:.4f}")
    print(f"Latency: {result['latency_ms']:.2f}ms")

    if result["success"]:
        print(f"\nResults:")
        for step_id, step_result in result["results"].items():
            print(f"  {step_id}: {step_result}")


if __name__ == "__main__":
    asyncio.run(main())
