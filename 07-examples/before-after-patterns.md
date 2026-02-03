# Before/After Patterns

> [!TIP]
> **Read this when:** Reviewing code for traceability issues, or fixing failure modes.

| | |
|---|---|
| **Time** | 20 min read (copy and adapt patterns) |
| **Outcome** | Anti-pattern recognition, concrete fix implementations |
| **Related** | [Legibility Loss](../01-failure-modes/legibility-loss.md) ・ [State Model](../02-architecture/state-model.md) |

---

Common anti-patterns in agentic systems and their fixes. Copy the "After" code.

---

## 1. Missing Trigger Type

**Problem:** Cannot distinguish user-initiated requests from hidden recompute.

### Before

```python
async def generate(user_id: str, prompt: str) -> str:
    response = await llm.complete(prompt)
    await db.save(user_id=user_id, response=response)
    return response
```

### After

```python
from enum import Enum
from dataclasses import dataclass
import uuid

class TriggerType(Enum):
    USER_EXPLICIT = "user_explicit"
    UNDO = "undo"
    RETRY = "retry"
    AUTO_SAVE = "auto_save"
    SYSTEM = "system"

@dataclass
class GenerateRequest:
    user_id: str
    prompt: str
    trigger_type: TriggerType
    trace_id: str = None
    
    def __post_init__(self):
        if self.trace_id is None:
            self.trace_id = str(uuid.uuid4())

async def generate(request: GenerateRequest) -> str:
    response = await llm.complete(request.prompt)
    
    await db.save(
        trace_id=request.trace_id,
        user_id=request.user_id,
        trigger_type=request.trigger_type.value,
        response=response,
        timestamp=datetime.utcnow()
    )
    
    return response
```

**Why it matters:** Without trigger type, you cannot calculate hidden recompute ratio or debug cost spikes.

---

## 2. No Version Tracking

**Problem:** Cannot reproduce decisions or rollback effectively.

### Before

```python
async def analyze(text: str) -> dict:
    prompt = load_prompt("analysis")
    result = await openai.chat(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt + text}]
    )
    return {"analysis": result}
```

### After

```python
from dataclasses import dataclass

@dataclass  
class PolicySnapshot:
    model_version: str
    prompt_version: str
    guardrails_version: str

# Store versions in config, not hardcoded
CURRENT_POLICY = PolicySnapshot(
    model_version="gpt-4-0125-preview",
    prompt_version="analysis-v2.3.1",
    guardrails_version="v1.2.0"
)

async def analyze(text: str, trace_id: str) -> dict:
    prompt_template = load_prompt(CURRENT_POLICY.prompt_version)
    
    result = await openai.chat(
        model=CURRENT_POLICY.model_version,
        messages=[{"role": "user", "content": prompt_template + text}]
    )
    
    # Log with full version context
    await log_decision(
        trace_id=trace_id,
        model_version=CURRENT_POLICY.model_version,
        prompt_version=CURRENT_POLICY.prompt_version,
        guardrails_version=CURRENT_POLICY.guardrails_version,
        input_hash=hash(text),
        output_hash=hash(result)
    )
    
    return {"analysis": result, "trace_id": trace_id}
```

**Why it matters:** When something breaks, you need to know exactly what version produced the output.

---

## 3. Silent Retries

**Problem:** Retries consume compute without visibility.

### Before

```python
async def call_tool(tool_name: str, params: dict) -> dict:
    for _ in range(5):
        try:
            return await tools[tool_name].execute(params)
        except Exception:
            await asyncio.sleep(1)
    raise ToolFailure(f"{tool_name} failed after retries")
```

### After

