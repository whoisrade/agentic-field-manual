# Quick Reference Card

Print this. Keep it visible.

---

## Severity Levels

| Level | Definition | Response |
|-------|------------|----------|
| **P0** | System down, data loss, wrong outputs at scale | Immediate, all hands |
| **P1** | Major feature broken, revenue impact | Within 1 hour |
| **P2** | Feature degraded, workaround exists | Within 4 hours |
| **P3** | Minor issue, no revenue impact | Within 1 week |

**P0/P1:** Use [Crisis Playbook](00-templates/crisis-playbook.md)

---

## Health Thresholds

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Time to explain output | <10 min | 10-60 min | >1 hour |
| Hidden recompute ratio | <20% | 20-40% | >40% |
| Cost per outcome trend | Stable | <10% MoM rise | >10% MoM rise |
| Missing decision records | <5% | 5-20% | >20% |
| Eval pass rate | >90% | 85-90% | <85% |
| Tool success rate | >98% | 95-98% | <95% |
| Rollback time | <5 min | 5-30 min | >30 min |

---

## The 4 Failure Modes

| Mode | Signal | Fix |
|------|--------|-----|
| **Legibility Loss** | Can't explain outputs | Add trace IDs, log versions |
| **Control Surface Drift** | Costs up, traffic flat | Track trigger types, redesign UX |
| **Auditability Gap** | Can't prove rationale | Implement decision envelopes |
| **Margin Fragility** | Scale destroys margin | Track cost per outcome |

---

## The 3 Irreversible Decisions

| Decision | Question | Risk |
|----------|----------|------|
| **State Model** | What do we persist? | Schema changes become migrations |
| **Interaction Contract** | What triggers compute? | Users form habits |
| **Control Plane** | Own or rent? | Vendor lock-in |

---

## Minimum Viable Logging

```python
{
    "trace_id": "uuid",
    "timestamp": "iso8601",
    "trigger_type": "user_explicit|undo|retry|auto_save",
    "model_version": "string",
    "prompt_version": "string",
    "input_tokens": int,
    "output_tokens": int,
    "cost_usd": float,
    "latency_ms": int,
    "status": "success|failed|timeout"
}
```

---

## Cost Per Outcome Query

```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  SUM(cost_usd) / NULLIF(
    COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END), 0
  ) as cost_per_outcome
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1 ORDER BY 1;
```

---

## Hidden Recompute Query

```sql
SELECT
  SUM(CASE WHEN trigger_type IN ('undo','retry','auto_save') THEN 1 ELSE 0 END)::float 
  / COUNT(*) as hidden_ratio
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days';
```

---

## Circuit Breaker Pattern

```python
from circuitbreaker import circuit

@circuit(failure_threshold=5, recovery_timeout=30)
async def call_external(request):
    return await external_api.call(request)
```

---

## Decision Envelope (Minimum)

```json
{
  "trace_id": "uuid",
  "timestamp": "iso8601",
  "inputs": {"user_action": "string", "context_hash": "string"},
  "policy": {"model_version": "string", "prompt_version": "string"},
  "output": {"result_id": "uuid", "state": "draft|committed|rejected"}
}
```

---

## Maturity Levels

| Level | Description |
|-------|-------------|
| 1 | Blind - Cannot explain outputs |
| 2 | Reactive - Can explain with effort |
| 3 | Observable - Can explain in 10 min |
| 4 | Controlled - Real-time tracing, alerts |
| 5 | Optimized - Self-diagnosing |

**Target:** Level 3-4

---

## Key Documents

| Need | Document |
|------|----------|
| Crisis | [Crisis Playbook](00-templates/crisis-playbook.md) |
| Cost spike | [Cost Spike Runbook](00-templates/cost-spike-runbook.md) |
| Assessment | [ASSESS.md](ASSESS.md) |
| Pre-ship | [Pre-Ship Checklist](00-templates/pre-ship-checklist.md) |
| Post-incident | [Incident Post-Mortem](00-templates/incident-postmortem.md) |
| Metrics | [Metrics Reference](07-examples/metrics-reference.md) |
| SQL diagnostics | [Diagnostic Queries](07-examples/diagnostic-queries.sql) |
| Stakeholder talk | [Conversation Scripts](05-communication/conversation-scripts.md) |
| Code patterns | [Before/After Patterns](07-examples/before-after-patterns.md) |

---

## Weekly Checks

Use [Weekly Ops Checklist](00-templates/weekly-ops-checklist.md)

- [ ] Cost per outcome trend
- [ ] Hidden recompute ratio
- [ ] Eval pass rate
- [ ] Tool success rates
- [ ] Circuit breaker trips

---

## Quarterly Review

Use [System Drift Review](06-operations/system-drift-review.md)
