# System Assessment

Complete this assessment in 10 minutes. It will tell you where you are and what to do next.

---

## Instructions

1. Answer each question honestly
2. Score each section
3. Calculate your total
4. Get your recommended actions

---

## Section 1: Traceability

For a random output from yesterday, can you answer these?

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Can you find the trace ID? | | | | |
| Can you see what model version was used? | | | | |
| Can you see what prompt version was used? | | | | |
| Can you see what user action triggered it? | | | | |
| Can you explain the output in under 10 minutes? | | | | |

**Section 1 Total:** ___ / 10

---

## Section 2: Economics

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Do you know your cost per successful outcome? | | | | |
| Do you track cost by trigger type (explicit vs hidden)? | | | | |
| Do you know your hidden recompute ratio? | | | | |
| Do you have cost alerts set up? | | | | |
| Can you model your costs at 10x usage? | | | | |

**Section 2 Total:** ___ / 10

---

## Section 3: Auditability

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Can you prove what the system knew at decision time? | | | | |
| Are human approvals recorded with timestamps? | | | | |
| Do you have decision envelopes for critical outputs? | | | | |
| Can you reconstruct a decision from 6 months ago? | | | | |
| Do you meet your industry's retention requirements? | | | | |

**Section 3 Total:** ___ / 10

---

## Section 4: Reliability

| Question | Yes (2) | Partial (1) | No (0) | Score |
|----------|---------|-------------|--------|-------|
| Do you have circuit breakers for external dependencies? | | | | |
| Can you roll back a deployment in under 5 minutes? | | | | |
| Do you have eval gates blocking bad deploys? | | | | |
| Do you track tool success rates? | | | | |
| Do you have defined SLOs for latency? | | | | |

**Section 4 Total:** ___ / 10

---

## Your Score

| Section | Score | Status |
|---------|-------|--------|
| Traceability | /10 | |
| Economics | /10 | |
| Auditability | /10 | |
| Reliability | /10 | |
| **Total** | **/40** | |

### Scoring Guide

| Total Score | Maturity Level | Status |
|-------------|----------------|--------|
| 0-10 | Level 1: Blind | Critical - start with [First 48 Hours](00-templates/first-48-hours.md) |
| 11-20 | Level 2: Reactive | Warning - prioritize your lowest section |
| 21-30 | Level 3: Observable | Good - fill specific gaps |
| 31-35 | Level 4: Controlled | Strong - optimize and document |
| 36-40 | Level 5: Optimized | Excellent - share your learnings |

---

## Your Lowest Section

Find your lowest scoring section. That's your priority.

### If Traceability is lowest (Section 1):

**Your problem:** You cannot explain outputs.

**Quick win (30 min):** Add trace IDs to all inference calls.

```python
# Add this to every inference call
log_entry = {
    "trace_id": str(uuid4()),
    "model_version": MODEL_VERSION,
    "prompt_version": PROMPT_VERSION,
    "user_action": request.action,
    "timestamp": datetime.utcnow().isoformat(),
}
```

**Read next:** [Legibility Loss](01-failure-modes/legibility-loss.md)

**Implement:** [fastapi-provenance-middleware.py](07-examples/fastapi-provenance-middleware.py)

---

### If Economics is lowest (Section 2):

**Your problem:** You do not know your true costs.

**Quick win (10 min):** Run this query to get cost per outcome:

```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  SUM(cost_usd) as total_cost,
  COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END) as successful,
  SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END), 0) as cost_per_outcome
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Read next:** [Cost Investigation](03-economics/cost-investigation.md)

**Implement:** [diagnostic-queries.sql](07-examples/diagnostic-queries.sql)

---

### If Auditability is lowest (Section 3):

**Your problem:** You cannot prove why decisions were made.

**Quick win (1 hour):** Add decision envelope to critical outputs:

```python
decision_envelope = {
    "trace_id": trace_id,
    "timestamp": datetime.utcnow().isoformat(),
    "inputs": {
        "user_action": action,
        "context_hash": hash_context(context),
    },
    "policy": {
        "model_version": MODEL_VERSION,
        "prompt_version": PROMPT_VERSION,
    },
    "output": {
        "result_id": result_id,
        "state": "committed",
    }
}
save_decision_envelope(decision_envelope)
```

**Read next:** [Auditability Gap](01-failure-modes/auditability-gap.md)

**Implement:** [decision-envelope-schema.json](07-examples/decision-envelope-schema.json)

---

### If Reliability is lowest (Section 4):

**Your problem:** You cannot fail gracefully or deploy safely.

**Quick win (30 min):** Add a circuit breaker to your most critical external call:

```python
from circuitbreaker import circuit

@circuit(failure_threshold=5, recovery_timeout=30)
async def call_external_api(request):
    return await external_api.call(request)
```

**Read next:** [Tool Reliability](06-operations/tool-reliability.md)

**Implement:** [orchestrator.py](07-examples/orchestrator.py) (see circuit breaker pattern)

---

## Next Steps

1. **Fix your lowest section first** using the quick win above
2. **Read the recommended document** (20-30 min)
3. **Implement the linked example** (2-4 hours)
4. **Re-run this assessment in 2 weeks**

---

## Share Your Results

When discussing with your team, share:

- Your total score: ___/40
- Your lowest section: ___
- Your first action: ___
- Target re-assessment date: ___
