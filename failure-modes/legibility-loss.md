# Legibility Loss

**The system works, but you can't explain why a specific output happened.**

Legibility loss is not a performance problem. It's a control problem. When you lose legibility, you stop learning from your system. You start negotiating with it.

---

## How It Forms

Legibility loss is a loop, not a bug.

```
User behavior mutates state
        ↓
State triggers recompute
        ↓
Recompute alters latency and quality
        ↓
Latency and quality change behavior
        ↓
(repeat until traceability breaks)
```

This loop compounds until no one can explain what happened.

---

## The Signals

Measure these weekly:

| Signal | Threshold |
|--------|-----------|
| Incidents requiring manual reconstruction | > 30% |
| Outputs lacking a stable trace ID | > 20% |
| Teams giving conflicting explanations for same output | > 2 teams |

---

## What It Sounds Like

- "We can't reproduce this reliably"
- "It depends on the sequence of actions"
- "It works in staging but not in production"
- "We think it's because of X, but we're not sure"

When debugging becomes forensic instead of diagnostic, you've lost legibility.

---

## The Cost

I've seen enterprise deals stall on a single question: "When your AI makes a decision, can you show us exactly what information it used?"

The team could show what the AI decided. They couldn't prove why. For decisions with legal exposure - hiring, recommendations, approvals - "we think it was because..." isn't an answer.

The fix was straightforward: attach a decision envelope to every output. But doing it retroactively took weeks. Doing it from day one would have taken a day.

See: Read the full story: [The Compliance Question We Couldn't Answer](../war-stories/the-compliance-question-we-couldnt-answer.md)

---

## The Fix

**1. Enforce a traceability chain**
```
User action See: State snapshot See: Tool calls See: Output
```
Every output should be traceable back through this chain.

**2. Define interaction contracts**
Which behaviors can mutate state? Make it explicit. Document it. Enforce it.

**3. Persist state provenance**
Store deltas and rationale, not just end states. The decision envelope matters more than the output.

**4. Add architectural gates**
Confirm before irreversible or expensive transitions. Gates create checkpoints in the trace.

---

## The Template

See: Use the [Traceability Checklist](../templates/traceability-checklist.md) before shipping changes
See: Run the [System Drift Review](../templates/system-drift-review.md) quarterly

---

## The Litmus Test

> Pick a random output from yesterday. Can your team explain it in under 10 minutes without guesswork?

If the answer is no, you already have legibility loss. The question is how bad it is.

---

> *"If you can explain the output, you have control. If you cannot, you're negotiating with your own product."*
