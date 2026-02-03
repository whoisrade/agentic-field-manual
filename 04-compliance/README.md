# Compliance and Sovereignty

What you need to prove and own to win enterprise deals and survive audits.

---

## When to Use This Section

| Situation | Read This | Time |
|-----------|-----------|------|
| Enterprise customer security review | [Audit Preparation](audit-preparation.md) | 45 min |
| Responding to compliance questionnaire | [Auditability](auditability.md) | 30 min |
| European customer asking about data residency | [Sovereignty](sovereignty.md) | 30 min |
| Reducing vendor dependency | [Operational Independence](operational-independence.md) | 30 min |

**Prerequisites:** Know your current logging and data storage architecture. If you do not, start with [Auditability](auditability.md).

---

## What's Here

| Document | What You Get |
|----------|--------------|
| [Audit Preparation](audit-preparation.md) | Step-by-step guide to prepare for audits |
| [Auditability](auditability.md) | What evidence you need to prove system behavior |
| [Sovereignty](sovereignty.md) | How to guarantee where data lives and who controls it |
| [Operational Independence](operational-independence.md) | How to run without vendor dependency |

---

## Quick Assessment

Can you answer these with evidence?

| Question | Yes with Evidence | Yes with Narrative | No |
|----------|-------------------|--------------------|----|
| Where is data stored and processed? | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp; |
| Can you prove locality under audit? | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp; |
| Can you isolate tenants by region? | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp; |
| Can you run without third-party dependency? | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp; |
| Can you reproduce any decision from last quarter? | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp; |

- **Yes with Evidence:** Healthy
- **Yes with Narrative:** Warning - you have gaps
- **No:** Critical - you will lose deals

---

## How to Use

1. **Run the assessment above** to identify gaps
2. **Read the relevant document** (30-45 min each)
3. **Implement the requirements** from the checklist in each doc
4. **Use [Audit Preparation](audit-preparation.md)** before any security review

---

## After Reading

You will be able to:
- Prepare for enterprise security reviews
- Answer compliance questionnaires with evidence
- Design for data sovereignty requirements
- Assess your vendor dependency risk

---

## The Auditability Standard

Logging is not auditability. **Reconstructability** is auditability.

You need to be able to reproduce:
- What the system knew at decision time
- What actions it took and why
- Who approved the outcome
- Which policies were in effect

If you can only show outputs without rationale, you have an [Auditability Gap](../01-failure-modes/auditability-gap.md).

---

## The Reality

Sovereignty is a vendor-selection requirement for global SaaS selling to enterprise.

The question that kills deals:
> "Can you prove where our data was processed for the last 90 days?"

If your answer is "we would have to check," you have lost.

---

## Related

- [Auditability Gap](../01-failure-modes/auditability-gap.md) - The failure mode this prevents
- [Pre-Ship Checklist](../00-templates/pre-ship-checklist.md) - Traceability requirements before shipping
- [Decision Envelope Schema](../07-examples/decision-envelope-schema.json) - How to structure provenance data
