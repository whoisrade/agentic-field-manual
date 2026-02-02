# Interaction Contract

**What users can ask for, how often they retry, and when the system recomputes.**

The interaction contract is the bridge between UX and system economics. It determines what user behavior is allowed to mutate state - and what that costs.

---

## Why It's Hard to Undo

Interaction contracts harden because:
- Users form habits around your UX patterns
- Changing flows breaks existing workflows
- Training users is expensive and slow
- Power users build automation on top of your patterns

Once users depend on a behavior, removing it feels like a regression.

---

## The Problem

**UX shapes behavior. Behavior shapes recompute. Recompute shapes cost.**

If your interaction contract allows users to trigger expensive compute without knowing it, they will. Not because they're malicious - because you made it easy.

Examples of broken contracts:
- Regenerate button with no cost indicator
- Undo that triggers full recompute instead of restoring cache
- Auto-save that runs the entire pipeline every 30 seconds
- Edit flows that invalidate large context windows

---

## The Signals

Measure these monthly:

| Signal | Threshold |
|--------|-----------|
| Regenerate/undo rate increase | > 10% month-over-month |
| Retry rate per successful outcome | > 1.2x |
| Recompute from default actions | > 25% of total |
| Outputs mutating state without explicit intent | > 10% |

---

## What a Good Contract Defines

1. **When recompute happens** - explicit triggers only
2. **What state can be mutated** - and by which actions
3. **What outputs are provisional vs final** - draft vs committed
4. **What actions require confirmation** - cost gates
5. **What behaviors are disallowed** - rate limits, quotas

---

## The Principles

**1. Distinguish explore vs commit actions**

Exploration should be cheap. Commitment should be explicit.

- "Preview" = cheap, cached, low-cost
- "Generate" = expensive, confirmed, tracked

**2. Expose irreversible actions before they happen**

If an action can't be undone, say so. If it costs money, show the cost.

**3. Separate draft and final state**

User edits should not immediately become permanent state. Build in a commit step.

**4. Make retries intentional**

If a user clicks "regenerate," they should know:
- This will cost compute
- This will replace the current output
- The previous version will still be accessible

**5. Default to reversible paths**

The safest action should be the default. Destructive actions should require intent.

---

## Example Contract Language

Document these for your product:

| Action | What It Does | Cost | Reversible? |
|--------|-------------|------|-------------|
| Edit draft | Updates local state only | Free | Yes |
| Preview | Runs inference, cached | $0.01 | Yes |
| Regenerate | Runs inference, replaces | $0.08 | Yes (prior saved) |
| Commit | Writes to permanent state | $0.02 | No |
| Undo | Restores prior version | Free | Yes |

---

## The Template

See: Use the [System Drift Review](../templates/system-drift-review.md) to audit your current contract
See: Document your contract in a user-facing format

---

## The Litmus Test

> List the top 5 most expensive actions in your system. Are they user-visible and explicitly confirmed?

If any expensive action is invisible or automatic, your contract is missing a gate.

---

> *"Without interaction contracts, the system learns expensive habits from users."*
