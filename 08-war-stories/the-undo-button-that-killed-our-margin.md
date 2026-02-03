# The Undo Button That Killed Our Margin

- **Use when**: Costs are rising but traffic is flat, or you are adding "free" UX features
- **Time**: 15 min read
- **Outcome**: Hidden recompute pattern recognition, instrumentation approach
- **Related**: [Control Surface Drift](../01-failure-modes/control-surface-drift.md) ・ [Hidden Recompute](../03-economics/hidden-recompute.md)

---

A story about hidden recompute, margin erosion, and the button that felt free.

---

## Related Concepts

Prerequisites:
- [Control Surface Drift](../01-failure-modes/control-surface-drift.md) - why UX shapes compute costs
- [Hidden Recompute](../03-economics/hidden-recompute.md) - detecting invisible cost drivers
- [Interaction Contract](../02-architecture/interaction-contract.md) - defining what users can trigger

---

## Context

AI-powered document editing platform. The product helps users write and edit long-form content with AI assistance - suggestions, rewrites, formatting.

Gross margin had been healthy. Over four months, it dropped significantly. Usage was growing, but costs were growing faster. The founder asked me to take a look.

---

## The Signal

First thing I did: pulled up session recordings.

Users weren't just editing. They were undoing. Constantly.

The pattern: AI makes a suggestion See: user accepts See: user doesn't like it See: user hits undo See: AI recomputes.

But undo wasn't just restoring text. Under the hood, it was re-running the entire context pipeline.

---

## The Investigation

I instrumented compute by trigger type. One week of data:

| Trigger Type | % of Compute |
|-------------|-------------|
| user_generate | ~30% |
| user_edit | ~20% |
| user_undo | ~35% |
| auto_save | ~15% |

Undo was the single largest cost driver. More than generate.

### Why was undo so expensive?

The undo implementation was straightforward from a state perspective, but expensive from a compute perspective:

1. User clicks Undo
2. System restores previous document state ✓
3. System re-embeds the entire context window ✗
4. System re-validates AI suggestions against new state ✗

Steps 3 and 4 were invisible to users. They thought undo was free. It wasn't.

This pattern is well-documented in UX research. See Jakob Nielsen's work on [recognition vs recall](https://www.nngroup.com/articles/recognition-and-recall/) - users will always take the path of least perceived effort, regardless of actual cost.

### The compounding effect

Undo-triggered recomputations had lower quality scores. The context was stale - it was rebuilding from the previous state, not the current session context.

Lower quality See: users undo again See: more cost See: worse quality See: more undo.

The loop was eating margin.

---

## The Fix

### Week 1: Stop the bleeding

The root cause was architectural: the product was fighting the user's mental model.

Users expected to accept or reject individual suggestions. Instead, they had to accept everything, then undo what they didn't want.

I proposed moving AI operations directly into the native suggestion system (the platform supported inline suggestions). This would let users reject individual edits without triggering full recomputation.

### Week 2: Implement granular rejection

Re-architected the suggestion flow:
- AI suggestions appear as reviewable items
- User can accept/reject each one individually
- Rejecting a suggestion doesn't trigger recompute - it just removes that suggestion
- Only explicit "regenerate" triggers new AI work

### Week 3: Cache what doesn't change

- Context embeddings cached per session
- Undo now restores cached context, doesn't recompute
- Added explicit cost indicator on regenerate action

---

## The Aftermath

**6 weeks later:**
- Undo-triggered recompute down ~90%
- Cost per document dropped significantly
- User satisfaction improved (they preferred granular control)

**The insight:**
The most expensive patterns emerge from UX/architecture misalignment. Users weren't doing anything wrong - the system was forcing expensive behavior.

---

## The Lesson

Session recordings are underrated for cost debugging.

I would never have found this pattern from metrics alone. The metrics said "undo is expensive." The recordings showed *why* users were undoing - and that the fix was architectural, not a rate limit.

**The pattern to watch for:**
When a "free" action triggers expensive compute, users will over-use it. The fix is usually to align the UX with the underlying cost structure - make cheap things feel cheap, expensive things feel expensive.

This aligns with Don Norman's principles in [The Design of Everyday Things](https://www.nngroup.com/books/design-everyday-things-revised/) - affordances should match actual system behavior.

---

## Further Reading

- [The Design of Everyday Things](https://www.nngroup.com/books/design-everyday-things-revised/) by Don Norman - on aligning user mental models with system behavior
- [Clarity](https://clarity.microsoft.com/) - free session recording tool by Microsoft
- [How to Measure Anything](https://www.howtomeasureanything.com/) by Douglas Hubbard - on finding unexpected metrics that matter

---

## The Templates

See: Use [Cost Model](../03-economics/cost-model.md) to instrument by trigger type
See: Run [System Drift Review](../06-operations/system-drift-review.md) to find your hidden undo button

---

> *"The most expensive button in your UI is the one that feels free."*
