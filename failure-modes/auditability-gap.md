# Auditability Gap

**You can show outputs, but you can't prove rationale or provenance.**

Auditability is not logging. Logging tells you what happened. Auditability proves why.

---

## The Gap

Most AI systems have this problem:
- Outputs are logged ✓
- Inputs are logged (sometimes) ✓
- Rationale is not logged ✗
- Policy versions are not tied to outputs ✗
- Human approvals exist but aren't recorded ✗

The evidence chain is broken. You can show activity without proving intent.

---

## The Signals

Measure these quarterly:

| Signal | Threshold |
|--------|-----------|
| Critical outputs lacking policy/prompt versioning | > 10% |
| Data lineage reconstruction time | > 1 day |
| Human approvals not tied to immutable records | Any |

---

## The Consequences

- **Regulatory exposure**: You can't prove compliance
- **Lost enterprise deals**: Customers require audit trails you can't provide
- **Legal risk**: Unverifiable decisions become liabilities
- **Internal confusion**: Teams disagree about "what the system knew"

---

## The Cost

The question that kills deals: "Why did your system make this recommendation?"

If your answer is narrative instead of evidence, you've lost. Enterprise buyers have heard "we think it's because..." too many times. They want receipts.

I've seen enterprise deals die in the final security review because the vendor couldn't produce a decision record. Not because the decision was wrong - because they couldn't prove it was right.

See: Read the full story: [The Compliance Question We Couldn't Answer](../war-stories/the-compliance-question-we-couldnt-answer.md)

---

## The Fix

**1. Persist provenance with every decision**

Minimum viable decision envelope:
```json
{
  "trace_id": "uuid",
  "timestamp": "iso8601",
  "inputs": { "user_action": "...", "context_hash": "..." },
  "policy": { "prompt_version": "v2.3", "model_version": "gpt-4-0125" },
  "tool_calls": [...],
  "output": { "result_id": "...", "state": "committed" },
  "approvals": [{ "approver": "user@company.com", "action": "approved" }]
}
```

**2. Version everything that affects output**

- Prompt templates
- Model versions
- Guardrails and policies
- Tool configurations

If you change any of these, the output might change. Version them.

**3. Retain evidence for your compliance window**

Know your retention requirements. Healthcare is different from fintech is different from enterprise SaaS. Design for the longest window you might need.

**4. Make reconstruction possible without live systems**

The test: can you explain a decision from 6 months ago using only stored data?

---

## The Template

See: Use the [Traceability Checklist](../templates/traceability-checklist.md) before shipping
See: Reference the [Decision Envelope Schema](../examples/decision-envelope-schema.json)

---

## The Litmus Test

> Can you reproduce why a decision was made last quarter without live systems?

If the answer involves "we'd have to check with the team" or "we'd need to look at the logs," you have an auditability gap.

---

> *"Logging is not auditability. Reconstructability is auditability."*
