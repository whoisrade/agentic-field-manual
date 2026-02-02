# Glossary

How to explain these concepts to your board, your CEO, or anyone who doesn't live in the technical details.

---

## Core Concepts

### Legibility Loss

**Technical:** The system produces outputs, but you can't trace how a user action led to that output.

**Board-level:** "We can't explain why the AI did what it did. This is a compliance risk and an enterprise sales blocker."

**One-liner:** *"If you can explain the output, you have control. If you cannot, you're negotiating with your own product."*

---

### Control Surface

**Technical:** Any place where user behavior or system state can trigger recompute, latency changes, or cost.

**Board-level:** "Points in our product where user actions cause the system to do expensive work."

**One-liner:** *"The most expensive button in your UI is the one that feels free."*

---

### Control Surface Drift

**Technical:** When user behavior and system state interact in ways that multiply recompute, latency, or retries - often invisibly.

**Board-level:** "Our costs are rising because users are developing expensive habits that we didn't anticipate."

**One-liner:** *"UX shapes behavior. Behavior shapes cost."*

---

### Auditability Gap

**Technical:** You can show what the system output, but you can't prove what it knew, why it acted, or who approved the behavior.

**Board-level:** "We can't answer a regulator's question about why the AI made a specific decision. This is a compliance gap."

**One-liner:** *"Logging is not auditability. Reconstructability is auditability."*

---

### Margin Fragility

**Technical:** Unit economics degrade as the system scales, often because hidden recompute grows faster than revenue.

**Board-level:** "Growth is making us less profitable because our AI costs don't scale linearly."

**One-liner:** *"At 10x usage, do your unit economics improve, stay flat, or collapse?"*

---

### Decision Envelope

**Technical:** The complete context needed to explain and reproduce an AI output: inputs, policy versions, tool calls, and approvals.

**Board-level:** "A record that proves exactly how and why the AI made a decision."

**Example:** *"When the regulator asks 'why did the system recommend X?', the decision envelope is the evidence."*

---

### Speculative State

**Technical:** State produced under uncertainty - drafts, retries, partial generations. If treated as final state, it corrupts your data model.

**Board-level:** "AI outputs that haven't been confirmed by a human. We need to track these separately from finalized decisions."

**One-liner:** *"Every AI output is speculative until a human commits it."*

---

### Reversibility Window

**Technical:** The period during which a technical decision can be changed cheaply. After the window closes, changes become expensive migrations.

**Board-level:** "How long we have before a technical choice becomes locked in. Some of our early decisions are now very expensive to change."

**One-liner:** *"Every decision starts cheap and ends expensive. The gap is the reversibility window."*

---

### Context Amnesia

**Technical:** Loss of the decision context that made an output valid at the time it was produced.

**Board-level:** "We can see what the AI produced, but we've lost the information about why it produced that specific output."

**One-liner:** *"Context amnesia is not data loss. It's meaning loss."*

---

### Hidden Recompute

**Technical:** Compute work that happens without user awareness - retries, context invalidation, auto-saves triggering full pipelines.

**Board-level:** "AI processing that costs us money but doesn't create visible value for users."

**One-liner:** *"The most expensive compute is the compute that creates no value."*

---

### Interaction Contract

**Technical:** Explicit rules defining what users can request, when the system recomputes, and what state can be mutated.

**Board-level:** "The agreement between our product and users about what happens when they take actions."

**One-liner:** *"Without interaction contracts, the system learns expensive habits from users."*

---

### Provenance

**Technical:** A verifiable record of how a piece of state was produced: inputs, tools, constraints, and approvals.

**Board-level:** "The evidence chain that proves how a decision was made."

**One-liner:** *"Provenance turns 'we think' into 'we can prove.'"*

---

### Control Plane Ownership

**Technical:** Whether you own vs rent the systems that govern AI behavior: orchestration, logging, policy enforcement, and infrastructure.

**Board-level:** "Do we control the critical parts of our AI system, or are we dependent on vendors?"

**One-liner:** *"If a vendor outage becomes your regulatory incident, you don't own the control plane."*

---

### Sovereignty

**Technical:** The architecture that guarantees where data lives, who can access it, and under which jurisdiction it operates.

**Board-level:** "Our ability to prove to regulators and customers that data stays where it's supposed to stay."

**One-liner:** *"Sovereignty is not a future concern. It's a vendor-selection requirement."*

---

### Operational Independence

**Technical:** The ability to maintain critical functions without depending on vendor intervention.

**Board-level:** "Can we keep operating if our vendors have problems?"

**One-liner:** *"Operational independence is not about ideology. It's about resilience."*

---

## Quick Reference

| Term | One-Sentence Definition |
|------|------------------------|
| Legibility Loss | Can't explain why outputs happened |
| Control Surface | Where user actions trigger AI work |
| Control Surface Drift | Costs rising from user habits |
| Auditability Gap | Can't prove why AI decided |
| Margin Fragility | Growth erodes profitability |
| Decision Envelope | Proof of how AI decided |
| Speculative State | Unconfirmed AI outputs |
| Reversibility Window | Time before changes get expensive |
| Context Amnesia | Lost the "why" behind outputs |
| Hidden Recompute | Invisible compute waste |
| Interaction Contract | Rules for user-triggered actions |
| Provenance | Evidence chain for decisions |
| Control Plane Ownership | Who controls the AI system |
| Sovereignty | Where data lives and who controls it |
| Operational Independence | Running without vendor dependency |

---

## How to Use This in a Board Meeting

**Opening:** "AI products have a unique failure mode: they can work perfectly and still become impossible to explain. When that happens, we can't defend our decisions to customers, regulators, or partners."

**The four risks:**
1. We can't explain why the system did what it did (legibility)
2. User behavior is driving up costs invisibly (control surfaces)
3. We can show what happened but not why (auditability)
4. Growth is making us less profitable (margin fragility)

**What we're doing about it:** [Customize for your situation]

**The ask:** [If any]

---

*"Agentic systems don't fail gracefully. They fail silently, then expensively, then catastrophically."*
