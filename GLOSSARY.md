# Glossary

| | |
|:--|:--|
| **Use when** | You encounter an unfamiliar term, or need to explain a concept to stakeholders |
| **Time** | Reference as needed |
| **Outcome** | Understanding of every term in technical and executive language |
| **Related** | [Stakeholder Glossary](05-communication/stakeholder-glossary.md) ・ [README](README.md) |

---
Terms used in this manual, with definitions for both technical and executive audiences.

---

## Failure Modes

### Legibility Loss

**Technical:** The system produces outputs, but you cannot trace how a user action led to that output. Investigation requires manually reconstructing context.

**Executive:** We cannot explain why the AI did what it did. This is a compliance risk and an enterprise sales blocker.

**Related:** [Legibility Loss](01-failure-modes/legibility-loss.md)

---

### Control Surface Drift

**Technical:** When user behavior and system state interact in ways that multiply recompute, latency, or retries, often invisibly.

**Executive:** Our costs are rising because users are developing expensive habits that we did not anticipate.

**Related:** [Control Surface Drift](01-failure-modes/control-surface-drift.md)

---

### Auditability Gap

**Technical:** You can show what the system output, but you cannot prove what it knew, why it acted, or who approved the behavior.

**Executive:** We cannot answer a regulator's question about why the AI made a specific decision. This is a compliance gap.

**Related:** [Auditability Gap](01-failure-modes/auditability-gap.md)

---

### Margin Fragility

**Technical:** Unit economics degrade as the system scales, often because hidden recompute grows faster than revenue.

**Executive:** Growth is making us less profitable because our AI costs do not scale linearly.

**Related:** [Margin Fragility](01-failure-modes/margin-fragility.md)

---

## Architecture Concepts

### Decision Envelope

**Technical:** The complete context needed to explain and reproduce an AI output: inputs, policy versions, tool calls, and approvals.

**Executive:** A record that proves exactly how and why the AI made a decision.

**Related:** [decision-envelope-schema.json](07-examples/decision-envelope-schema.json)

---

### Speculative State

**Technical:** State produced under uncertainty: drafts, retries, partial generations. If treated as final state, it corrupts your data model.

**Executive:** AI outputs that have not been confirmed by a human. We track these separately from finalized decisions.

---

### Reversibility Window

**Technical:** The period during which a technical decision can be changed cheaply. After the window closes, changes become expensive migrations.

**Executive:** How long we have before a technical choice becomes locked in. Some early decisions are now very expensive to change.

**Related:** [Architecture Decisions](02-architecture/)

---

### Control Surface

**Technical:** Any point where user behavior or system state can trigger recompute, latency changes, or cost.

**Executive:** Points in our product where user actions cause the system to do expensive work.

---

### Interaction Contract

**Technical:** Explicit rules defining what users can request, when the system recomputes, and what state can be mutated.

**Executive:** The agreement between our product and users about what happens when they take actions.

**Related:** [Interaction Contract](02-architecture/interaction-contract.md)

---

### Control Plane Ownership

**Technical:** Whether you own or rent the systems that govern AI behavior: orchestration, logging, policy enforcement, and infrastructure.

**Executive:** Do we control the critical parts of our AI system, or are we dependent on vendors?

**Related:** [Control Plane Ownership](02-architecture/control-plane-ownership.md)

---

### State Model

**Technical:** The schema and semantics of how AI outputs are persisted, versioned, and proven.

**Executive:** How we store and track what the AI produces.

**Related:** [State Model](02-architecture/state-model.md)

---

## Economics Concepts

### Hidden Recompute

**Technical:** Compute work that happens without user awareness: retries, context invalidation, auto-saves triggering full pipelines.

**Executive:** AI processing that costs us money but does not create visible value for users.

**Related:** [Hidden Recompute](03-economics/hidden-recompute.md)

---

### Cost per Successful Outcome

**Technical:** Total cost (inference + orchestration + retries) divided by number of outputs that delivered value.

**Executive:** What it actually costs us to produce something useful, not just to run the AI.

**Related:** [Cost Model](03-economics/cost-model.md), [Metrics Reference](07-examples/metrics-reference.md)

---

### Trigger Type

**Technical:** Classification of what caused an inference call: user explicit action, edit, undo, auto-save, retry, or background job.

**Executive:** Why the AI ran. Some triggers are user-initiated, others are system-initiated.

---

### Hidden Recompute Ratio

**Technical:** Percentage of compute triggered by non-explicit user actions (undo, auto-save, retry, background).

**Executive:** What fraction of our AI costs are invisible to users.

**Related:** [Metrics Reference](07-examples/metrics-reference.md)

---

## Reliability Concepts

### Circuit Breaker

**Technical:** A pattern that stops calling a failing service and returns a fallback, preventing cascade failures.

**Executive:** An automatic safety switch that prevents one broken component from taking down the whole system.

**Related:** [orchestrator.py](07-examples/orchestrator.py)

---

### Checkpoint

**Technical:** Saved state at a known-good point in a multi-step workflow, enabling resumption after failure.

**Executive:** A save point that lets us continue from where we left off instead of starting over.

---

### SLO (Service Level Objective)

**Technical:** A target for system performance, typically latency percentiles or availability percentages.

**Executive:** Our performance target. What we promise users about speed and reliability.

**Related:** [Latency and SLOs](06-operations/latency-slo-coupling.md)

---

### SLO Coupling

**Technical:** The feedback loop where latency changes user behavior, and behavior changes system load.

**Executive:** When the system is slow, users retry, which makes the system slower.

**Related:** [Latency and SLOs](06-operations/latency-slo-coupling.md)

---

## Observability Concepts

