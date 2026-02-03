# Architecture Decisions

The 3 decisions that close your reversibility window the fastest.

---

## When to Use This Section

| Situation | Read This |
|-----------|-----------|
| Designing what data to persist | [State Model](state-model.md) |
| Defining what user actions trigger compute | [Interaction Contract](interaction-contract.md) |
| Deciding what to own vs rent | [Control Plane Ownership](control-plane-ownership.md) |

**Time required:** 20-40 min per decision

**Prerequisites:** None, but read [Failure Modes](../01-failure-modes/README.md) first if debugging an active issue.

---

## The 3 Irreversible Decisions

| Decision | What It Controls | Why It Hardens |
|----------|------------------|----------------|
| [State Model](state-model.md) | What you persist and how | Downstream systems depend on schema |
| [Interaction Contract](interaction-contract.md) | What user behavior triggers | Users form habits, UX changes break workflows |
| [Control Plane Ownership](control-plane-ownership.md) | What you own vs rent | Contracts lock in, migrations are expensive |

---

## How to Use

### Planning a new system?

Read all three before you ship. Order:
1. [State Model](state-model.md) - Most likely to cause pain later
2. [Interaction Contract](interaction-contract.md) - Shapes user behavior and cost
3. [Control Plane Ownership](control-plane-ownership.md) - Determines operational independence

### Inheriting a system?

Identify which decisions have already closed:
- Is this still in the reversibility window?
- What would it cost to change?
- What signals would trigger a change?

### Facing an active problem?

Go to [Failure Modes](../01-failure-modes/) instead. This section is for prevention, not diagnosis.

---

## After Reading

You will be able to:
- Make explicit decisions about state, interaction, and ownership
- Document decisions using [Decision Record](../00-templates/decision-record.md)
- Identify which decisions are still reversible
- Estimate the cost of changing locked-in decisions

---

## Quick Assessment

Fill this out for your system:

| Question | State Model | Interaction Contract | Control Plane |
|----------|-------------|---------------------|---------------|
| Is this documented? | | | |
| Who owns it? | | | |
| When did we decide? | | | |
| What would trigger a change? | | | |
| What would a change cost? | | | |

If you cannot answer these, you have implicit decisions that need to be made explicit.

---

## The Reversibility Window

Every decision starts cheap and ends expensive.

```
Decision made
     |
     v
[====== Reversibility Window ======]
     |
     v
Changes become migrations
     |
     v
Changes become rewrites
```

**Rule:** If more than two teams depend on a decision, treat changes as migrations, not refactors.

---

## Related

- [Decision Record](../00-templates/decision-record.md) - Template for documenting decisions
- [Failure Modes](../01-failure-modes/) - What happens when these decisions are wrong
