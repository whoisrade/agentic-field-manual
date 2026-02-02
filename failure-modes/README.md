# Failure Modes

Agentic systems don't fail gracefully. They fail silently, then expensively, then catastrophically.

The failure mode is always the same: you lose the ability to trace what happened.

---

## The 4 Failure Modes

| Mode | What It Looks Like | Start Here |
|------|-------------------|------------|
| **Legibility Loss** | "Why did it do that?" takes 2 hours to answer | [legibility-loss.md](legibility-loss.md) |
| **Control Surface Drift** | Margin erodes but traffic is flat | [control-surface-drift.md](control-surface-drift.md) |
| **Auditability Gap** | You can show outputs but not rationale | [auditability-gap.md](auditability-gap.md) |
| **Margin Fragility** | Success creates cost curves you can't sustain | [margin-fragility.md](margin-fragility.md) |

---

## Which One Are You Facing?

**"We can't explain why the system did X"**
See: You have [Legibility Loss](legibility-loss.md)

**"Our inference costs are rising but usage is flat"**
See: You have [Control Surface Drift](control-surface-drift.md) or [Margin Fragility](margin-fragility.md)

**"A customer asked how we made a decision and we couldn't answer"**
See: You have an [Auditability Gap](auditability-gap.md)

**"We're profitable at low volume but losing money as we scale"**
See: You have [Margin Fragility](margin-fragility.md)

---

## The Common Thread

All four failure modes share one root cause: **the system became untraceable**.

- Legibility loss means you can't trace behavior to cause
- Control surface drift means you can't trace cost to trigger
- Auditability gap means you can't trace output to rationale
- Margin fragility means you can't trace economics to behavior

The fix is always the same: restore traceability before it's too late.

---

## What To Do Next

1. Identify which failure mode you're facing
2. Read the deep-dive doc
3. Run the litmus test at the bottom
4. Use the linked template to start fixing it Monday

See: Need something immediately? Go to [Templates](../templates/)