```python
@dataclass
class ToolCallResult:
    success: bool
    result: dict | None
    attempts: int
    total_latency_ms: int
    errors: list[str]

async def call_tool(
    tool_name: str, 
    params: dict, 
    trace_id: str,
    max_retries: int = 3
) -> ToolCallResult:
    attempts = 0
    errors = []
    start_time = time.time()
    
    for attempt in range(max_retries + 1):
        attempts += 1
        try:
            result = await tools[tool_name].execute(params)
            
            await log_tool_call(
                trace_id=trace_id,
                tool=tool_name,
                attempt=attempt,
                success=True,
                latency_ms=int((time.time() - start_time) * 1000)
            )
            
            return ToolCallResult(
                success=True,
                result=result,
                attempts=attempts,
                total_latency_ms=int((time.time() - start_time) * 1000),
                errors=errors
            )
            
        except Exception as e:
            errors.append(str(e))
            
            await log_tool_call(
                trace_id=trace_id,
                tool=tool_name,
                attempt=attempt,
                success=False,
                error=str(e)
            )
            
            if attempt < max_retries:
                await asyncio.sleep(2 ** attempt)  # Exponential backoff
    
    return ToolCallResult(
        success=False,
        result=None,
        attempts=attempts,
        total_latency_ms=int((time.time() - start_time) * 1000),
        errors=errors
    )
```

**Why it matters:** Silent retries are a major source of hidden recompute. Make them visible.

---

## 4. No State Provenance

**Problem:** Cannot explain why current state exists.

### Before

```python
async def update_document(doc_id: str, new_content: str):
    await db.documents.update(
        {"_id": doc_id},
        {"$set": {"content": new_content, "updated_at": datetime.utcnow()}}
    )
```

### After

```python
from enum import Enum

class StateType(Enum):
    DRAFT = "draft"
    COMMITTED = "committed"
    REJECTED = "rejected"

@dataclass
class StateChange:
    output_id: str
    prior_state_id: str | None
    state: StateType
    content_hash: str
    provenance: dict
    created_at: datetime

async def update_document(
    doc_id: str, 
    new_content: str,
    trace_id: str,
    triggered_by: TriggerType,
    user_id: str
) -> StateChange:
    # Get current state for provenance chain
    current = await db.documents.find_one({"_id": doc_id})
    
    new_state_id = str(uuid.uuid4())
    
    change = StateChange(
        output_id=new_state_id,
        prior_state_id=current["output_id"] if current else None,
        state=StateType.DRAFT,
        content_hash=hashlib.sha256(new_content.encode()).hexdigest(),
        provenance={
            "trace_id": trace_id,
            "triggered_by": triggered_by.value,
            "user_id": user_id,
            "timestamp": datetime.utcnow().isoformat()
        },
        created_at=datetime.utcnow()
    )
    
    # Insert new version, don't overwrite
    await db.document_versions.insert_one({
        "doc_id": doc_id,
        "output_id": new_state_id,
        "prior_state_id": change.prior_state_id,
        "state": change.state.value,
        "content": new_content,
        "content_hash": change.content_hash,
        "provenance": change.provenance,
        "created_at": change.created_at
    })
    
    # Update pointer to latest
    await db.documents.update(
        {"_id": doc_id},
        {"$set": {"current_version_id": new_state_id}}
    )
    
    return change
```

**Why it matters:** Full state history enables undo, audit, and debugging. Overwriting destroys provenance.

---

## 5. No Cost Attribution

**Problem:** Cannot attribute costs to features or users.

### Before

```python
async def generate_with_tools(request: dict) -> dict:
    result = await agent.run(request["prompt"])
    return {"result": result}
```

### After

```python
@dataclass
class CostRecord:
    trace_id: str
    user_id: str
    feature: str
    input_tokens: int
    output_tokens: int
    tool_calls: int
    inference_cost_usd: float
    total_latency_ms: int

async def generate_with_tools(
    request: dict,
    trace_id: str,
    feature: str = "default"
) -> dict:
    start_time = time.time()
    
    # Run with token tracking
    result = await agent.run(request["prompt"])
    
    # Calculate costs (use your provider's pricing)
    input_tokens = result.usage.input_tokens
    output_tokens = result.usage.output_tokens
    tool_calls = len(result.tool_calls)
    
    # Example pricing (adjust for your model)
    input_cost = input_tokens * 0.00001  # $0.01 per 1K input tokens
    output_cost = output_tokens * 0.00003  # $0.03 per 1K output tokens
    inference_cost = input_cost + output_cost
    
    cost = CostRecord(
        trace_id=trace_id,
        user_id=request["user_id"],
        feature=feature,
        input_tokens=input_tokens,
        output_tokens=output_tokens,
        tool_calls=tool_calls,
        inference_cost_usd=inference_cost,
        total_latency_ms=int((time.time() - start_time) * 1000)
    )
    
    await log_cost(cost)
    
    return {
        "result": result.content,
        "trace_id": trace_id,
        "cost_usd": inference_cost
    }
```

