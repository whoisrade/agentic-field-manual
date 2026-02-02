# Control Surface Drift

**User behavior and system state interact in ways that multiply recompute, latency, or retries.**

Control surface drift is what happens when your UX makes expensive actions feel cheap. Over time, recompute becomes a habit.

---

## The Mechanism

UX shapes behavior. Behavior shapes recompute. Recompute shapes cost.

The problem isn't that users are doing something wrong. The problem is that your system made the expensive path feel free.

Examples:
- The undo button that re-embeds the entire context
- The auto-save that triggers a full pipeline re-run
- The regenerate button with no cost indicator
- The edit flow that invalidates cached state

---

## The Signals

Measure these monthly:

| Signal | Threshold |
|--------|-----------|
| Regenerate/undo rate increase | > 10% month-over-month |
| Retry rate per successful outcome | > 1.2x |
| Recompute triggered without user awareness | > 25% of total |
| Latency spikes correlating with user churn | Pattern match |

---

## The Cost

I once reviewed Clarity recordings for an AI document editing product and found something unexpected: users were undoing constantly.

The pattern: AI makes a suggestion See: user accepts See: user doesn't like it See: user hits undo See: AI recomputes everything.

But undo wasn't just restoring text. Under the hood, it re-ran the entire context pipeline.

The fix wasn't rate limiting. It was re-architecting the suggestion system to let users reject individual edits without triggering full recomputation.

See: Read the full story: [The Undo Button That Killed Our Margin](../war-stories/the-undo-button-that-killed-our-margin.md)

---

## The Fix

**1. Map your recompute surfaces**

List every user action that can trigger inference. For each one, answer:
- Is it visible to the user?
- Does the user know it costs compute?
- Can the user avoid it if they want to?

**2. Close unnecessary triggers**

- Cache stable context instead of recomputing
- Separate preview compute from commit compute
- Gate expensive retries behind confirmation

**3. Redesign for explicit intent**

The rule: if an action costs more than $0.05, it should be visible and intentional.

- Add "This will use X credits" before expensive actions
- Separate "explore" mode from "commit" mode
- Make undo restore cached state, not recompute

---

## The Template

See: Use the [System Drift Review](../templates/system-drift-review.md) to find your control surfaces
See: Track the metrics in [Cost Model](../economics/cost-model.md)

---

## The Litmus Test

> List the top 10 user actions in your product. Which ones trigger recompute silently?

Those are your control surfaces. If you can't name them, you're already drifting.

---

> *"The most expensive button in your UI is the one that feels free."*
