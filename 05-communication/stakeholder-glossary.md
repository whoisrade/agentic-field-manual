# Stakeholder Glossary

> **Read this when:** Preparing for a meeting with non-technical stakeholders, or writing executive communications.
>
> **Time:** Reference as needed. Use alongside [Conversation Scripts](conversation-scripts.md).
>
> **After reading:** You will have plain-language definitions for every technical concept.
>
> **Prerequisites:** None. This is the starting point for stakeholder communication.

---

Terms translated for non-technical audiences. Use these definitions when communicating with executives, board members, and enterprise customers.

---

## How to Use This Document

When explaining technical concepts to stakeholders:

1. Lead with the business impact, not the technical definition
2. Use analogies from their domain (finance, operations, legal)
3. Connect every term to a risk or opportunity they care about
4. Avoid jargon that requires further explanation

---

## Core Terms

### Decision Envelope

**For executives:**
A receipt that proves exactly how and why the AI made a specific decision. When a regulator or customer asks "why did your system do X?", the decision envelope is the evidence.

**Business implication:**
Without decision envelopes, we cannot prove compliance or defend our decisions to auditors.

---

### Hidden Recompute

**For executives:**
AI processing that costs us money but does not create visible value for users. Like running the manufacturing line when no products are being shipped.

**Business implication:**
Hidden recompute is why costs can rise even when usage is flat. Finding and eliminating it directly improves margin.

---

### Control Surface

**For executives:**
Any point in our product where a user action triggers AI processing. Think of it as a toll booth. Every time users pass through, we pay.

**Business implication:**
If we do not manage control surfaces, user behavior directly controls our costs.

---

### Margin Fragility

**For executives:**
A condition where growing the business makes us less profitable because AI costs scale faster than revenue.

**Business implication:**
A product can be "successful" by usage metrics and simultaneously become unprofitable. The 10x test: if usage grows 10x, do we make more money or less?

---

### Legibility

**For executives:**
Our ability to explain why the AI did what it did. When we lose legibility, we cannot debug problems, respond to audits, or defend decisions.

**Business implication:**
Lost legibility creates compliance risk and blocks enterprise deals that require explainability.

---

### Auditability

**For executives:**
The ability to prove, with evidence, why a decision was made. Logging is not auditability. Auditability means we can reconstruct the decision from stored data.

**Business implication:**
Enterprise customers and regulators increasingly require audit trails for AI decisions. Without auditability, we cannot close regulated industry deals.

---

### Speculative State

**For executives:**
AI outputs that have not been confirmed by a human. Like a draft contract that has not been signed.

**Business implication:**
We must track speculative state separately from final decisions. Mixing them creates compliance and quality issues.

---

### Reversibility Window

**For executives:**
The time period during which a technical decision can be changed cheaply. After the window closes, changes become expensive projects rather than quick fixes.

**Business implication:**
Early architecture decisions that seem minor can become very expensive to change later. Awareness of reversibility windows helps prioritize engineering investment.

---

### Control Plane Ownership

**For executives:**
Whether we control the critical parts of our AI system or depend on vendors. If a vendor outage becomes our incident, we do not own the control plane.

**Business implication:**
Vendor dependency creates operational risk. For critical systems, we may need to own infrastructure rather than rent it.

---

### Sovereignty

**For executives:**
Our ability to prove to regulators and customers that data stays where it is supposed to stay. Not just policy, but architecture that enforces it.

**Business implication:**
Sovereignty is a requirement for selling to European enterprise customers and regulated industries. It must be built in, not bolted on.

---

## Quick Reference for Presentations

| Term | One-Sentence Explanation |
|------|--------------------------|
| Decision Envelope | The receipt proving how an AI decision was made |
| Hidden Recompute | AI costs that do not create user value |
| Control Surface | Where user actions trigger AI costs |
| Margin Fragility | Growth making us less profitable |
| Legibility | Ability to explain AI behavior |
| Auditability | Ability to prove decision rationale |
| Speculative State | AI outputs not yet confirmed by humans |
| Reversibility Window | Time before a decision gets expensive to change |
| Control Plane Ownership | Whether we or vendors control our AI system |
| Sovereignty | Proving data stays where regulations require |

---

## Common Questions and Answers

### "Why are our AI costs rising when usage is flat?"

Hidden recompute. User behavior is triggering AI processing that does not create visible value. Common sources: undo buttons that recompute, auto-save that triggers pipelines, retry loops on errors.

### "Can we prove why the AI made a specific decision?"

Only if we have decision envelopes. Without them, we can show what was decided but not prove why. This is the difference between logging and auditability.

### "Are we ready for an enterprise security audit?"

Only if we can reconstruct any decision from stored data, without calling live systems. If reconstruction requires "asking the team" or "checking current logs," we have gaps.

### "What happens to our economics at 10x growth?"

Depends on margin fragility. If hidden recompute grows with usage, costs scale faster than revenue. We need to model this before scaling.

### "Do we control our own system?"

Depends on control plane ownership. If a vendor outage becomes our incident, we are dependent. For critical workloads, we may need to own rather than rent.

---

## Related

- [Board Explainer](board-explainer.md) - Full presentation template
- [Glossary](../glossary.md) - Technical definitions
