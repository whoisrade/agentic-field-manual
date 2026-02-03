# Economics at Scale

AI systems have a unique problem: success can destroy margin.

---

## When to Use This Section

| Situation | Read This | Time |
|-----------|-----------|------|
| CFO asking why margin is dropping | [Cost Investigation](cost-investigation.md) | 30 min |
| Need to track cost per outcome | [Cost Model](cost-model.md) | 20 min |
| Deciding build vs buy for inference | [API vs Owned](api-vs-owned.md) | 30 min |
| Modeling cost at 10x scale | [Capacity Planning](capacity-planning.md) | 20 min |
| Finding hidden cost drivers | [Hidden Recompute](hidden-recompute.md) | 20 min |

**Prerequisites:** Know your current cost per API call. If you do not, start with [Cost Model](cost-model.md).

---

## What's Here

| Document | What You Get |
|----------|--------------|
| [Cost Investigation](cost-investigation.md) | Step-by-step diagnosis of rising costs |
| [Cost Model](cost-model.md) | Formulas and queries for tracking cost per outcome |
| [API vs Owned](api-vs-owned.md) | Decision framework for rent vs own |
| [Capacity Planning](capacity-planning.md) | Forecasting for bursty AI traffic |
| [Hidden Recompute](hidden-recompute.md) | Finding the silent margin killer |

---

## Quick Diagnostics

Run weekly:

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Cost per successful outcome | Stable or declining | Rising under 10% MoM | Rising over 10% MoM |
| Hidden recompute ratio | Under 20% | 20-40% | Over 40% |
| Cache hit rate | Over 70% | 50-70% | Under 50% |
| Retry rate | Under 5% | 5-15% | Over 15% |

See [Metrics Reference](../07-examples/metrics-reference.md) for how to calculate these.

---

## How to Use

1. **Run the diagnostics above** to identify your problem area
2. **Read the relevant document** (20-30 min each)
3. **Run the queries** from [diagnostic-queries.sql](../07-examples/diagnostic-queries.sql)
4. **Implement fixes** and track improvement

---

## After Reading

You will be able to:
- Calculate cost per successful outcome (not just cost per request)
- Identify hidden recompute sources
- Make a data-driven build vs buy decision
- Model your economics at 10x scale

---

## The Core Insight

**In AI products, UX creates economics.**

| User Action | Hidden Cost |
|-------------|-------------|
| Regenerate button | Full inference cost again |
| Undo flow | Context rebuild + recompute |
| Auto-save | Can trigger full pipeline |
| Retry on error | Multiplied by retry count |

Every user interaction that triggers recompute is a line item in your cost model.

---

## The Margin Fragility Test

> At 10x usage, do your unit economics improve, stay flat, or collapse?

| Answer | Interpretation |
|--------|----------------|
| Improve | You have scale |
| Flat | You have a business |
| Collapse | You have a demo |

If you cannot answer this with a spreadsheet, you are not ready for growth.

---

## Related

- [Margin Fragility](../01-failure-modes/margin-fragility.md) - The failure mode this prevents
- [Control Surface Drift](../01-failure-modes/control-surface-drift.md) - When UX drives hidden costs
- [Metrics Reference](../07-examples/metrics-reference.md) - All formulas and queries
