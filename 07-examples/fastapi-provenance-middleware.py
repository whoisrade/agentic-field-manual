"""
FastAPI Middleware for AI System Provenance

This middleware captures decision context for every AI-related request.
Attach it to your FastAPI app to automatically log decision envelopes.

Usage:
    from fastapi import FastAPI
    from provenance_middleware import ProvenanceMiddleware

    app = FastAPI()
    app.add_middleware(ProvenanceMiddleware, db_url="postgresql://...")
"""

import uuid
import time
import hashlib
import json
from datetime import datetime
from typing import Optional, Dict, Any, Callable
from dataclasses import dataclass, asdict
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.types import ASGIApp
import asyncpg


# ============================================================================
# DATA STRUCTURES
# ============================================================================

@dataclass
class DecisionEnvelope:
    """The core provenance record for any AI decision."""
    trace_id: str
    timestamp: str
    user_id: Optional[str]
    session_id: Optional[str]
    user_action: str
    trigger_type: str
    prompt_version: str
    model_version: str
    result_id: str
    state: str  # 'draft', 'committed', 'rejected'
    context_hash: Optional[str] = None
    prior_state_id: Optional[str] = None
    inference_cost_usd: Optional[float] = None
    input_tokens: Optional[int] = None
    output_tokens: Optional[int] = None
    total_latency_ms: Optional[int] = None
    confidence: Optional[float] = None
    metadata: Optional[Dict[str, Any]] = None


@dataclass
class ToolCall:
    """Record of an external tool invocation."""
    decision_envelope_id: str
    tool_name: str
    input_hash: Optional[str]
    output_hash: Optional[str]
    latency_ms: int
    success: bool
    retry_count: int = 0
    error_message: Optional[str] = None


# ============================================================================
# CONTEXT MANAGER FOR REQUEST-SCOPED PROVENANCE
# ============================================================================

class ProvenanceContext:
    """
    Request-scoped context for building a decision envelope.

    Usage in your endpoint:
        @app.post("/generate")
        async def generate(request: Request):
            ctx = request.state.provenance
            ctx.set_user_action("generate")
            ctx.set_model_version("gpt-4-0125")

            # ... do work ...

            ctx.add_tool_call("search", input_data, output_data, latency_ms=150)
            ctx.set_result(result_id, state="committed", confidence=0.87)
    """

    def __init__(self, trace_id: str):
        self.trace_id = trace_id
        self.start_time = time.time()
        self.envelope_data: Dict[str, Any] = {
            "trace_id": trace_id,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "trigger_type": "user_explicit",  # default
            "state": "draft",  # default
        }
        self.tool_calls: list[ToolCall] = []

    def set_user(self, user_id: str, session_id: Optional[str] = None):
        self.envelope_data["user_id"] = user_id
        if session_id:
            self.envelope_data["session_id"] = session_id

    def set_user_action(self, action: str):
        self.envelope_data["user_action"] = action

    def set_trigger_type(self, trigger_type: str):
        """One of: user_explicit, undo, auto_save, retry, background"""
        self.envelope_data["trigger_type"] = trigger_type

    def set_context(self, context: Any, prior_state_id: Optional[str] = None):
        """Hash the context for reproducibility tracking."""
        context_str = json.dumps(context, sort_keys=True, default=str)
        self.envelope_data["context_hash"] = hashlib.sha256(context_str.encode()).hexdigest()[:16]
        if prior_state_id:
            self.envelope_data["prior_state_id"] = prior_state_id

    def set_policy(self, prompt_version: str, model_version: str, guardrails_version: Optional[str] = None):
        self.envelope_data["prompt_version"] = prompt_version
        self.envelope_data["model_version"] = model_version
        if guardrails_version:
            self.envelope_data["guardrails_version"] = guardrails_version

    def set_result(
        self,
        result_id: str,
        state: str = "draft",  # 'draft', 'committed', 'rejected'
        confidence: Optional[float] = None
    ):
        self.envelope_data["result_id"] = result_id
        self.envelope_data["state"] = state
        if confidence is not None:
            self.envelope_data["confidence"] = confidence

    def set_cost(
        self,
        inference_cost_usd: Optional[float] = None,
        input_tokens: Optional[int] = None,
        output_tokens: Optional[int] = None
    ):
        if inference_cost_usd is not None:
            self.envelope_data["inference_cost_usd"] = inference_cost_usd
        if input_tokens is not None:
            self.envelope_data["input_tokens"] = input_tokens
        if output_tokens is not None:
            self.envelope_data["output_tokens"] = output_tokens

    def add_tool_call(
        self,
        tool_name: str,
        input_data: Any,
        output_data: Any,
        latency_ms: int,
        success: bool = True,
        retry_count: int = 0,
        error_message: Optional[str] = None
    ):
        input_hash = hashlib.sha256(json.dumps(input_data, sort_keys=True, default=str).encode()).hexdigest()[:16]
        output_hash = hashlib.sha256(json.dumps(output_data, sort_keys=True, default=str).encode()).hexdigest()[:16] if output_data else None

        self.tool_calls.append(ToolCall(
            decision_envelope_id=self.trace_id,  # Will be updated with actual envelope ID
            tool_name=tool_name,
            input_hash=input_hash,
            output_hash=output_hash,
            latency_ms=latency_ms,
            success=success,
            retry_count=retry_count,
            error_message=error_message
        ))

    def set_metadata(self, metadata: Dict[str, Any]):
        self.envelope_data["metadata"] = metadata

    def finalize(self) -> DecisionEnvelope:
        """Build the final envelope with computed fields."""
        self.envelope_data["total_latency_ms"] = int((time.time() - self.start_time) * 1000)

        # Ensure required fields have defaults
        if "user_action" not in self.envelope_data:
            self.envelope_data["user_action"] = "unknown"
        if "prompt_version" not in self.envelope_data:
            self.envelope_data["prompt_version"] = "unknown"
        if "model_version" not in self.envelope_data:
            self.envelope_data["model_version"] = "unknown"
        if "result_id" not in self.envelope_data:
            self.envelope_data["result_id"] = str(uuid.uuid4())

        return DecisionEnvelope(**self.envelope_data)