### Latency Percentiles (p50, p95, p99)

**Technical:**
- p50 (median): Typical user experience
- p95: Experience for 1 in 20 users
- p99: Worst-case for 1 in 100 users

**Executive:** How fast the system is for most users, and for the unlucky few.

**Related:** [Metrics Reference](07-examples/metrics-reference.md)

---

### Trace ID

**Technical:** A unique identifier that follows a request through all system components, enabling end-to-end debugging.

**Executive:** A tracking number that lets us see exactly what happened for any user action.

---

### Provenance

**Technical:** A verifiable record of how a piece of state was produced: inputs, tools, constraints, and approvals.

**Executive:** The evidence chain that proves how a decision was made.

---

### Context Amnesia

**Technical:** Loss of the decision context that made an output valid at the time it was produced.

**Executive:** We can see what the AI produced, but we have lost the information about why it produced that specific output.

---

## Quality Concepts

### Golden Set

**Technical:** A fixed set of prompts and scenarios with known-good outputs, used for regression testing.

**Executive:** A collection of test cases that we use to make sure the AI still works correctly.

**Related:** [Eval and Regression](06-operations/eval-and-regression.md)

---

### LLM-as-Judge

**Technical:** Using a capable model to evaluate outputs for quality, safety, or accuracy.

**Executive:** Using AI to grade AI outputs at scale.

**Related:** [llm-as-judge-prompts.md](07-examples/llm-as-judge-prompts.md)

---

### Eval Gate

**Technical:** A CI/CD check that blocks deployment if evaluation scores fall below thresholds.

**Executive:** An automatic quality check that prevents shipping bad AI updates.

**Related:** [eval-gate.yml](07-examples/eval-gate.yml)

---

### Drift Detection

**Technical:** Monitoring for semantic changes in AI output distributions over time, often using embedding distance.

**Executive:** Watching for the AI to start behaving differently than expected.

**Related:** [Eval and Regression](06-operations/eval-and-regression.md)

---

## Compliance Concepts

### Sovereignty

**Technical:** The architecture that guarantees where data lives, who can access it, and under which jurisdiction it operates.

**Executive:** Our ability to prove to regulators and customers that data stays where it is supposed to stay.

**Related:** [Sovereignty](04-compliance/sovereignty.md)

---

### Operational Independence

**Technical:** The ability to maintain critical functions without depending on vendor intervention.

**Executive:** Can we keep operating if our vendors have problems?

**Related:** [Operational Independence](04-compliance/operational-independence.md)

---

### Data Residency

**Technical:** Guaranteeing that data is stored and processed only in specific geographic regions.

**Executive:** Proving to European customers that their data never leaves Europe.

**Related:** [Sovereignty](04-compliance/sovereignty.md)

---

## Orchestration Concepts

### Sequential Chain

**Technical:** Running agents or tools one after another, passing output forward.

**Example:** Input -> Research Agent -> Drafting Agent -> Review Agent -> Output

---

### Router Pattern

**Technical:** A decision node that routes to different agents based on input classification.

**Example:** Query -> Classifier -> (Simple Agent OR Complex Agent)

---

### Parallel Fan-Out

**Technical:** Running multiple agents or tools simultaneously, then aggregating results.

**Example:** Query -> [Agent A, Agent B, Agent C] -> Aggregator -> Output

---

### Hierarchical (Supervisor)

**Technical:** A supervisor agent that coordinates specialized sub-agents.

**Example:** Supervisor -> (Research Agent, Analyst Agent, Writer Agent) -> Supervisor -> Output

---

### State Machine

**Technical:** An orchestration pattern with explicit states and transitions, useful for complex workflows with branching.

**Related:** [Orchestration](06-operations/orchestration.md)

---

## Quick Reference

| Term | One-Sentence Definition |
|------|------------------------|
| Legibility Loss | Cannot explain why outputs happened |
| Control Surface | Where user actions trigger AI work |
| Control Surface Drift | Costs rising from user habits |
| Auditability Gap | Cannot prove why AI decided |
| Margin Fragility | Growth erodes profitability |
| Decision Envelope | Proof of how AI decided |
| Speculative State | Unconfirmed AI outputs |
| Reversibility Window | Time before changes get expensive |
| Context Amnesia | Lost the "why" behind outputs |
| Hidden Recompute | Invisible compute waste |
| Cost per Successful Outcome | True cost to produce value |
| Interaction Contract | Rules for user-triggered actions |
| Provenance | Evidence chain for decisions |
| Control Plane Ownership | Who controls the AI system |
| Sovereignty | Where data lives and who controls it |
| Operational Independence | Running without vendor dependency |
| Circuit Breaker | Automatic failure isolation |
| Checkpoint | Save point for resumption |
| SLO | Performance target |
| Trace ID | Request tracking identifier |
| Golden Set | Regression test cases |
| LLM-as-Judge | AI grading AI outputs |
| Eval Gate | Quality check blocking deployment |
| p50/p95/p99 | Latency percentiles |
| Hidden Recompute Ratio | Fraction of invisible AI costs |

---

## For Executive Presentations

### Opening Statement

AI products have a unique failure mode: they can work perfectly and still become impossible to explain. When that happens, we cannot defend our decisions to customers, regulators, or partners.

### The Four Risks

1. We cannot explain why the system did what it did (legibility)
2. User behavior is driving up costs invisibly (control surfaces)
3. We can show what happened but not why (auditability)
4. Growth is making us less profitable (margin fragility)

### Related

See: [Board Explainer](05-communication/board-explainer.md) for the full presentation template.
See: [Stakeholder Glossary](05-communication/stakeholder-glossary.md) for non-technical translations.
