# Metrics Reference

> **Read this when:** You need to calculate any metric mentioned in the manual, or setting up observability.
>
> **Time:** Reference as needed. Use Ctrl+F to find specific metrics.
>
> **After reading:** You will have formulas and queries for every metric in this manual.
>
> **Prerequisites:** Structured logging and SQL-compatible data store.

---

How to calculate and track every metric mentioned in this manual.

This document provides the formulas, queries, and instrumentation patterns for each metric. All examples are technology-agnostic but assume you have structured logging and a SQL-compatible data store.

---

## Cost Metrics

### Cost per Successful Outcome

The most important metric. Not cost per request. Cost per outcome that delivered value.

**Formula:**
```
cost_per_outcome = (inference_cost + orchestration_overhead + retry_cost) / successful_outputs
```

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  SUM(inference_cost_usd) as inference_cost,
  SUM(orchestration_cost_usd) as orchestration_cost,
  SUM(CASE WHEN is_retry THEN cost_usd ELSE 0 END) as retry_cost,
  COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END) as successful_outputs,
  (SUM(inference_cost_usd) + SUM(orchestration_cost_usd) + SUM(CASE WHEN is_retry THEN cost_usd ELSE 0 END))
    / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN output_id END), 0) as cost_per_outcome
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY 1
ORDER BY 1;
```

**Instrumentation:**
- Log `cost_usd` with every inference call
- Tag each call as `is_retry` or not
- Track `state` (draft/committed/rejected) for every output

**Thresholds:**
| Status | Trend |
|--------|-------|
| Healthy | Stable or declining |
| Warning | Rising under 10% MoM |
| Critical | Rising over 10% MoM |

---

### Hidden Recompute Ratio

Percentage of compute that happens without creating visible user value.

**Formula:**
```
hidden_recompute_ratio = hidden_computes / total_computes
```

Where hidden triggers include: `undo`, `auto_save`, `retry`, `background`

**SQL:**
```sql
SELECT
  SUM(CASE WHEN trigger_type = 'user_explicit' THEN 1 ELSE 0 END) as explicit_computes,
  SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END) as hidden_computes,
  SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END)::float
    / NULLIF(COUNT(*), 0) as hidden_ratio
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days';
```

**Instrumentation:**
- Tag every inference call with `trigger_type`:
  - `user_explicit` - User clicked generate/submit
  - `user_edit` - User edited and triggered recompute
  - `undo` - Undo action triggered recompute
  - `auto_save` - Auto-save triggered pipeline
  - `retry` - Automatic retry after failure
  - `background` - Background job or scheduled task

**Thresholds:**
| Status | Ratio |
|--------|-------|
| Healthy | Under 20% |
| Warning | 20-40% |
| Critical | Over 40% |

---

### Cost by Trigger Type

Breakdown of where cost is coming from.

**SQL:**
```sql
SELECT
  trigger_type,
  COUNT(*) as event_count,
  SUM(cost_usd) as total_cost,
  AVG(cost_usd) as avg_cost,
  SUM(cost_usd) / SUM(SUM(cost_usd)) OVER () as pct_of_total
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY total_cost DESC;
```

**Expected Distribution:**
| Trigger Type | Expected % | Investigate If |
|--------------|------------|----------------|
| user_explicit | 40-60% | Below 30% |
| user_edit | 10-20% | Above 30% |
| undo | Under 10% | Above 15% |
| auto_save | Under 10% | Above 15% |
| retry | Under 5% | Above 10% |
| background | Under 10% | Above 20% |

---

## Latency Metrics

### Latency Percentiles (p50, p95, p99)

**What they measure:**
- p50 (median): Typical user experience
- p95: Experience for 1 in 20 users
- p99: Worst-case for 1 in 100 users

**SQL:**
```sql
SELECT
  DATE_TRUNC('hour', created_at) as hour,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY latency_ms) as p50,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) as p95,
  PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY latency_ms) as p99
FROM inference_events
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY 1;
```

**Instrumentation:**
```python
import time