# ============================================================================
# STORAGE
# ============================================================================

class ProvenanceStore:
    """Async storage for decision envelopes."""

    def __init__(self, db_url: str):
        self.db_url = db_url
        self.pool: Optional[asyncpg.Pool] = None

    async def connect(self):
        self.pool = await asyncpg.create_pool(self.db_url, min_size=2, max_size=10)

    async def disconnect(self):
        if self.pool:
            await self.pool.close()

    async def save_envelope(self, envelope: DecisionEnvelope) -> str:
        """Save a decision envelope and return its ID."""
        async with self.pool.acquire() as conn:
            result = await conn.fetchrow("""
                INSERT INTO decision_envelopes (
                    trace_id, created_at, user_id, session_id, user_action,
                    trigger_type, context_hash, prior_state_id,
                    prompt_version, model_version,
                    result_id, state, confidence,
                    inference_cost_usd, input_tokens, output_tokens, total_latency_ms,
                    metadata
                ) VALUES (
                    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18
                ) RETURNING id
            """,
                uuid.UUID(envelope.trace_id),
                datetime.fromisoformat(envelope.timestamp.rstrip('Z')),
                envelope.user_id,
                envelope.session_id,
                envelope.user_action,
                envelope.trigger_type,
                envelope.context_hash,
                uuid.UUID(envelope.prior_state_id) if envelope.prior_state_id else None,
                envelope.prompt_version,
                envelope.model_version,
                uuid.UUID(envelope.result_id),
                envelope.state,
                envelope.confidence,
                envelope.inference_cost_usd,
                envelope.input_tokens,
                envelope.output_tokens,
                envelope.total_latency_ms,
                json.dumps(envelope.metadata) if envelope.metadata else None
            )
            return str(result['id'])

    async def save_tool_calls(self, envelope_id: str, tool_calls: list[ToolCall]):
        """Save tool calls associated with an envelope."""
        if not tool_calls:
            return

        async with self.pool.acquire() as conn:
            for tc in tool_calls:
                await conn.execute("""
                    INSERT INTO tool_calls (
                        decision_envelope_id, tool_name, input_hash, output_hash,
                        latency_ms, success, retry_count, error_message
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                """,
                    uuid.UUID(envelope_id),
                    tc.tool_name,
                    tc.input_hash,
                    tc.output_hash,
                    tc.latency_ms,
                    tc.success,
                    tc.retry_count,
                    tc.error_message
                )


