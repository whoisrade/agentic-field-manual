# Legibility Loss

> **Read this when:** You cannot explain why the system produced a specific output.
>
> **Time:** 20 min to read, 2-4 hours to implement fixes.
>
> **After reading:** You will know the root cause, have a checklist of fixes, and understand what to monitor.
>
> **Prerequisites:** None.

---

The system works, but you cannot explain why a specific output happened.

Legibility loss is not a performance problem. It is a control problem. When you lose legibility, you stop learning from your system. You start negotiating with it.

---

## How It Forms

Legibility loss is a loop, not a bug.

```
User behavior mutates state
        |
        v
State triggers recompute
        |
        v
Recompute alters latency and quality
        |
        v
Latency and quality change behavior
        |
        v
(repeat until traceability breaks)
```

This loop compounds until no one can explain what happened.

---

## The Signals

Measure these weekly:

| Signal | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Time to explain any output | Under 10 min | 10-60 min | Over 1 hour |
| Incidents requiring manual reconstruction | Under 10% | 10-30% | Over 30% |
| Outputs lacking a stable trace ID | Under 5% | 5-20% | Over 20% |

---

## What It Sounds Like

- "We cannot reproduce this reliably"
- "It depends on the sequence of actions"
- "It works in staging but not in production"
- "We think it is because of X, but we are not sure"

When debugging becomes forensic instead of diagnostic, you have lost legibility.

---

## The Cost

Enterprise deals stall on a single question: "When your AI makes a decision, can you show us exactly what information it used?"

Teams can show what the AI decided. They cannot prove why. For decisions with legal exposure (hiring, recommendations, approvals) "we think it was because..." is not an answer.

The fix is straightforward: attach a decision envelope to every output. Doing it retroactively takes weeks. Doing it from day one takes a day.

---

## The Fix

### 1. Enforce a Traceability Chain

Every output should be traceable through this chain:

```
User action -> State snapshot -> Tool calls -> Output
```

<details>
<summary><strong>Example: Minimum traceability logging</strong></summary>

```python
# At each step, log with trace_id
log_entry = {
    "trace_id": context.trace_id,
    "step": "tool_call",
    "timestamp": datetime.utcnow().isoformat(),
    "input_hash": hash_inputs(inputs),
    "output_hash": hash_outputs(outputs),
    "latency_ms": elapsed_ms,
}
```

</details>

### 2. Define Interaction Contracts

Which behaviors can mutate state? Make it explicit. Document it. Enforce it.

| User Action | Can Mutate State | Triggers Recompute |
|-------------|------------------|-------------------|
| View | No | No |
| Edit | Yes | Sometimes |
| Generate | Yes | Yes |
| Undo | Yes | Depends on implementation |

### 3. Persist State Provenance

Store deltas and rationale, not just end states. The decision envelope matters more than the output.

See: [Decision Envelope Schema](../07-examples/decision-envelope-schema.json)

### 4. Add Architectural Gates

Confirm before irreversible or expensive transitions. Gates create checkpoints in the trace.

---

## Checklist

Use this to assess your current legibility:

- [ ] Every output has a trace ID
- [ ] Trace ID links to full decision context
- [ ] State changes include prior state reference
- [ ] Tool calls are logged with inputs and outputs
- [ ] Model and prompt versions are recorded
- [ ] Reconstruction is tested, not just designed

---

## The Litmus Test

> Pick a random output from yesterday. Can your team explain it in under 10 minutes without guesswork?

If the answer is no, you already have legibility loss. The question is how bad it is.

---

## Related

- [Pre-Ship Checklist](../00-templates/pre-ship-checklist.md) - Traceability requirements before shipping
- [State Model](../02-architecture/state-model.md) - Architectural decisions that affect legibility
- [System Drift Review](../06-operations/system-drift-review.md) - Detecting legibility drift over time
