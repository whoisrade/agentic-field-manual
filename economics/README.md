# Economics at Scale

AI systems have a unique economic problem: success can destroy margin.

This section covers the cost dynamics that emerge as AI products scale - and how to prevent margin fragility before it becomes irreversible.

---

## What's Here

| Topic | What It Covers |
|-------|---------------|
| [Hidden Recompute](hidden-recompute.md) | The silent margin killer |
| [Cost Model](cost-model.md) | Actual formulas for tracking cost per outcome |
| [API vs Owned](api-vs-owned.md) | When to rent inference vs own it |
| [Capacity Planning](capacity-planning.md) | How to forecast demand for bursty AI traffic |

---

## The Core Insight

**In AI products, UX creates economics.**

The regenerate button is a cost driver.
The undo flow is a cost driver.
Auto-save is a cost driver.

Every user interaction that triggers recompute is a line item in your cost model. If you don't track cost per successful outcome, you're flying blind.

---

## The Margin Fragility Test

> At 10x usage, do your unit economics improve, stay flat, or collapse?
>
> - **Improve** See: You have scale
> - **Flat** See: You have a business
> - **Collapse** See: You have a demo

If you can't answer this question with a spreadsheet, you're not ready for growth.

---

## When to Use This Section

- Your CFO is asking why margin is dropping
- You're preparing for a board meeting on unit economics
- You're deciding whether to invest in owned inference
- You need to model cost at 10x usage before shipping a feature
