# System Assessment

> **Use when:** Inheriting a system, quarterly review, pre-acquisition due diligence, or scoping a remediation project.
>
> **Time:** 30-45 minutes for full assessment.
>
> **After completing:** You will have a maturity score, gap analysis, and prioritized action plan.

---

## How to Use This Assessment

1. Answer each question based on evidence, not belief
2. "Partial" means you have something but it does not fully work
3. Score each section
4. Read the diagnosis for your lowest sections
5. Follow the recommended actions in priority order

---

## Section 1: Traceability

Can you explain what happened and why?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Pick a random output from yesterday. Can you find the trace ID within 2 minutes? | | | | |
| Can you see what model version produced that output? | | | | |
| Can you see what prompt version was used? | | | | |
| Can you see what user action triggered the inference? | | | | |
| Can you see what context (documents, conversation history) was included? | | | | |
| Can you see what tools were called and their responses? | | | | |
| Can you explain the output to a non-engineer in under 10 minutes? | | | | |
| Do trace IDs follow requests across all services (not just the LLM call)? | | | | |
| Are traces retained for at least 90 days? | | | | |
| Can you filter traces by user, session, model version, or outcome? | | | | |

**Section 1 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | Strong traceability |
| 10-15 | Gaps will surface in incidents |
| 0-9 | You cannot debug this system |

---

## Section 2: State Management

How do you handle the difference between "thinking" and "done"?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Is there a clear distinction between speculative state (drafts) and committed state (final)? | | | | |
| Can users see what the AI is "thinking" vs what is saved? | | | | |
| Is every state transition recorded with timestamp and trigger? | | | | |
| Can you reconstruct the state at any point in time? | | | | |
| Are failed/abandoned generations recorded (not just deleted)? | | | | |
| Is the state model documented? | | | | |
| Do more than 2 teams depend on this state model? | If yes: (0) If no: (2) | | | |
| Can you migrate state schema without downtime? | | | | |
| Is speculative state garbage-collected on a defined schedule? | | | | |
| Is there a TTL (time-to-live) for drafts/uncommitted state? | | | | |

**Section 2 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | State model is production-grade |
| 10-15 | Edge cases will bite you |
| 0-9 | Implicit state model - document it now |

---

## Section 3: Economics

Do you understand your costs?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Do you know your cost per successful outcome (not just per token)? | | | | |
| Can you break down cost by: explicit user action vs hidden recompute? | | | | |
| Do you know your hidden recompute ratio (retries, auto-saves, undo)? | | | | |
| Do you have alerts for cost anomalies (> 2x normal daily spend)? | | | | |
| Can you attribute cost to specific users, features, or workflows? | | | | |
| Do you have a cost model that projects costs at 10x usage? | | | | |
| Do unit economics improve, stay flat, or degrade at scale? | Improve: (2), Flat: (1), Degrade: (0) | | | |
| Do you track cost per model version? | | | | |
| Can you identify which prompts/features have the worst cost/value ratio? | | | | |
| Do you have a cost cap or budget alert per user session? | | | | |

**Section 3 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | Economics are under control |
| 10-15 | Hidden costs will surprise you at scale |
| 0-9 | You do not know what you are spending |

---

## Section 4: Auditability

Can you prove what happened?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Can you prove what the system knew at the time of any decision? | | | | |
| Are human approvals recorded with timestamp, approver ID, and what was approved? | | | | |
| Do you have decision envelopes (full input/output/policy snapshots) for critical outputs? | | | | |
| Can you reconstruct a decision from 6 months ago with all context? | | | | |
| Do you meet your industry's data retention requirements? | | | | |
| Can you generate an audit log for any user or session on demand? | | | | |
| Are policy versions (what rules applied) recorded with outputs? | | | | |
| Is there an immutable audit trail (not just logs that can be deleted)? | | | | |
| Have you tested your audit capability with a mock audit? | | | | |
| Can you explain your AI decision-making to a regulator in writing? | | | | |

**Section 4 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | Audit-ready |
| 10-15 | Will struggle under scrutiny |
| 0-9 | Cannot pass an audit |

---

## Section 5: Reliability

Can you fail gracefully and recover quickly?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Do you have circuit breakers for external dependencies (model APIs, tools)? | | | | |
| Can you roll back a deployment in under 5 minutes? | | | | |
| Do you have eval gates that block deploys when quality drops? | | | | |
| Do you track success rate for every external tool call? | | | | |
| Do you have defined SLOs for latency (p50, p95, p99)? | | | | |
| Do you have fallback behavior when the primary model is unavailable? | | | | |
| Are retries capped and exponentially backed off? | | | | |
| Do you monitor retry rate as a leading indicator of problems? | | | | |
| Can you gracefully degrade (serve cached/simpler responses) under load? | | | | |
| Do you have runbooks for common failure scenarios? | | | | |