start = time.perf_counter()
result = await call_inference()
latency_ms = (time.perf_counter() - start) * 1000

log_event({
    "trace_id": context.trace_id,
    "latency_ms": latency_ms,
    "endpoint": "generate",
    "model": model_version,
})
```

**Breakdown by Component:**

For debugging, track latency per component:

```sql
SELECT
  component,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY latency_ms) as p50,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) as p95
FROM component_latencies
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY p95 DESC;
```

Components to track:
- `inference` - Model API call time
- `embedding` - Embedding generation
- `tool_call` - External tool invocations
- `orchestration` - Routing and coordination overhead
- `db_read` - Database reads
- `db_write` - Database writes

---

### Retry Rate

Percentage of requests that required retry.

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  COUNT(*) as total_requests,
  SUM(CASE WHEN retry_count > 0 THEN 1 ELSE 0 END) as requests_with_retry,
  SUM(CASE WHEN retry_count > 0 THEN 1 ELSE 0 END)::float / COUNT(*) as retry_rate,
  AVG(retry_count) as avg_retries_per_request
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Under 5% |
| Warning | 5-15% |
| Critical | Over 15% |

---

### Timeout Rate

Percentage of requests that timed out.

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  COUNT(*) as total_requests,
  SUM(CASE WHEN status = 'timeout' THEN 1 ELSE 0 END) as timeouts,
  SUM(CASE WHEN status = 'timeout' THEN 1 ELSE 0 END)::float / COUNT(*) as timeout_rate
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Under 2% |
| Warning | 2-5% |
| Critical | Over 5% |

---

## Quality Metrics

### Eval Pass Rate

Percentage of outputs passing evaluation criteria.

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  eval_type,
  COUNT(*) as total_evals,
  SUM(CASE WHEN passed THEN 1 ELSE 0 END) as passed,
  SUM(CASE WHEN passed THEN 1 ELSE 0 END)::float / COUNT(*) as pass_rate
FROM eval_results
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY 1, 2
ORDER BY 1, 2;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Over 90% |
| Warning | 85-90% |
| Critical | Under 85% |

---

### User Regenerate Rate

How often users reject AI output and request regeneration.

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  COUNT(DISTINCT session_id) as sessions,
  SUM(CASE WHEN action = 'regenerate' THEN 1 ELSE 0 END) as regenerates,
  SUM(CASE WHEN action = 'regenerate' THEN 1 ELSE 0 END)::float 
    / NULLIF(SUM(CASE WHEN action = 'generate' THEN 1 ELSE 0 END), 0) as regenerate_rate
FROM user_actions
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Under 20% |
| Warning | 20-30% |
| Critical | Over 30% |

---

### Escalation Rate

How often outputs require human review.

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  COUNT(*) as total_outputs,
  SUM(CASE WHEN escalated THEN 1 ELSE 0 END) as escalated,
  SUM(CASE WHEN escalated THEN 1 ELSE 0 END)::float / COUNT(*) as escalation_rate
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Under 5% |
| Warning | 5-10% |
| Critical | Over 10% |

---

## Reliability Metrics

### Task Completion Rate

For orchestrated workflows, percentage that complete successfully.

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  COUNT(*) as total_tasks,
  SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
  SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END)::float / COUNT(*) as completion_rate
FROM orchestration_tasks
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Over 95% |
| Warning | 90-95% |
| Critical | Under 90% |

---

### Tool Success Rate

For external tool calls, percentage that succeed.

**SQL:**
```sql
SELECT
  tool_name,
  COUNT(*) as total_calls,
  SUM(CASE WHEN success THEN 1 ELSE 0 END) as successful,
  SUM(CASE WHEN success THEN 1 ELSE 0 END)::float / COUNT(*) as success_rate,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) as p95_latency
FROM tool_calls
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY success_rate ASC;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Over 98% |
| Warning | 95-98% |
| Critical | Under 95% |

---

### Circuit Breaker Status

Track when circuit breakers trip.