# ============================================================================
# MIDDLEWARE
# ============================================================================

class ProvenanceMiddleware(BaseHTTPMiddleware):
    """
    FastAPI middleware that automatically tracks provenance for AI requests.

    For each request:
    1. Creates a ProvenanceContext attached to request.state.provenance
    2. Your endpoint populates the context
    3. After the response, saves the decision envelope
    """

    def __init__(
        self,
        app: ASGIApp,
        db_url: str,
        ai_paths: Optional[list[str]] = None,  # Only track these paths (e.g., ["/generate", "/analyze"])
        exclude_paths: Optional[list[str]] = None  # Exclude these paths
    ):
        super().__init__(app)
        self.store = ProvenanceStore(db_url)
        self.ai_paths = ai_paths or []
        self.exclude_paths = exclude_paths or ["/health", "/metrics"]
        self._initialized = False

    async def _ensure_connected(self):
        if not self._initialized:
            await self.store.connect()
            self._initialized = True

    def _should_track(self, path: str) -> bool:
        """Determine if this request should have provenance tracking."""
        if any(path.startswith(p) for p in self.exclude_paths):
            return False
        if self.ai_paths:
            return any(path.startswith(p) for p in self.ai_paths)
        return True

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        await self._ensure_connected()

        if not self._should_track(request.url.path):
            return await call_next(request)

        # Create provenance context for this request
        trace_id = request.headers.get("X-Trace-ID", str(uuid.uuid4()))
        ctx = ProvenanceContext(trace_id)

        # Extract user from auth header if available
        if auth := request.headers.get("Authorization"):
            # Simplified - in production, decode JWT and extract user_id
            ctx.set_user(user_id="extracted-from-auth")

        # Attach to request state
        request.state.provenance = ctx

        # Call the endpoint
        response = await call_next(request)

        # Only save if the endpoint actually used the context
        if hasattr(request.state, 'provenance') and ctx.envelope_data.get("user_action"):
            try:
                envelope = ctx.finalize()
                envelope_id = await self.store.save_envelope(envelope)
                await self.store.save_tool_calls(envelope_id, ctx.tool_calls)

                # Add trace ID to response headers for debugging
                response.headers["X-Trace-ID"] = trace_id
                response.headers["X-Decision-Envelope-ID"] = envelope_id
            except Exception as e:
                # Don't fail the request if provenance saving fails
                # Log error in production
                print(f"Failed to save provenance: {e}")

        return response


# ============================================================================
# EXAMPLE USAGE
# ============================================================================

"""
Example endpoint using the middleware:

@app.post("/generate")
async def generate_content(request: Request, payload: GenerateRequest):
    ctx = request.state.provenance

    # Set basic info
    ctx.set_user_action("generate")
    ctx.set_trigger_type("user_explicit")
    ctx.set_policy(
        prompt_version="content-gen-v2.3",
        model_version="gpt-4-0125-preview"
    )
    ctx.set_context(
        context={"input": payload.prompt, "options": payload.options},
        prior_state_id=payload.prior_version_id
    )

    # Call external tools
    start = time.time()
    search_results = await search_service.query(payload.prompt)
    ctx.add_tool_call(
        tool_name="search",
        input_data={"query": payload.prompt},
        output_data=search_results,
        latency_ms=int((time.time() - start) * 1000)
    )

    # Generate content
    result = await llm.generate(payload.prompt, context=search_results)

    # Record result
    ctx.set_result(
        result_id=str(uuid.uuid4()),
        state="draft",
        confidence=result.confidence
    )
    ctx.set_cost(
        inference_cost_usd=result.cost,
        input_tokens=result.input_tokens,
        output_tokens=result.output_tokens
    )

    return {"content": result.text, "result_id": ctx.envelope_data["result_id"]}
"""
