# Control Surface Drift

> **Read this when:** Costs are rising but traffic is flat, and you suspect UX is driving hidden compute.
>
> **Time:** 20 min to read, then use [Cost Investigation](../03-economics/cost-investigation.md) for diagnosis.
>
> **After reading:** You will understand how UX creates cost and have patterns to fix it.
>
> **Prerequisites:** Know your hidden recompute ratio. If not, run [this query](../07-examples/metrics-reference.md#hidden-recompute-ratio) first.

---

User behavior and system state interact in ways that multiply recompute, latency, or retries.

Control surface drift is what happens when your UX makes expensive actions feel cheap. Over time, recompute becomes a habit.

---

## The Mechanism

UX shapes behavior. Behavior shapes recompute. Recompute shapes cost.

The problem is not that users are doing something wrong. The problem is that your system made the expensive path feel free.

Examples:
- The undo button that re-embeds the entire context
- The auto-save that triggers a full pipeline re-run
- The regenerate button with no cost indicator
- The edit flow that invalidates cached state

---

## The Signals

Measure these monthly:

| Signal | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Regenerate/undo rate | Stable | Rising 10%+ MoM | Rising 20%+ MoM |
| Retry rate per successful outcome | Under 1.2x | 1.2-1.5x | Over 1.5x |
| Recompute without user awareness | Under 15% | 15-25% | Over 25% |

---

## The Cost

Session recording analysis often reveals unexpected patterns. Users undo constantly when the suggestion system does not match their mental model.

The pattern: AI makes a suggestion, user accepts, user does not like it, user hits undo, AI recomputes everything.

But undo is not just restoring text. Under the hood, it re-runs the entire context pipeline.

The fix is not rate limiting. It is re-architecting the suggestion system to let users reject individual edits without triggering full recomputation.

---

## The Fix

### 1. Map Your Recompute Surfaces

List every user action that can trigger inference. For each one, answer:

| User Action | Visible to User | User Knows Cost | User Can Avoid |
|-------------|-----------------|-----------------|----------------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

<details>
<summary><strong>Example: Control surface audit</strong></summary>

| User Action | Visible | User Knows Cost | User Can Avoid | Issue |
|-------------|---------|-----------------|----------------|-------|
| Generate | Yes | No | Yes | No cost indicator |
| Regenerate | Yes | No | Yes | Feels free |
| Undo | Yes | No | Yes | Triggers full recompute |
| Auto-save | No | No | No | Hidden trigger |
| Edit | Yes | No | Yes | May invalidate cache |

</details>

### 2. Close Unnecessary Triggers

| Trigger | Fix |
|---------|-----|
| Undo triggers recompute | Cache pre-undo state, restore from cache |
| Auto-save triggers pipeline | Debounce, smart dirty detection |
| Edit invalidates cache | Incremental context updates |
| Retry on any error | Retry only on transient errors |

### 3. Redesign for Explicit Intent

The rule: if an action costs more than $0.05, it should be visible and intentional.

- Add "This will use X credits" before expensive actions
- Separate "explore" mode from "commit" mode
- Make undo restore cached state, not recompute
- Add confirmation for regenerate

---

## Checklist

Use this to assess your control surfaces:

- [ ] All user actions that trigger inference are documented
- [ ] Hidden triggers (auto-save, background jobs) are identified
- [ ] Expensive actions have user-visible cost indicators
- [ ] Undo restores cached state rather than recomputing
- [ ] Retry limits are configured for all inference paths
- [ ] Recompute ratio is tracked in monitoring

---

## Investigation Process

When you suspect control surface drift:

1. Pull hidden recompute ratio for last 7 days
2. Identify top 3 trigger types by cost
3. Watch 10 session recordings focused on expensive triggers
4. Map the UX flow that leads to expensive behavior
5. Design fix that aligns user mental model with cost structure

---

## The Test

List the top 10 user actions in your product. Which ones trigger recompute silently?

Those are your control surfaces. If you cannot name them, you are already drifting.

---

## Related

- [Cost Investigation](../03-economics/cost-investigation.md) - Full investigation process
- [Hidden Recompute](../03-economics/hidden-recompute.md) - Deep dive on hidden costs
- [Interaction Contract](../02-architecture/interaction-contract.md) - Preventing expensive user habits
