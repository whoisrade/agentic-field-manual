# State Model

**What you persist, how you version it, and whether you can explain why a result exists.**

The state model is the first decision that closes your reversibility window. Get it wrong, and you'll rebuild it twice.

---

## Why It's Hard to Undo

State models harden because:
- Downstream systems depend on your schema
- User-facing APIs expose your data structures
- Analytics and reporting build on your assumptions
- Migrations at scale are expensive and risky

Once two teams depend on your state model, changes become migrations, not refactors.

---

## The AI-Specific Problem

AI creates **speculative state** - drafts, retries, partials, intermediate outputs.

Traditional CRUD applications have a simple state model: data goes in, data comes out. AI applications have a more complex reality:
- Multiple generations for the same request
- Retries that produce different results
- Drafts that may or may not be committed
- Intermediate state that influenced the final output

If you persist only final outputs, you erase the rationale needed for traceability and audits.

---

## The Signals

Measure these weekly:

| Signal | Threshold |
|--------|-----------|
| Outputs lacking a decision record | > 20% |
| Outputs overwritten without retaining prior context | > 15% |
| Reproducing an output requires live systems | Any critical output |

---

## The Cost

A Series B company I advised had to rebuild their state model 18 months in. By then:
- 4 teams depended on the original schema
- The migration took 11 weeks
- They lost 2 engineers who didn't want to do the migration

The original decision was made in week 2. The bill came due in month 18.

See: Read the full story: [Why We Rebuilt State Twice](../war-stories/why-we-rebuilt-state-twice.md)

---

## The Principles

**1. Treat every AI output as speculative state with lineage**

Don't persist outputs as facts. Persist them as decisions with context.

**2. Persist deltas and decision context, not just end results**

When state changes, store:
- What changed
- Why it changed
- What the prior state was
- Who or what triggered the change

**3. Separate draft from committed state explicitly**

Never let a draft become indistinguishable from a committed output. Use explicit state flags:
```json
{ "state": "draft" | "committed" | "rejected" }
```

**4. Keep an explicit trace from input to output**

Every output should be traceable back to:
- The user action that triggered it
- The context that informed it
- The policy/model version that produced it

---

## The Decision Envelope

Minimum viable state for any AI output:

```json
{
  "output_id": "uuid",
  "trace_id": "uuid",
  "state": "draft | committed | rejected",
  "created_at": "iso8601",
  "inputs": {
    "user_action": "string",
    "context_hash": "string",
    "prior_state_id": "uuid | null"
  },
  "policy": {
    "prompt_version": "string",
    "model_version": "string"
  }
}
```

See: See the full schema: [Decision Envelope Schema](../examples/decision-envelope-schema.json)

---

## The Template

See: Use the [Decision Log](../templates/decision-log.md) before committing to a state model
See: Check the [Traceability Checklist](../templates/traceability-checklist.md) for coverage

---

## The Litmus Test

> If a user asks "why did this happen?" can you answer with evidence rather than narrative?

If the answer requires guesswork, your state model is missing provenance.

---

> *"Every decision has a reversibility window. Most teams don't notice it closing until it's shut."*
