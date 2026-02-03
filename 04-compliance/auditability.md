# Auditability

> [!TIP]
> **Read this when:** Designing audit logging, or after discovering you cannot answer an auditor's question.

| | |
|---|---|
| **Time** | 20 min read |
| **Outcome** | Minimum evidence set required for auditability |
| **Prerequisites** | None (foundational) |
| **Related** | [decision-envelope-schema.json](../07-examples/decision-envelope-schema.json) ・ [Audit Preparation](audit-preparation.md) |

---

**The minimum evidence required to prove system behavior under regulatory or enterprise scrutiny.**

Regulation is moving from "show me outputs" to "show me reasoning, data lineage, and control."

---

## The Minimum Evidence Set

For any critical output, you need:

| Evidence | What It Proves |
|----------|---------------|
| Inputs and prompts (versioned) | What the system was asked |
| Tool calls and outputs | What actions were taken |
| Decision records and approvals | Who authorized the outcome |
| Data lineage from source to inference | Where the data came from |
| Policies in effect at decision time | What rules governed behavior |
| Access logs for sensitive data | Who touched what, when |

---

## The Failure Pattern

Teams log outputs but can't prove intent or provenance.

The log says: "Output X was generated at time T"
The auditor asks: "Why? Based on what? Approved by whom?"
The team says: "We'd have to check..."

That's not auditability. That's narrative.

---

## Auditability vs Logging

| Logging | Auditability |
|---------|-------------|
| Records what happened | Proves why it happened |
| Shows activity | Shows intent |
| Stored in various places | Unified evidence chain |
| May be incomplete | Must be complete for critical paths |
| Used for debugging | Used for compliance and defense |

---

## Implementation

**1. Decision envelope per output**

Every critical output has an attached envelope:
```json
{
  "trace_id": "uuid",
  "inputs": {...},
  "policy_version": "v2.3",
  "model_version": "gpt-4-0125",
  "tool_calls": [...],
  "approvals": [...],
  "timestamp": "iso8601"
}
```

**2. Immutable storage**

Decision records cannot be modified after creation. Append-only logs or immutable storage.

**3. Retention aligned to compliance windows**

Know your requirements:
- GDPR: varies by purpose
- HIPAA: 6 years
- Financial services: 5-7 years
- SOC 2: defined by your policy

Design retention before you need it.

**4. Reconstruction capability**

Test regularly: can you reproduce a decision from 6 months ago using only stored data?

---

## The Checklist

Before shipping any AI feature:

- [ ] Inputs versioned and logged
- [ ] Policy version attached to output
- [ ] Model version attached to output
- [ ] Tool calls logged with inputs/outputs
- [ ] Human approvals captured (if required)
- [ ] Data lineage traceable
- [ ] Retention window defined
- [ ] Reconstruction tested

---

## The Litmus Test

> If a regulator asks "why did the system do X?" can you answer with evidence in 24 hours?

If the answer requires live systems, engineering time, or guesswork, you have a gap.

---

> *"Logging is not auditability. Reconstructability is auditability."*