**SQL:**
```sql
SELECT
  DATE_TRUNC('hour', created_at) as hour,
  service_name,
  COUNT(*) as trip_count,
  MAX(duration_seconds) as longest_open
FROM circuit_breaker_events
WHERE event_type = 'opened'
  AND created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1, 2
ORDER BY 1, 2;
```

**Alert on:** Any circuit breaker trip on critical path.

---

## Traceability Metrics

### Decision Envelope Completeness

Percentage of outputs with complete provenance.

**SQL:**
```sql
SELECT
  DATE_TRUNC('day', created_at) as day,
  COUNT(*) as total_outputs,
  SUM(CASE WHEN 
    trace_id IS NOT NULL 
    AND model_version IS NOT NULL 
    AND prompt_version IS NOT NULL 
    AND context_hash IS NOT NULL
  THEN 1 ELSE 0 END) as complete_envelopes,
  SUM(CASE WHEN 
    trace_id IS NOT NULL 
    AND model_version IS NOT NULL 
    AND prompt_version IS NOT NULL 
    AND context_hash IS NOT NULL
  THEN 1 ELSE 0 END)::float / COUNT(*) as completeness_rate
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Over 95% |
| Warning | 80-95% |
| Critical | Under 80% |

---

### Time to Reconstruct

How long it takes to explain any output.

This is measured manually during audits or incident response. Track it:

```sql
INSERT INTO reconstruction_tests (
  output_id,
  tested_at,
  reconstruction_time_minutes,
  successful,
  missing_components,
  tester
) VALUES (...);
```

**Thresholds:**
| Status | Time |
|--------|------|
| Healthy | Under 10 minutes |
| Warning | 10-60 minutes |
| Critical | Over 1 hour |

---

## Cache Metrics

### Cache Hit Rate

**SQL:**
```sql
SELECT
  DATE_TRUNC('hour', created_at) as hour,
  cache_name,
  SUM(CASE WHEN hit THEN 1 ELSE 0 END) as hits,
  SUM(CASE WHEN NOT hit THEN 1 ELSE 0 END) as misses,
  SUM(CASE WHEN hit THEN 1 ELSE 0 END)::float / COUNT(*) as hit_rate
FROM cache_events
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1, 2
ORDER BY 1, 2;
```

**Thresholds:**
| Status | Rate |
|--------|------|
| Healthy | Over 70% |
| Warning | 50-70% |
| Critical | Under 50% |

---

## Instrumentation Patterns

### Minimum Viable Logging

Every inference call should log:

```python
log_entry = {
    # Identity
    "trace_id": str,
    "step_id": str,
    "parent_step_id": str | None,
    
    # What happened
    "action": str,
    "trigger_type": str,  # user_explicit, undo, retry, etc.
    "model_version": str,
    "prompt_version": str,
    
    # Cost
    "input_tokens": int,
    "output_tokens": int,
    "cost_usd": float,
    
    # Timing
    "latency_ms": float,
    "timestamp": str,  # ISO 8601
    
    # Status
    "status": str,  # success, failed, timeout
    "retry_count": int,
    "is_retry": bool,
}
```

### Tool Call Logging

```python
tool_log = {
    "trace_id": str,
    "tool_name": str,
    "input_hash": str,
    "output_hash": str,
    "latency_ms": float,
    "success": bool,
    "error": str | None,
    "retry_count": int,
}
```

### User Action Logging

```python
action_log = {
    "trace_id": str,
    "session_id": str,
    "user_id": str,
    "action": str,  # generate, regenerate, undo, commit, etc.
    "timestamp": str,
}
```

---

## Dashboard Minimum

Build a dashboard with these panels:

1. **Cost per outcome trend** - Daily, 30-day view
2. **Hidden recompute ratio** - Weekly trend
3. **Cost breakdown by trigger type** - Pie chart
4. **Latency percentiles** - p50, p95, p99 over time
5. **Retry rate by endpoint** - Table
6. **Tool success rate** - Table
7. **Eval pass rate trend** - Daily
8. **Circuit breaker trips** - Event timeline

**Alert thresholds:** Set alerts for any metric crossing from Healthy to Warning.
