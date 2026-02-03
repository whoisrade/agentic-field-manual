# Failure Modes

The 4 ways agentic systems break.

---

## When to Use This Section

| Situation | Read This |
|-----------|-----------|
| "Why did it do that?" and no one knows | [Legibility Loss](legibility-loss.md) |
| Costs rising but traffic is flat | [Control Surface Drift](control-surface-drift.md) |
| Customer asked for decision rationale, you cannot provide it | [Auditability Gap](auditability-gap.md) |
| Profitable at low volume, losing money at scale | [Margin Fragility](margin-fragility.md) |

**Time required:** 15-30 min per failure mode

---

## The 4 Failure Modes

| Mode | Signal | Detection Time |
|------|--------|----------------|
| [Legibility Loss](legibility-loss.md) | Cannot explain outputs | Days to weeks |
| [Control Surface Drift](control-surface-drift.md) | Hidden cost growth | Weeks to months |
| [Auditability Gap](auditability-gap.md) | Cannot prove rationale | Surfaces at audit |
| [Margin Fragility](margin-fragility.md) | Scale destroys margin | Months to quarters |

---

## Quick Diagnostics

Run weekly:

| Check | Healthy | Warning | Critical |
|-------|---------|---------|----------|
| Time to explain any output | Under 10 min | 10-60 min | Over 1 hour |
| Hidden recompute ratio | Under 20% | 20-40% | Over 40% |
| Outputs missing decision records | Under 5% | 5-20% | Over 20% |
| Cost per outcome trend | Stable | Rising under 10% MoM | Rising over 10% MoM |

---

## How to Use

1. **Identify your failure mode** using the diagnostics above
2. **Read the detailed document** for that mode (15-30 min)
3. **Run the checklist** at the end of that document
4. **Use the linked template** to begin remediation

---

## After Reading

You will be able to:
- Diagnose which failure mode you are facing
- Explain the root cause to your team
- Know the specific metrics to track
- Have a checklist of fixes to implement

---

## The Common Root Cause

All four failure modes share one cause: **the system became untraceable**.

| Failure Mode | What You Lost |
|--------------|---------------|
| Legibility Loss | Cannot trace behavior to cause |
| Control Surface Drift | Cannot trace cost to trigger |
| Auditability Gap | Cannot trace output to rationale |
| Margin Fragility | Cannot trace economics to behavior |

The fix is always the same: restore traceability.

---

## Related

- [Pre-Ship Checklist](../00-templates/pre-ship-checklist.md) - Prevent these before they start
- [Crisis Playbook](../00-templates/crisis-playbook.md) - If a failure mode is causing an incident
- [Cost Investigation](../03-economics/cost-investigation.md) - Deep dive on cost failures
