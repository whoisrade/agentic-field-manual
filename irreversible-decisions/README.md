# The 3 Irreversible Decisions

Every AI product has a window where decisions are reversible. These three choices close that window the fastest.

Get them right, and the rest stays flexible. Get them wrong, and you'll pay for years.

---

## The Decisions

| Decision | What It Controls | Why It's Hard to Undo |
|----------|-----------------|----------------------|
| **State Model** | What you persist and how you prove it | Data models harden, downstream systems depend on them |
| **Interaction Contract** | What user behavior can trigger | Users form habits, UX changes break workflows |
| **Control Plane Ownership** | What you own vs rent | Contracts lock in, migrations are expensive |

---

## How to Use This Section

**Planning a new system?**
See: Read all three before you ship. These are the decisions you'll regret not thinking through.

**Inheriting a system?**
See: Identify which decisions have already closed. That tells you where you have leverage and where you don't.

**Facing a specific problem?**
See: Go to [Failure Modes](../failure-modes/) instead - this section is for prevention, not diagnosis.

---

## The Reversibility Window

Every decision starts cheap and ends expensive. The gap is the reversibility window.

**What closes the window:**
- User habits harden
- Data models stabilize
- Compliance requirements solidify
- Contracts and integrations lock in assumptions

**The rule of thumb:**
If more than two teams or systems depend on a decision, treat changes as migrations, not refactors.

---

## Details

- [State Model](state-model.md) - what to persist and how to prove it
- [Interaction Contract](interaction-contract.md) - what users can trigger and when
- [Control Plane Ownership](control-plane-ownership.md) - what to own vs rent

---

> *"The best time to make the hard decision is before the system has users. The second best time is now."*
