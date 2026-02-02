# Recompute Dashboard Queries

SQL queries for monitoring AI system economics. Adjust table/column names to match your schema.

These queries assume you're using the schema from [traceability-postgres-schema.sql](traceability-postgres-schema.sql).

---

## Core Metrics

### 1. Cost per Successful Outcome (Daily)

The most important metric. If this is rising while traffic is flat, you have hidden recompute.

```sql
SELECT
    DATE_TRUNC('day', created_at) as day,
    SUM(inference_cost_usd) as total_cost,
    COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END) as successful_outputs,
    SUM(inference_cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY 1
ORDER BY 1;
```

**What to look for:**
- Rising trend See: hidden recompute
- Spikes See: investigate that day's trigger breakdown
- Stable See: healthy system

---

### 2. Hidden Recompute Ratio

What percentage of your compute is invisible to users?

```sql
SELECT
    SUM(CASE WHEN trigger_type = 'user_explicit' THEN 1 ELSE 0 END) as explicit_computes,
    SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END) as hidden_computes,
    SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END)::float
        / NULLIF(COUNT(*), 0) as hidden_ratio
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days';
```

**Thresholds:**
- < 15% See: Healthy
- 15-25% See: Monitor
- > 25% See: Investigate immediately

---

### 3. Cost Breakdown by Trigger Type

Find which user actions are driving cost.

```sql
SELECT
    trigger_type,
    COUNT(*) as event_count,
    SUM(inference_cost_usd) as total_cost,
    AVG(inference_cost_usd) as avg_cost,
    SUM(inference_cost_usd) / SUM(SUM(inference_cost_usd)) OVER () * 100 as pct_of_total
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY total_cost DESC;
```

**Action items:**
- If `undo` or `auto_save` is top 3 See: fix control surface
- If `retry` is high See: investigate tool reliability
- If `user_explicit` dominates See: healthy system

---

### 4. Recompute per User Action

Which user actions cost the most?

```sql
SELECT
    user_action,
    COUNT(*) as action_count,
    COUNT(DISTINCT result_id) as unique_outputs,
    COUNT(*)::float / COUNT(DISTINCT result_id) as compute_per_output,
    SUM(inference_cost_usd) as total_cost,
    SUM(inference_cost_usd) / COUNT(DISTINCT result_id) as cost_per_output
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY cost_per_output DESC;
```

**Red flags:**
- `compute_per_output` > 1.5 See: users are regenerating frequently
- High cost actions that aren't gated See: add confirmation dialogs

---

## Tool Reliability

### 5. Tool Success Rate

Which tools are failing?

```sql
SELECT
    tool_name,
    COUNT(*) as total_calls,
    SUM(CASE WHEN success THEN 1 ELSE 0 END) as successful,
    (SUM(CASE WHEN success THEN 1 ELSE 0 END)::float / COUNT(*) * 100)::int as success_rate_pct,
    SUM(retry_count) as total_retries,
    AVG(retry_count) as avg_retries_per_call
FROM tool_calls
WHERE called_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY success_rate_pct ASC;
```

**Action items:**
- Success rate < 95% See: add circuit breaker
- High avg_retries See: investigate root cause

---

### 6. Tool Latency Distribution

Where is latency hiding?

```sql
SELECT
    tool_name,
    COUNT(*) as calls,
    AVG(latency_ms)::int as avg_latency,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY latency_ms)::int as p50,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms)::int as p95,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY latency_ms)::int as p99,
    MAX(latency_ms) as max_latency
FROM tool_calls
WHERE called_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY p95 DESC;
```

**Red flags:**
- p95 > 5x avg See: tail latency problem
- p99 > 10s See: needs timeout/fallback

---

## Trend Analysis

### 7. Week-over-Week Cost Comparison

Is cost per outcome improving or degrading?

