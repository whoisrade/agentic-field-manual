# Weekly Operations Checklist

> **Use when:** Every Monday morning, or at your regular ops review.
>
> **Time:** 30 minutes.
>
> **After completing:** You will have caught drift before it becomes a crisis.

---

Copy this checklist weekly. Fill in the values. Flag anything in Warning or Critical.

---

| Field | Value |
|-------|-------|
| Week of | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Reviewed by | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Review date | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## 1. Cost Health

| Metric | This Week | Last Week | Status |
|--------|-----------|-----------|--------|
| Cost per outcome | $&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | $&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Total inference cost | $&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | $&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Hidden recompute ratio | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

**Status Guide:**
- Healthy: Stable or declining
- Warning: >10% increase
- Critical: >20% increase

**Query to run:**

```sql
SELECT
  DATE_TRUNC('week', created_at) as week,
  SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome,
  SUM(cost_usd) as total_cost,
  ROUND(100.0 * SUM(CASE WHEN trigger_type IN ('undo','retry','auto_save') THEN 1 ELSE 0 END) / COUNT(*), 1) as hidden_ratio
FROM inference_events
WHERE created_at > NOW() - INTERVAL '14 days'
GROUP BY 1 ORDER BY 1;
```

| Notes |
|-------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp; |
| &emsp; |

---

## 2. Quality Health

| Metric | This Week | Last Week | Status |
|--------|-----------|-----------|--------|
| Eval pass rate | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| User acceptance rate | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Regeneration rate | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

**Status Guide:**
- Healthy: >90% eval pass, <15% regeneration
- Warning: 85-90% eval pass, 15-25% regeneration
- Critical: <85% eval pass, >25% regeneration

| Notes |
|-------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp; |
| &emsp; |

---

## 3. Reliability Health

| Metric | This Week | Last Week | Status |
|--------|-----------|-----------|--------|
| Tool success rate | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;% | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Circuit breaker trips | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| p95 latency | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;ms | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;ms | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

**Status Guide:**
- Healthy: >98% tool success, 0 circuit breaker trips
- Warning: 95-98% tool success, 1-2 trips
- Critical: <95% tool success, >2 trips

**Query to run:**

```sql
SELECT
  tool_name,
  COUNT(*) as calls,
  ROUND(100.0 * SUM(CASE WHEN success THEN 1 ELSE 0 END) / COUNT(*), 1) as success_rate
FROM tool_calls
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1 ORDER BY success_rate ASC;
```

| Notes |
|-------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp; |
| &emsp; |

---

## 4. Traceability Health

| Check | Status |
|-------|--------|
| Random output explainable in <10 min? | [ ] Yes [ ] No |
| All outputs have trace_id? | [ ] Yes [ ] No |
| Model/prompt versions logged? | [ ] Yes [ ] No |

**If any "No":** See [Legibility Loss](../01-failure-modes/legibility-loss.md)

| Notes |
|-------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp; |
| &emsp; |

---

## 5. Upcoming Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp; | &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; | &emsp; |

---

## 6. Action Items from Last Week

| Item | Owner | Status |
|------|-------|--------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; |

---

## 7. Action Items for This Week

| Item | Owner | Due |
|------|-------|-----|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; |
| &emsp; | &emsp; | &emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## Summary

| Field | Value |
|-------|-------|
| Overall Status | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Key Concerns | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Escalations Needed | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## Quick Reference Thresholds

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Cost per outcome trend | Stable | >10% rise | >20% rise |
| Hidden recompute ratio | <20% | 20-40% | >40% |
| Eval pass rate | >90% | 85-90% | <85% |
| Tool success rate | >98% | 95-98% | <95% |
| p95 latency | <2s | 2-5s | >5s |
| Time to explain output | <10 min | 10-60 min | >1 hour |
