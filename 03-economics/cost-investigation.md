# Cost Investigation

> **Read this when:** Costs are rising but traffic is flat, or CFO is asking questions.
>
> **Time:** 1-2 hours to complete the full investigation.
>
> **After reading:** You will have identified the cost driver and have specific fixes to implement.
>
> **Prerequisites:** Access to your inference logs and cost data.

---

Step-by-step process for diagnosing why AI system costs are rising.

Use this when costs are increasing but traffic is flat, or when you need to understand cost per outcome before a board meeting.

---

## Step 1: Establish Baseline

Before investigating, establish what "normal" looks like.

### Pull These Metrics

| Metric | 30 days ago | 7 days ago | Today |
|--------|-------------|------------|-------|
| Daily inference cost | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Daily successful outcomes | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Cost per outcome | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Total API calls | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Unique active users | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

### Calculate Baseline Ratios

```
recompute_ratio = total_api_calls / successful_outcomes
cost_per_user = total_daily_cost / unique_active_users
```

If recompute_ratio is above 3, you have significant hidden compute.

---

## Step 2: Identify Cost Sources

### Query: Cost by Trigger Type

<details>
<summary><strong>SQL Example</strong></summary>

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

</details>

### Expected Trigger Types

| Trigger Type | Expected % | Investigate If |
|--------------|------------|----------------|
| user_generate | 40-60% | Below 30% |
| user_edit | 10-20% | Above 30% |
| user_undo | Under 10% | Above 15% |
| auto_save | Under 10% | Above 15% |
| retry | Under 5% | Above 10% |
| background | Under 10% | Above 20% |

### Document Findings

| Trigger Type | Actual % | Expected % | Investigation Needed? |
|--------------|----------|------------|-----------------------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## Step 3: Trace Hidden Recompute

Hidden recompute is compute that happens without creating visible user value.

### Common Sources

| Source | How to Detect | Typical Fix |
|--------|---------------|-------------|
| Undo loops | High undo trigger %, session recordings | Granular rejection, cached context |
| Auto-save triggers | High auto_save trigger %, correlation with edits | Debounce, smart dirty detection |
| Retry storms | High retry %, circuit breaker trips | Retry limits, exponential backoff |
| Context invalidation | Re-embedding after minor changes | Incremental context updates |
| Speculative execution | Compute before user confirms | Defer until commitment |

### Query: Hidden Recompute Ratio

<details>
<summary><strong>SQL Example</strong></summary>

```sql
SELECT
  SUM(CASE WHEN trigger_type = 'user_explicit' THEN 1 ELSE 0 END) as explicit_computes,
  SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END) as hidden_computes,
  SUM(CASE WHEN trigger_type IN ('undo', 'auto_save', 'retry', 'background') THEN 1 ELSE 0 END)::float
    / NULLIF(COUNT(*), 0) as hidden_ratio
FROM inference_events
WHERE created_at > NOW() - INTERVAL '7 days';
```

</details>

---

## Step 4: Analyze User Behavior

Cost problems often start as UX problems.

### Session Recording Analysis

If you have session recordings (Clarity, FullStory, etc.), watch 10-20 sessions focused on:

- How often do users hit regenerate?
- What triggers undo behavior?
- Where do users hesitate or retry?

### Query: Cost per User Action

<details>
<summary><strong>SQL Example</strong></summary>

```sql
SELECT
  user_action_type,
  COUNT(DISTINCT output_id) as outputs,
  SUM(cost_usd) as total_cost,
  SUM(cost_usd) / COUNT(DISTINCT output_id) as cost_per_action
FROM decision_envelopes
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY cost_per_action DESC;
```

</details>

### Document Findings

| User Action | Frequency | Cost per Action | Issue Identified |
|-------------|-----------|-----------------|------------------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## Step 5: Check for Context Waste

Large parts of AI context may be identical across users but recomputed every time.

### Questions to Answer

- [ ] What percentage of the prompt is static (system prompt, tool definitions)?
- [ ] What percentage varies per user vs per session vs per request?
- [ ] Are embeddings recomputed for unchanged content?

### Common Fixes

| Waste Type | Fix | Impact |
|------------|-----|--------|
| Static prompt recompute | Prompt caching (if provider supports) | 20-50% reduction |
| Repeated embeddings | Embedding cache with TTL | 30-60% reduction |
| Full context on minor edits | Incremental context updates | 40-70% reduction |

---

## Step 6: Model at Scale

Before concluding, model what happens at 10x usage.

### Scaling Analysis

| Metric | Current | At 10x | Concern? |
|--------|---------|--------|----------|
| Daily cost | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Cost per outcome | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Hidden recompute cost | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

### Key Question

Does cost scale linearly, sublinearly, or superlinearly?

| Scaling | What It Means |
|---------|---------------|
| Sublinear (cost < 10x) | You have scale effects (caching, shared compute) |
| Linear (cost = 10x) | Acceptable, no hidden multipliers |
| Superlinear (cost > 10x) | Hidden recompute or coordination overhead growing faster than usage |

---

## Step 7: Prioritize Fixes

Based on your investigation, prioritize fixes by impact and effort.

| Fix | Cost Reduction | Effort | Priority |
|-----|----------------|--------|----------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

### Priority Framework

| Priority | Criteria |
|----------|----------|
| P0 | Over 20% of cost, under 1 week effort |
| P1 | Over 10% of cost, under 2 weeks effort |
| P2 | Under 10% of cost or over 2 weeks effort |

---

## Output Template

Summarize your investigation:

**Period analyzed:** [dates]

**Cost trend:** [stable / rising X% / falling X%]

**Root cause:** [primary driver of cost]

**Hidden recompute ratio:** [X%]

**Top 3 cost drivers:**
1. [Driver] - [X% of cost]
2. [Driver] - [X% of cost]
3. [Driver] - [X% of cost]

**Recommended fixes:**
1. [Fix] - [Expected impact] - [Owner] - [Timeline]
2. [Fix] - [Expected impact] - [Owner] - [Timeline]

**10x scaling assessment:** [linear / sublinear / superlinear]

---

## Related Documents

- [Cost Model](cost-model.md) - Detailed formulas and queries
- [Hidden Recompute](hidden-recompute.md) - Deep dive on hidden costs
- [Margin Fragility](../01-failure-modes/margin-fragility.md) - The failure mode this prevents
