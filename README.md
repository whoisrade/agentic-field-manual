# Agentic Field Manual

Production patterns for teams building autonomous AI systems.

---

## Start Here

**New to this system?** [Run the 10-minute assessment](ASSESS.md) to find your gaps and get specific recommendations.

**In a crisis?** Go directly to [First 48 Hours](00-templates/first-48-hours.md).

**Need a quick reference?** Print the [Quick Reference Card](QUICK-REFERENCE.md).

---

## Quick Wins (30 min or less)

Do one of these today:

| Action | Impact | Time |
|--------|--------|------|
| Add trace IDs to all inference calls | Debug any output | 30 min |
| Log trigger type with every compute | Find hidden recompute | 15 min |
| Run [cost per outcome query](07-examples/metrics-reference.md#cost-per-successful-outcome) | Know your economics | 10 min |
| Add model + prompt version to logs | Enable reproducibility | 20 min |
| Set up weekly cost trend alert | Catch drift early | 15 min |

---

## What's Your Situation?

### Something Is On Fire

| Situation | Do This | Time |
|-----------|---------|------|
| System is failing, costs exploding, quality collapsing | [First 48 Hours](00-templates/first-48-hours.md) | 2-8 hours |
| Cannot explain why the system did something | [Legibility Loss](01-failure-modes/legibility-loss.md) | 30 min read, then fix |
| Costs rising but traffic is flat | [Cost Investigation](03-economics/cost-investigation.md) | 1-2 hours |
| Enterprise deal dying due to audit questions | [Audit Preparation](04-compliance/audit-preparation.md) | 2-4 hours |

### I'm About to Ship

| Situation | Do This | Time |
|-----------|---------|------|
| Launching an agentic feature this week | [Pre-Ship Checklist](00-templates/pre-ship-checklist.md) | 1-2 hours |
| Making an architecture decision | [Decision Record](00-templates/decision-record.md) | 15-60 min |

### I Just Inherited This System

| Question to Answer | Read This | Time |
|--------------------|-----------|------|
| What are the failure modes I should watch for? | [Failure Modes Overview](01-failure-modes/README.md) | 20 min |
| What decisions are already locked in? | [Architecture Decisions](02-architecture/README.md) | 30 min |
| What should I be monitoring? | [Metrics Reference](07-examples/metrics-reference.md) | 30 min |
| What questions should I ask the team? | [System Review Questions](#system-review-questions) | 10 min |

### I Need to Present to Leadership

| Situation | Do This | Time |
|-----------|---------|------|
| Board meeting about AI risk | [Board Explainer](05-communication/board-explainer.md) | 30 min read, 1 hour customize |
| CFO asking about margin | [Cost Model](03-economics/cost-model.md) + [Margin Fragility](01-failure-modes/margin-fragility.md) | 1 hour |
| Need to translate terms | [Stakeholder Glossary](05-communication/stakeholder-glossary.md) | 10 min |

### I'm Reviewing Someone's Design

| What to Check | Reference | Questions to Ask |
|---------------|-----------|------------------|
| State model | [State Model](02-architecture/state-model.md) | Is speculative state explicit? Can you reconstruct decisions? |
| Interaction contract | [Interaction Contract](02-architecture/interaction-contract.md) | What triggers recompute? What's the cost per action? |
| Control plane | [Control Plane Ownership](02-architecture/control-plane-ownership.md) | What do you own vs rent? What's the exit plan? |
| Orchestration | [Orchestration](06-operations/orchestration.md) | How do you handle failures? What's the cost cap? |
| Guardrails | [Safety Surface](06-operations/safety-surface.md) | What layers of defense? What's the abuse surface? |

### I'm Building Something New

| Phase | Key Documents |
|-------|---------------|
| Design | [State Model](02-architecture/state-model.md), [Interaction Contract](02-architecture/interaction-contract.md), [Orchestration](06-operations/orchestration.md) |
| Implementation | [Examples](07-examples/README.md), [Metrics Reference](07-examples/metrics-reference.md) |
| Pre-Launch | [Pre-Ship Checklist](00-templates/pre-ship-checklist.md) |
| Post-Launch | [Eval and Regression](06-operations/eval-and-regression.md), [System Drift Review](06-operations/system-drift-review.md) |

---

## System Review Questions

Use these when assessing any agentic system:

### Traceability (5 min)

- [ ] Pick a random output from yesterday. Can you explain it in under 10 min?
- [ ] Do you have trace IDs that follow requests end-to-end?
- [ ] Are model and prompt versions recorded with each output?

### Economics (5 min)

- [ ] Do you know your cost per successful outcome?
- [ ] What percentage of compute is hidden (retries, undo, auto-save)?
- [ ] At 10x usage, do unit economics improve, stay flat, or collapse?

### Auditability (5 min)

- [ ] Can you prove what the system knew at decision time?
- [ ] Are human approvals recorded with timestamps?
- [ ] Can you reconstruct a decision from 6 months ago?

### Reliability (5 min)

- [ ] What happens when an external tool fails?
- [ ] Do you have circuit breakers?
- [ ] How long does rollback take?

**Scoring:**
- All checked: Healthy
- Most checked: Warning - prioritize gaps
- Few checked: Critical - use [First 48 Hours](00-templates/first-48-hours.md)

---

## Quick Diagnostics

Run weekly:

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Time to explain any output | Under 10 min | 10-60 min | Over 1 hour |
| Hidden recompute ratio | Under 20% | 20-40% | Over 40% |
| Cost per outcome trend | Stable | Rising under 10% MoM | Rising over 10% MoM |
| Outputs missing decision records | Under 5% | 5-20% | Over 20% |
| Eval pass rate | Over 90% | 85-90% | Under 85% |

See [Metrics Reference](07-examples/metrics-reference.md) for how to calculate these.

---

## Maturity Levels

Where is your system?

| Level | Traceability | Economics | Auditability | Reliability |
|-------|--------------|-----------|--------------|-------------|
| **1: Blind** | Cannot explain outputs | Do not know cost per outcome | Logs only | No circuit breakers |
| **2: Reactive** | Can explain with effort (1+ hour) | Know cost, not tracking trend | Some provenance | Manual rollback |
| **3: Observable** | Can explain in 10 min | Weekly cost tracking | Decision envelopes | Circuit breakers exist |
| **4: Controlled** | Real-time tracing | Cost alerts, capacity planning | Full audit trail | Automated rollback |
| **5: Optimized** | Self-diagnosing | Predictive cost modeling | Proactive compliance | Self-healing |

**Most teams are at Level 2.** This manual helps you get to Level 3-4.

To assess your level, run the [System Review Questions](#system-review-questions).

---

## Severity Levels

When something goes wrong, classify it:

| Severity | Definition | Response Time | Example |
|----------|------------|---------------|---------|
| **P0** | System down or data loss | Immediate, all hands | Complete outage, wrong outputs at scale |
| **P1** | Major feature broken, revenue impact | Within 1 hour | Costs 10x normal, key workflow broken |
| **P2** | Feature degraded, workaround exists | Within 4 hours | Slow responses, intermittent failures |
| **P3** | Minor issue, no revenue impact | Within 1 week | Edge case bug, cosmetic issue |

Use [First 48 Hours](00-templates/first-48-hours.md) for P0/P1. Regular process for P2/P3.

---

## The 4 Failure Modes

| Failure Mode | Signal | Root Cause |
|--------------|--------|------------|
| [Legibility Loss](01-failure-modes/legibility-loss.md) | "Why did it do that?" takes hours | Missing decision context |
| [Control Surface Drift](01-failure-modes/control-surface-drift.md) | Costs rise, traffic flat | User behavior triggers hidden compute |
| [Auditability Gap](01-failure-modes/auditability-gap.md) | Can show outputs, not rationale | Logging without provenance |
| [Margin Fragility](01-failure-modes/margin-fragility.md) | Success destroys margin | No cost-per-outcome tracking |

---

## The 3 Irreversible Decisions

| Decision | Controls | Why It Hardens |
|----------|----------|----------------|
| [State Model](02-architecture/state-model.md) | What you persist | Downstream systems depend on schema |
| [Interaction Contract](02-architecture/interaction-contract.md) | What triggers compute | Users form habits around UX |
| [Control Plane Ownership](02-architecture/control-plane-ownership.md) | What you own vs rent | Contracts and migrations lock in |

---

## Case Studies

| Story | Lesson |
|-------|--------|
| [The Undo Button That Killed Our Margin](08-war-stories/the-undo-button-that-killed-our-margin.md) | Hidden recompute from "free" UI actions |
| [Why We Rebuilt State Twice](08-war-stories/why-we-rebuilt-state-twice.md) | State model closes reversibility window |
| [The Compliance Question We Couldn't Answer](08-war-stories/the-compliance-question-we-couldnt-answer.md) | Auditability gaps kill enterprise deals |
| [From API to Owned in 90 Days](08-war-stories/from-api-to-owned-in-90-days.md) | When to transition inference ownership |

---

## Reference

| Resource | Purpose |
|----------|---------|
| [Quick Reference Card](QUICK-REFERENCE.md) | One-page summary - print this |
| [System Assessment](ASSESS.md) | 10-minute self-assessment with scoring |
| [Conversation Scripts](05-communication/conversation-scripts.md) | Exact words for stakeholder meetings |
| [Glossary](glossary.md) | All terms with technical and executive definitions |
| [Metrics Reference](07-examples/metrics-reference.md) | Formulas and queries for every metric |
| [Examples](07-examples/README.md) | Production code and schemas |
| [Templates](00-templates/README.md) | Documents you copy and fill in |

---

## Full Topic Index

<details>
<summary>Expand for complete navigation by topic</summary>

### Architecture and Design

| Topic | Document |
|-------|----------|
| State persistence | [State Model](02-architecture/state-model.md) |
| User action triggers | [Interaction Contract](02-architecture/interaction-contract.md) |
| Build vs buy | [API vs Owned](03-economics/api-vs-owned.md) |
| Control plane | [Control Plane Ownership](02-architecture/control-plane-ownership.md) |
| Multi-agent orchestration | [Orchestration](06-operations/orchestration.md) |
| Tool failure handling | [Tool Reliability](06-operations/tool-reliability.md) |

### Cost and Economics

| Topic | Document |
|-------|----------|
| Cost investigation | [Cost Investigation](03-economics/cost-investigation.md) |
| Cost per outcome | [Cost Model](03-economics/cost-model.md) |
| Hidden recompute | [Hidden Recompute](03-economics/hidden-recompute.md) |
| Capacity planning | [Capacity Planning](03-economics/capacity-planning.md) |
| Margin at scale | [Margin Fragility](01-failure-modes/margin-fragility.md) |

### Quality and Reliability

| Topic | Document |
|-------|----------|
| Evals and regression | [Eval and Regression](06-operations/eval-and-regression.md) |
| Latency and SLOs | [Latency and SLOs](06-operations/latency-slo-coupling.md) |
| Rollout and rollback | [Rollout and Rollback](06-operations/rollout-and-rollback.md) |
| Safety and guardrails | [Safety Surface](06-operations/safety-surface.md) |
| Human oversight | [Human in the Loop](06-operations/human-in-the-loop.md) |

### Compliance

| Topic | Document |
|-------|----------|
| Audit preparation | [Audit Preparation](04-compliance/audit-preparation.md) |
| Auditability requirements | [Auditability](04-compliance/auditability.md) |
| Data sovereignty | [Sovereignty](04-compliance/sovereignty.md) |
| Operational independence | [Operational Independence](04-compliance/operational-independence.md) |
| Data privacy | [Data Privacy](06-operations/data-privacy.md) |

</details>

---

## About

Written by [Rade Joksimovic](AUTHOR.md). Patterns from systems with 1.5M+ MAU, 30M+ monthly API calls, 50K+ orchestrated agents.

---

*If you can explain the output, you have control. If you cannot, you are negotiating with your own product.*