```sql
WITH weekly AS (
    SELECT
        DATE_TRUNC('week', created_at) as week,
        SUM(inference_cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome
    FROM decision_envelopes
    WHERE created_at > NOW() - INTERVAL '8 weeks'
    GROUP BY 1
)
SELECT
    week,
    cost_per_outcome,
    LAG(cost_per_outcome) OVER (ORDER BY week) as prev_week,
    ((cost_per_outcome - LAG(cost_per_outcome) OVER (ORDER BY week))
        / NULLIF(LAG(cost_per_outcome) OVER (ORDER BY week), 0) * 100)::int as pct_change
FROM weekly
ORDER BY week;
```

---

### 8. Model Version Cost Comparison

Did the new model version improve economics?

```sql
SELECT
    model_version,
    COUNT(*) as decisions,
    AVG(inference_cost_usd) as avg_cost,
    AVG(input_tokens) as avg_input_tokens,
    AVG(output_tokens) as avg_output_tokens,
    AVG(total_latency_ms) as avg_latency
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '14 days'
GROUP BY 1
ORDER BY COUNT(*) DESC;
```

---

## Alerting Queries

### 9. Real-time Cost Spike Detection

Run every 5 minutes. Alert if cost per outcome spikes.

```sql
WITH recent AS (
    SELECT
        SUM(inference_cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome
    FROM decision_envelopes
    WHERE created_at > NOW() - INTERVAL '1 hour'
),
baseline AS (
    SELECT
        SUM(inference_cost_usd) / NULLIF(COUNT(DISTINCT CASE WHEN state = 'committed' THEN result_id END), 0) as cost_per_outcome
    FROM decision_envelopes
    WHERE created_at BETWEEN NOW() - INTERVAL '7 days' AND NOW() - INTERVAL '1 hour'
)
SELECT
    recent.cost_per_outcome as current_cost,
    baseline.cost_per_outcome as baseline_cost,
    ((recent.cost_per_outcome - baseline.cost_per_outcome) / NULLIF(baseline.cost_per_outcome, 0) * 100)::int as pct_deviation,
    CASE
        WHEN recent.cost_per_outcome > baseline.cost_per_outcome * 1.25 THEN 'ALERT'
        WHEN recent.cost_per_outcome > baseline.cost_per_outcome * 1.10 THEN 'WARNING'
        ELSE 'OK'
    END as status
FROM recent, baseline;
```

---

### 10. Hidden Recompute Spike

Alert if hidden recompute ratio jumps.

```sql
WITH current_hour AS (
    SELECT
        SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry') THEN 1 ELSE 0 END)::float / NULLIF(COUNT(*), 0) as hidden_ratio
    FROM decision_envelopes
    WHERE created_at > NOW() - INTERVAL '1 hour'
),
baseline AS (
    SELECT
        SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry') THEN 1 ELSE 0 END)::float / NULLIF(COUNT(*), 0) as hidden_ratio
    FROM decision_envelopes
    WHERE created_at BETWEEN NOW() - INTERVAL '7 days' AND NOW() - INTERVAL '1 hour'
)
SELECT
    current_hour.hidden_ratio as current_ratio,
    baseline.hidden_ratio as baseline_ratio,
    CASE
        WHEN current_hour.hidden_ratio > 0.30 THEN 'ALERT'
        WHEN current_hour.hidden_ratio > baseline.hidden_ratio * 1.5 THEN 'WARNING'
        ELSE 'OK'
    END as status
FROM current_hour, baseline;
```

---

## Dashboard Recommendations

Build a dashboard with:

1. **Cost per Outcome** (line chart, 30-day trend)
2. **Hidden Recompute Ratio** (single stat, with threshold coloring)
3. **Cost by Trigger Type** (pie chart)
4. **Top 5 Expensive User Actions** (table)
5. **Tool Success Rates** (bar chart)
6. **Tool P95 Latency** (bar chart)
7. **Week-over-Week Cost Change** (single stat)

Update at least hourly. Alert on:
- Cost per outcome > 120% of 7-day baseline
- Hidden recompute ratio > 25%
- Any tool success rate < 90%