**Section 5 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | Resilient operations |
| 10-15 | Will struggle under failure conditions |
| 0-9 | Fragile - expect outages |

---

## Section 6: Safety and Guardrails

What prevents bad outputs?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Do you have input validation (blocklists, format checks) before model calls? | | | | |
| Do you have output filtering (content classification, PII detection) after model calls? | | | | |
| Are guardrails layered (multiple independent checks)? | | | | |
| Do you log blocked requests for analysis? | | | | |
| Can you update guardrails without a full deploy? | | | | |
| Do you have rate limits per user/session? | | | | |
| Do you have cost caps per user/session? | | | | |
| Have you tested guardrails with adversarial inputs? | | | | |
| Is there a human escalation path for edge cases? | | | | |
| Do you track guardrail trigger rate as a metric? | | | | |

**Section 6 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | Defense in depth |
| 10-15 | Single point of failure in safety |
| 0-9 | Abuse and bad outputs are undefended |

---

## Section 7: Orchestration

How are multi-step workflows managed?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Are orchestration decisions (what to do next) logged? | | | | |
| Is there a clear orchestration pattern (chain, router, parallel, state machine)? | | | | |
| Can you trace the full path of a multi-agent interaction? | | | | |
| Are there timeouts for long-running orchestrations? | | | | |
| Is there a maximum depth/iteration limit for recursive agent calls? | | | | |
| Can you cancel/abort an in-progress orchestration cleanly? | | | | |
| Are intermediate results persisted (not lost on crash)? | | | | |
| Do you track orchestration latency breakdown (which step took how long)? | | | | |
| Is the orchestration pattern documented? | | | | |
| Can you replay a failed orchestration from a checkpoint? | | | | |

**Section 7 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | Production-grade orchestration |
| 10-15 | Debugging will be painful |
| 0-9 | Black box - you cannot see inside |

---

## Section 8: Control Plane Ownership

What do you control vs what controls you?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Could you switch model providers within 30 days if needed? | | | | |
| Do you have a documented exit strategy for every critical vendor? | | | | |
| Can you run evaluations without calling the production model API? | | | | |
| Do you own your training/fine-tuning data? | | | | |
| Do you own your evaluation datasets? | | | | |
| Can you deploy in a different region if required? | | | | |
| Is there a single vendor whose outage would stop your entire system? | If yes: (0) If no: (2) | | | |
| Have you tested recovery from a vendor outage? | | | | |
| Are vendor contracts reviewed for data usage rights? | | | | |
| Do you have leverage (alternatives) in vendor negotiations? | | | | |

**Section 8 Total:** ___ / 20

| Score | Interpretation |
|-------|----------------|
| 16-20 | Strong operational independence |
| 10-15 | Some vendor lock-in risk |
| 0-9 | Dependent - vendor changes will hurt |

---

## Score Summary

| Section | Score | Max | Status |
|---------|-------|-----|--------|
| 1. Traceability | | 20 | |
| 2. State Management | | 20 | |
| 3. Economics | | 20 | |
| 4. Auditability | | 20 | |
| 5. Reliability | | 20 | |
| 6. Safety & Guardrails | | 20 | |
| 7. Orchestration | | 20 | |
| 8. Control Plane | | 20 | |
| **Total** | | **160** | |

### Maturity Level

| Total Score | Level | Status |
|-------------|-------|--------|
| 0-40 | Level 1: Blind | Critical gaps across multiple areas |
| 41-80 | Level 2: Reactive | Some observability, many gaps |
| 81-120 | Level 3: Observable | Functional but fragile |
| 121-140 | Level 4: Controlled | Production-grade with minor gaps |
| 141-160 | Level 5: Optimized | Best-in-class operations |

---

## Gap Analysis

List your three lowest-scoring sections:

1. **Lowest:** ________________ (Score: ___/20)
2. **Second:** ________________ (Score: ___/20)
3. **Third:** ________________ (Score: ___/20)

---

## Remediation by Section

### If Traceability is lowest (Section 1)

**Your problem:** You cannot explain outputs.

**Why it matters:** Without traceability, every incident becomes a mystery. Debug time increases 10x. Customer escalations become crises.

**Quick win (30 min):** Add trace IDs to all inference calls:

```python
import uuid
from datetime import datetime

def create_trace_context(request):
    return {
        "trace_id": str(uuid.uuid4()),
        "model_version": MODEL_VERSION,
        "prompt_version": PROMPT_VERSION,
        "user_id": request.user_id,
        "session_id": request.session_id,
        "action": request.action,
        "timestamp": datetime.utcnow().isoformat(),
    }

# Include trace_context in all logs and stored outputs
```

**This week:**
1. Instrument all inference calls with trace IDs
2. Ensure traces flow across service boundaries
3. Set up log aggregation with trace ID filtering

**Read:** [Legibility Loss](01-failure-modes/legibility-loss.md)

**Implement:** [fastapi-provenance-middleware.py](07-examples/fastapi-provenance-middleware.py)

---

### If State Management is lowest (Section 2)

**Your problem:** You cannot distinguish thinking from done.

**Why it matters:** Without explicit state, you cannot debug undo, cannot calculate true costs, and cannot audit decisions. Every "draft" is a liability.

**Quick win (1 hour):** Add state field to all AI outputs:

```python
from enum import Enum

class OutputState(Enum):
    SPECULATIVE = "speculative"  # AI is thinking
    PENDING = "pending"          # Waiting for user
    COMMITTED = "committed"      # User accepted
    DISCARDED = "discarded"      # User rejected

# Every output record must have:
# - state: OutputState
# - state_transitions: List[{from, to, timestamp, trigger}]
```

**This week:**
1. Audit current implicit state model
2. Add explicit state field to output records
3. Log all state transitions

**Read:** [State Model](02-architecture/state-model.md)

**Implement:** [traceability-postgres-schema.sql](07-examples/traceability-postgres-schema.sql)

---

### If Economics is lowest (Section 3)

**Your problem:** You do not know your true costs.

**Why it matters:** Without cost visibility, you cannot price correctly, cannot detect waste, and will be surprised when scale destroys margin.

**Quick win (10 min):** Run this query:

```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  SUM(cost_usd) as total_cost,
  COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END) as successful,
  SUM(cost_usd) / NULLIF(
    COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END), 0
  ) as cost_per_outcome,
  SUM(CASE WHEN trigger_type = 'explicit' THEN cost_usd ELSE 0 END) as explicit_cost,
  SUM(CASE WHEN trigger_type != 'explicit' THEN cost_usd ELSE 0 END) as hidden_cost
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**This week:**
1. Add cost tracking to all inference calls
2. Classify triggers as explicit vs hidden
3. Set up daily cost alerts (> 2x normal)

**Read:** [Cost Investigation](03-economics/cost-investigation.md)

**Implement:** [diagnostic-queries.sql](07-examples/diagnostic-queries.sql)

---

### If Auditability is lowest (Section 4)

**Your problem:** You cannot prove why decisions were made.

**Why it matters:** Without auditability, you cannot pass enterprise audits, cannot defend against legal challenges, and cannot win compliance-sensitive deals.

**Quick win (1 hour):** Add decision envelopes to critical outputs:

```python
def create_decision_envelope(trace_id, inputs, policy, output, approvals=None):
    return {
        "envelope_version": "1.0",
        "trace_id": trace_id,
        "created_at": datetime.utcnow().isoformat(),
        "inputs": {
            "user_action": inputs["action"],
            "context_hash": hash_context(inputs["context"]),
            "context_snapshot": inputs["context"],  # Full content for audit
        },
        "policy": {
            "model_version": policy["model_version"],
            "prompt_version": policy["prompt_version"],
            "guardrail_versions": policy["guardrails"],
        },
        "output": {
            "result_id": output["id"],
            "state": output["state"],
            "content_hash": hash_content(output["content"]),
        },
        "approvals": approvals or [],
    }

# Store immutably - do not allow updates/deletes
```

**This week:**
1. Identify critical outputs that need envelopes
2. Implement decision envelope storage (immutable)
3. Test with mock audit retrieval

**Read:** [Auditability Gap](01-failure-modes/auditability-gap.md)

**Implement:** [decision-envelope-schema.json](07-examples/decision-envelope-schema.json)

---

### If Reliability is lowest (Section 5)

**Your problem:** You cannot fail gracefully.

**Why it matters:** Without reliability patterns, every external failure cascades. No circuit breakers means one bad vendor call can take down your system.

**Quick win (30 min):** Add circuit breaker to critical calls:

```python
from circuitbreaker import circuit

@circuit(
    failure_threshold=5,
    recovery_timeout=30,
    expected_exception=ExternalAPIError
)
async def call_model_api(request):
    return await model_api.generate(request)

