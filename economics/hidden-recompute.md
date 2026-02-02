# Hidden Recompute

**Work the system repeats without user awareness.**

Hidden recompute is the primary cause of margin erosion in AI systems. It's compute that happens but doesn't create value.

---

## Sources

| Source | What Happens |
|--------|-------------|
| Silent retries | Failed calls retry automatically, invisibly |
| Context invalidation | User actions force full re-embedding |
| Partial failures | Tool chain restarts from scratch |
| Auto-saves | Background saves trigger full pipeline |
| Undo flows | Restoring state recomputes instead of caching |

---

## Detection

**1. Compare total compute to successful outcomes**

```sql
SELECT
  COUNT(*) as total_inference_calls,
  COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END) as successful_outputs,
  COUNT(*)::float / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END), 0) as ratio
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days';
```

If ratio > 1.3, you have hidden recompute.

**2. Track recompute per feature, not per request**

Break down by trigger type:
```sql
SELECT
  trigger_type,
  COUNT(*) as count,
  SUM(cost_usd) as total_cost
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY total_cost DESC;
```

**3. Inspect retry cascades**

Look for tool calls with retry_count > 0:
```sql
SELECT
  tool_name,
  AVG(retry_count) as avg_retries,
  SUM(retry_count * cost_per_call) as retry_cost
FROM tool_calls
GROUP BY 1
HAVING AVG(retry_count) > 0.5
ORDER BY retry_cost DESC;
```

**4. Identify tool calls with >1x repeats per output**

If you're calling the same tool multiple times for one output, that's recompute.

---

## Mitigation

**Cache stable context**

If context hasn't changed, don't re-embed:
```python
if context_hash == cached_hash:
    return cached_embedding
```

**Gate expensive retries**

Don't retry automatically. Make it explicit:
```python
if retry_count >= max_retries:
    return fallback_or_escalate()
```

**Simplify state transitions**

The more complex your state machine, the more opportunities for recompute. Fewer states = fewer triggers.

**Split preview vs commit compute**

Preview can use cached, lower-fidelity results. Commit runs the full pipeline. Users get fast feedback without burning margin.

---

## The Math

Hidden recompute cost = `total_inference_cost - (successful_outputs × cost_per_successful_output)`

If this number is growing faster than your revenue, you're losing.

---

## The Litmus Test

> Can you explain why total compute is higher than successful outcomes?

If you can't, hidden recompute is already eroding margin.

---

> *"The most expensive compute is the compute that creates no value."*
