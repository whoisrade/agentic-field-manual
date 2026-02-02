# Capacity Planning

**How to forecast inference demand for bursty AI traffic.**

AI traffic is user-driven and bursty. Traditional capacity planning underestimates variance. You need a different model.

---

## Planning Inputs

| Input | What to Measure |
|-------|-----------------|
| Cost per successful outcome | Your unit economics anchor |
| Peak concurrent sessions | Worst-case simultaneous load |
| Recompute multipliers | Hidden work per visible output |
| Latency targets per outcome | SLOs that affect user behavior |

---

## The Problem

Teams plan for average load:
- "We average 1000 requests/hour"
- "Provision for 1500 to be safe"

Then reality hits:
- Peak is 4x average
- A viral moment is 10x average
- SLOs break at 2x average

And now you're scrambling.

---

## The Model

**1. Measure actual distribution, not just average**

```sql
SELECT
  DATE_TRUNC('hour', created_at) as hour,
  COUNT(*) as requests,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY requests_per_minute) as p95_load,
  MAX(requests_per_minute) as peak_load
FROM request_logs
GROUP BY 1;
```

**2. Calculate recompute multiplier**

```
recompute_multiplier = total_inference_calls / successful_outputs
```

Your actual load is `visible_requests × recompute_multiplier`.

**3. Model peak scenarios**

| Scenario | Multiplier | Duration |
|----------|-----------|----------|
| Normal peak | 2x average | Hours |
| Product launch | 5x average | Days |
| Viral moment | 10x average | Hours |
| Incident recovery | 3x average | Hours |

**4. Set latency-based capacity**

What load level breaks your SLOs?

```sql
SELECT
  CASE
    WHEN concurrent_sessions < 100 THEN '<100'
    WHEN concurrent_sessions < 500 THEN '100-500'
    ELSE '500+'
  END as load_bucket,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY latency_ms) as p95_latency
FROM request_logs
GROUP BY 1;
```

Provision to stay under SLO at your target peak.

---

## Capacity Formula

```
required_capacity =
  (peak_requests_per_second × recompute_multiplier)
  / throughput_per_gpu
  × (1 + headroom_buffer)
```

Where:
- `peak_requests_per_second` = your 99th percentile or planned peak
- `recompute_multiplier` = hidden work factor
- `throughput_per_gpu` = benchmarked for your model/hardware
- `headroom_buffer` = typically 20-30%

---

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|-------------|-------------|
| Planning for average | Peaks break you |
| Ignoring recompute | Actual load is higher than visible |
| Single-point provisioning | No room for variance |
| Ignoring latency constraints | Capacity without SLOs is meaningless |

---

## The Litmus Test

> Can you simulate 5-10x spikes without breaking SLOs?

If you haven't tested it, you don't know. And the first time you find out shouldn't be in production.

---

> *"AI traffic is bursty. Plan for peaks, not averages."*