# Also add: timeout, retry with backoff, fallback
```

**This week:**
1. Identify critical external dependencies
2. Add circuit breakers with appropriate thresholds
3. Implement fallback behavior for each
4. Document in runbooks

**Read:** [Tool Reliability](06-operations/tool-reliability.md)

**Implement:** [orchestrator.py](07-examples/orchestrator.py)

---

### If Safety & Guardrails is lowest (Section 6)

**Your problem:** Bad outputs are undefended.

**Why it matters:** Without guardrails, you are one prompt injection away from a PR crisis. Abuse is a matter of when, not if.

**Quick win (2 hours):** Add layered guardrails:

```python
class GuardrailResult:
    passed: bool
    blocked_reason: Optional[str]
    confidence: float

async def apply_guardrails(input_text: str, output_text: str) -> GuardrailResult:
    # Layer 1: Rule-based (fast, cheap)
    if contains_blocked_patterns(input_text):
        return GuardrailResult(passed=False, blocked_reason="input_blocked", confidence=1.0)
    
    # Layer 2: Classification (medium speed)
    classification = await classify_content(output_text)
    if classification.is_harmful:
        return GuardrailResult(passed=False, blocked_reason="harmful_content", confidence=classification.confidence)
    
    # Layer 3: PII detection
    if contains_pii(output_text):
        return GuardrailResult(passed=False, blocked_reason="pii_detected", confidence=0.95)
    
    return GuardrailResult(passed=True, blocked_reason=None, confidence=1.0)
```

**This week:**
1. Implement at least 2 guardrail layers
2. Add logging for blocked requests
3. Set up guardrail trigger rate monitoring

**Read:** [Safety Surface](06-operations/safety-surface.md)

**Implement:** [guardrails.py](07-examples/guardrails.py)

---

### If Orchestration is lowest (Section 7)

**Your problem:** Multi-step workflows are black boxes.

**Why it matters:** Without orchestration visibility, you cannot debug agent loops, cannot optimize costs, and cannot identify slow steps.

**Quick win (1 hour):** Add orchestration logging:

```python
class OrchestrationLogger:
    def __init__(self, trace_id: str):
        self.trace_id = trace_id
        self.steps = []
    
    def log_step(self, step_name: str, input_summary: str, output_summary: str, duration_ms: int, cost_usd: float):
        self.steps.append({
            "trace_id": self.trace_id,
            "step": step_name,
            "step_index": len(self.steps),
            "input_summary": input_summary,
            "output_summary": output_summary,
            "duration_ms": duration_ms,
            "cost_usd": cost_usd,
            "timestamp": datetime.utcnow().isoformat(),
        })
    
    def get_summary(self):
        return {
            "trace_id": self.trace_id,
            "total_steps": len(self.steps),
            "total_duration_ms": sum(s["duration_ms"] for s in self.steps),
            "total_cost_usd": sum(s["cost_usd"] for s in self.steps),
            "steps": self.steps,
        }
```

**This week:**
1. Identify current orchestration pattern (or document the implicit one)
2. Add step-level logging
3. Add timeouts and depth limits

**Read:** [Orchestration](06-operations/orchestration.md)

**Implement:** [orchestrator.py](07-examples/orchestrator.py)

---

### If Control Plane is lowest (Section 8)

**Your problem:** You are dependent on vendors you cannot replace.

**Why it matters:** Without exit strategies, vendor price increases or outages become existential risks. You have no negotiating leverage.

**Quick win (2 hours):** Document dependencies and exits:

| Dependency | Vendor | What Breaks If They Fail | Exit Time | Exit Cost |
|------------|--------|--------------------------|-----------|-----------|
| Primary model | | | | |
| Embeddings | | | | |
| Vector DB | | | | |
| Tool APIs | | | | |

**This week:**
1. List all critical vendor dependencies
2. Estimate exit time and cost for each
3. Identify single points of failure
4. Test failover for at least one

**Read:** [Control Plane Ownership](02-architecture/control-plane-ownership.md)

**Implement:** Review [API vs Owned](03-economics/api-vs-owned.md)

---

## Action Plan

Based on your gap analysis, fill in:

| Priority | Section | First Action | Owner | Due Date |
|----------|---------|--------------|-------|----------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

---

## Re-Assessment Schedule

| Date | Assessor | Total Score | Lowest Section | Notes |
|------|----------|-------------|----------------|-------|
| | | /160 | | Initial assessment |
| +2 weeks | | /160 | | |
| +1 month | | /160 | | |
| +1 quarter | | /160 | | |

---

## Assessment Artifacts

After completing this assessment, you should have:

- [ ] Completed scorecard (this document, filled in)
- [ ] Gap analysis identifying top 3 priority areas
- [ ] Action plan with owners and dates
- [ ] Re-assessment scheduled

Store the completed assessment with your system documentation.
