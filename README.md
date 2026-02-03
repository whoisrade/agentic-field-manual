<div align="center">

# Agentic Field Manual

### The missing operations manual for production AI systems.

<br/>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/whoisrade/agentic-field-manual)](https://github.com/whoisrade/agentic-field-manual/commits/main)
[![GitHub stars](https://img.shields.io/github/stars/whoisrade/agentic-field-manual?style=social)](https://github.com/whoisrade/agentic-field-manual/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Author](https://img.shields.io/badge/Author-Rade_Joksimovic-orange)](AUTHOR.md)

**[Quick Start](#quick-start)** · **[Assess Your System](ASSESS.md)** · **[Crisis Playbook](00-templates/crisis-playbook.md)** · **[Quick Reference](QUICK-REFERENCE.md)**

</div>

---

**Agentic systems fail silently, expensively, then catastrophically.** This manual gives you the patterns, checklists, and code to prevent that—from a team that learned operating 1.5M+ MAU systems the hard way.

---

## Who This Is For

- **Principal Engineers** inheriting or building agentic systems
- **CTOs/VPEs** who need to understand AI operational risk
- **AI/ML Engineers** shipping to production (not just prototyping)
- **Platform Teams** building shared AI infrastructure

This manual is for production systems where failure has consequences.

---

## Quick Start

Add this to your inference calls today:

```python
def log_inference(request, response, model_version, prompt_version):
    return {
        "trace_id": str(uuid.uuid4()),
        "trigger_type": request.get("trigger", "user_explicit"),
        "model_version": model_version,
        "prompt_version": prompt_version,
        "cost_usd": calculate_cost(response.usage),
        "state": "speculative",  # → "committed" when user accepts
    }
```

Then run weekly:

```sql
SELECT SUM(cost_usd) / NULLIF(COUNT(DISTINCT CASE 
  WHEN state = 'committed' THEN trace_id END), 0) as cost_per_outcome
FROM inference_logs WHERE created_at > NOW() - INTERVAL '7 days';
```

**If cost per outcome is rising**, you have a problem → [Cost Investigation](03-economics/cost-investigation.md)

---

## Start Here

| Your Situation | Go To |
|----------------|-------|
| **Just inherited a system** | [System Assessment](ASSESS.md) → [Failure Modes](01-failure-modes/README.md) |
| **Building something new** | [State Model](02-architecture/state-model.md) → [Interaction Contract](02-architecture/interaction-contract.md) |
| **In crisis mode** | [Crisis Playbook](00-templates/crisis-playbook.md) |
| **Costs are spiking** | [Cost Investigation](03-economics/cost-investigation.md) |
| **Presenting to leadership** | [Board Explainer](05-communication/board-explainer.md) |
| **Setting up observability** | [Metrics Reference](07-examples/metrics-reference.md) |
| **Preparing for an audit** | [Audit Preparation](04-compliance/audit-preparation.md) |

> [!TIP] **First time here?** Run the [10-minute assessment](ASSESS.md) to identify your gaps and get personalized recommendations.

---

## The 4 Failure Modes

These are how agentic systems break:

| Failure Mode | Signal | Fix |
|--------------|--------|-----|
| [Legibility Loss](01-failure-modes/legibility-loss.md) | "Why did it do that?" takes hours | Decision envelopes |
| [Control Surface Drift](01-failure-modes/control-surface-drift.md) | Costs rise, traffic flat | Interaction contracts |
| [Auditability Gap](01-failure-modes/auditability-gap.md) | Can show outputs, not rationale | Provenance logging |
| [Margin Fragility](01-failure-modes/margin-fragility.md) | Success destroys margin | Cost-per-outcome tracking |

---

## The 3 Irreversible Decisions

These decisions harden quickly—get them right early:

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
| [Adoption Guide](ADOPTION.md) | How to implement these patterns incrementally |
| [Anti-Patterns](ANTI-PATTERNS.md) | Common mistakes to avoid |
| [Glossary](GLOSSARY.md) | All terms with technical and executive definitions |
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

### Templates

| Situation | Template |
|-----------|----------|
| System failing | [Crisis Playbook](00-templates/crisis-playbook.md) |
| Costs spiked | [Cost Spike Runbook](00-templates/cost-spike-runbook.md) |
| Weekly review | [Weekly Ops Checklist](00-templates/weekly-ops-checklist.md) |
| After incident | [Incident Post-Mortem](00-templates/incident-postmortem.md) |
| Before shipping | [Pre-Ship Checklist](00-templates/pre-ship-checklist.md) |
| Architecture decision | [Decision Record](00-templates/decision-record.md) |

</details>

---

## Contributing

Found a bug? Have a war story to share? See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## About the Author

**[Rade Joksimovic](AUTHOR.md)** - Principal engineer focused on AI systems at scale.

- 15+ years building SaaS systems
- Recent focus: LLM-driven products and agentic infrastructure
- Scale: 1.5M+ MAU, 30M+ monthly API calls, 50K+ orchestrated agents

[Twitter](https://twitter.com/whoisrade) ・ [LinkedIn](https://linkedin.com/in/radejoksimovic) ・ [Email](mailto:rade.joksimovic@gmail.com)

---

## Acknowledgments

Thanks to the teams at [Filekit](https://filekit.ai), [ShortlistIQ](https://shortlistiq.com), [Olovka](https://olovka.ai), and [Rumora](https://rumora.ai) for battle-testing these patterns across diverse agentic architectures—from document generation to autonomous interviewing to social media orchestration.

Special thanks to everyone who shared war stories, reported issues, and contributed patterns from their own production systems.

---

<div align="center">

*If you can explain the output, you have control.*  
*If you cannot, you are negotiating with your own product.*

<br/>

**[⬆ Back to Top](#agentic-field-manual)**

</div>