**Why it matters:** Without cost attribution, you cannot identify which features or users drive margin erosion.

---

## 6. No Circuit Breaker

**Problem:** Cascading failures when dependencies are down.

### Before

```python
async def get_embedding(text: str) -> list[float]:
    return await embedding_api.embed(text)

async def search(query: str) -> list[dict]:
    embedding = await get_embedding(query)  # Fails hard if API down
    results = await vector_db.search(embedding)
    return results
```

### After

```python
from circuitbreaker import circuit

class EmbeddingUnavailable(Exception):
    pass

@circuit(
    failure_threshold=5,      # Open after 5 failures
    recovery_timeout=30,       # Try again after 30 seconds
    expected_exception=Exception
)
async def get_embedding(text: str) -> list[float]:
    return await embedding_api.embed(text)

async def search(query: str, trace_id: str) -> list[dict]:
    try:
        embedding = await get_embedding(query)
        results = await vector_db.search(embedding)
        return results
        
    except CircuitBreakerError:
        # Log the degradation
        await log_event(
            trace_id=trace_id,
            event="circuit_breaker_open",
            service="embedding_api"
        )
        
        # Graceful degradation: fall back to keyword search
        return await keyword_search(query)
```

**Why it matters:** Without circuit breakers, one failing dependency takes down your entire system.

---

## 7. No Decision Envelope

**Problem:** Cannot prove why a decision was made.

### Before

```python
async def approve_content(content: str) -> bool:
    result = await safety_check(content)
    return result.is_safe
```

### After

```python
@dataclass
class DecisionEnvelope:
    trace_id: str
    timestamp: str
    inputs: dict
    policy: dict
    output: dict
    reasoning: dict | None = None

async def approve_content(
    content: str,
    trace_id: str,
    user_id: str
) -> tuple[bool, DecisionEnvelope]:
    
    timestamp = datetime.utcnow().isoformat()
    
    # Run safety check with full context capture
    result = await safety_check(content)
    
    envelope = DecisionEnvelope(
        trace_id=trace_id,
        timestamp=timestamp,
        inputs={
            "user_action": "content_approval",
            "user_id": user_id,
            "content_hash": hashlib.sha256(content.encode()).hexdigest()
        },
        policy={
            "model_version": CURRENT_POLICY.model_version,
            "guardrails_version": CURRENT_POLICY.guardrails_version,
            "rules_applied": result.rules_triggered
        },
        output={
            "result_id": str(uuid.uuid4()),
            "state": "approved" if result.is_safe else "rejected",
            "confidence": result.confidence
        },
        reasoning={
            "flags": result.flags,
            "score": result.safety_score
        }
    )
    
    await store_decision_envelope(envelope)
    
    return result.is_safe, envelope
```

**Why it matters:** When an auditor asks "why did you approve this?", you need a complete answer.

---

## Quick Reference

| Anti-Pattern | Signal | Fix |
|--------------|--------|-----|
| Missing trigger type | Cannot explain cost spikes | Add trigger type to all requests |
| No version tracking | Cannot reproduce issues | Log model, prompt, guardrails versions |
| Silent retries | Hidden recompute | Log every retry with attempt count |
| No state provenance | Cannot explain current state | Version all state, link to prior |
| No cost attribution | Cannot identify cost drivers | Log costs per feature, per user |
| No circuit breaker | Cascading failures | Wrap external calls, add fallbacks |
| No decision envelope | Cannot prove decisions | Capture inputs, policy, reasoning |
