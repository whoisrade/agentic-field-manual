# Cost Spike Runbook

> **Use when:** Inference costs have spiked unexpectedly (>20% above baseline).
>
> **Time:** 30-60 minutes for initial triage.
>
> **Outcome:** Root cause identified, immediate mitigation applied.

---

## Step 1: Confirm the Spike (5 min)

Run this query to confirm the spike is real:

```sql
SELECT 
  DATE_TRUNC('hour', created_at) as hour,
  COUNT(*) as requests,
  SUM(cost_usd) as total_cost,
  AVG(cost_usd) as avg_cost_per_request
FROM inference_events
WHERE created_at > NOW() - INTERVAL '48 hours'
GROUP BY 1
ORDER BY 1;
```

**Check:**
- [ ] Cost increase is sustained (not a 1-hour blip)
- [ ] Time when spike started is identified

**Write down:** Spike started at `____________` (timestamp)

---

## Step 2: Rule Out Traffic Increase (5 min)

```sql
SELECT 
  DATE_TRUNC('hour', created_at) as hour,
  COUNT(*) as requests,
  COUNT(DISTINCT user_id) as unique_users,
  SUM(cost_usd) as total_cost,
  SUM(cost_usd) / COUNT(*) as cost_per_request
FROM inference_events
WHERE created_at > NOW() - INTERVAL '48 hours'
GROUP BY 1
ORDER BY 1;
```

**If traffic is flat but cost is up:** Problem is cost per request. Go to Step 3.

**If traffic spiked:** Check for:
- Marketing campaign
- Viral content
- Bot traffic (check user agent patterns)
- Attack (check rate limiting)

---

## Step 3: Check Hidden Recompute (10 min)

```sql
SELECT 
  DATE_TRUNC('hour', created_at) as hour,
  trigger_type,
  COUNT(*) as count,
  SUM(cost_usd) as cost
FROM inference_events
WHERE created_at > NOW() - INTERVAL '48 hours'
GROUP BY 1, 2
ORDER BY 1, 2;
```

**Calculate hidden recompute ratio:**

```sql
SELECT 
  DATE_TRUNC('day', created_at) as day,
  COUNT(*) as total,
  SUM(CASE WHEN trigger_type IN ('undo', 'retry', 'auto_save') THEN 1 ELSE 0 END) as hidden,
  SUM(CASE WHEN trigger_type IN ('undo', 'retry', 'auto_save') THEN 1 ELSE 0 END)::float / COUNT(*) as hidden_ratio
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 1;
```

**If hidden ratio increased:**
- [ ] Check for recent UX changes (undo button, auto-save)
- [ ] Check for retry loop bugs
- [ ] Check auto-save frequency settings

---

## Step 4: Check Token Usage (10 min)

```sql
SELECT 
  DATE_TRUNC('hour', created_at) as hour,
  AVG(input_tokens) as avg_input,
  AVG(output_tokens) as avg_output,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY input_tokens) as p95_input,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY output_tokens) as p95_output
FROM inference_events
WHERE created_at > NOW() - INTERVAL '48 hours'
GROUP BY 1
ORDER BY 1;
```

**If input tokens increased:**
- [ ] Check context window management
- [ ] Check for context being appended, not replaced
- [ ] Check prompt template changes

**If output tokens increased:**
- [ ] Check if model version changed
- [ ] Check if temperature/sampling changed
- [ ] Check if output format requirements changed

---

## Step 5: Check Feature Attribution (10 min)

```sql
SELECT 
  DATE_TRUNC('day', created_at) as day,
  feature,
  COUNT(*) as requests,
  SUM(cost_usd) as total_cost,
  SUM(cost_usd) / COUNT(*) as cost_per_request
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1, 2
ORDER BY 1, total_cost DESC;
```

**If one feature is driving costs:**
- [ ] Check that feature for recent changes
- [ ] Check that feature's retry logic
- [ ] Check that feature's token usage

---

## Step 6: Check Tool Call Failures (5 min)

```sql
SELECT 
  tool_name,
  COUNT(*) as total_calls,
  SUM(CASE WHEN success = false THEN 1 ELSE 0 END) as failures,
  SUM(CASE WHEN success = false THEN 1 ELSE 0 END)::float / COUNT(*) as failure_rate,
  AVG(retries) as avg_retries
FROM tool_calls
WHERE created_at > NOW() - INTERVAL '48 hours'
GROUP BY 1
ORDER BY failures DESC;
```

**If a tool has high failure rate:**
- [ ] Check if that tool's API is having issues
- [ ] Check if retry logic is causing cost multiplication
- [ ] Consider circuit breaker activation

---

## Step 7: Immediate Mitigation

Based on findings, apply one or more:

### If hidden recompute
```python
# Reduce auto-save frequency
AUTO_SAVE_INTERVAL_MS = 30000  # Was 5000

# Add rate limiting on undo
UNDO_RATE_LIMIT = "3/minute"
```

### If context bloat
```python
# Truncate context to last N messages
MAX_CONTEXT_MESSAGES = 10

# Or implement sliding window
context = messages[-MAX_CONTEXT_MESSAGES:]
```

### If tool retries
```python
# Reduce max retries
MAX_TOOL_RETRIES = 2  # Was 5

# Add circuit breaker
@circuit(failure_threshold=3, recovery_timeout=60)
async def call_tool(...):
    ...
```

### If specific feature
```python
# Feature flag to disable/throttle
if FEATURE_FLAGS.get("expensive_feature_throttle"):
    await rate_limit(user_id, "expensive_feature", limit=10, period="hour")
```

---

## Step 8: Document and Monitor

- [ ] Record root cause in incident log
- [ ] Set up alert for this condition
- [ ] Schedule follow-up to verify fix

**Root cause:** 

**Mitigation applied:**

**Alert created:** [ ] Yes [ ] No

**Follow-up scheduled for:** `____________`

---

## Common Root Causes Quick Reference

| Symptom | Likely Cause | Quick Fix |
|---------|--------------|-----------|
| High undo/retry ratio | UX encouraging retries | Rate limit, add confirmation |
| Rising input tokens | Context bloat | Truncate, summarize |
| Rising output tokens | Model change or prompt | Rollback, constrain |
| One feature dominates | Feature bug or abuse | Throttle, investigate |
| Tool retry spike | External API issues | Circuit breaker, fallback |

---

## Escalation

If costs are still rising after mitigation:

1. **Immediate:** Enable cost cap if not already
2. **Within 1 hour:** Alert engineering leadership
3. **If critical:** Consider temporary feature disable

**Cost cap query (if you have one):**

```sql
UPDATE feature_flags 
SET enabled = false 
WHERE feature = 'expensive_feature'
AND (SELECT SUM(cost_usd) FROM inference_events WHERE created_at > NOW() - INTERVAL '1 hour') > 1000;
```
