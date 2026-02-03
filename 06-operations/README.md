# Operations

How to run an agentic system day-to-day.

---

## When to Use This Section

| Situation | Read This | Time |
|-----------|-----------|------|
| Designing multi-agent orchestration | [Orchestration](orchestration.md) | 30 min |
| Planning for external tool failures | [Tool Reliability](tool-reliability.md) | 20 min |
| Setting up evals and quality gates | [Eval and Regression](eval-and-regression.md) | 30 min |
| Designing safety and guardrails | [Safety Surface](safety-surface.md) | 25 min |
| Defining human oversight model | [Human in the Loop](human-in-the-loop.md) | 20 min |
| Planning deployment and rollback | [Rollout and Rollback](rollout-and-rollback.md) | 20 min |
| Understanding latency feedback loops | [Latency and SLOs](latency-slo-coupling.md) | 15 min |
| Handling data retention and deletion | [Data Privacy](data-privacy.md) | 20 min |
| Quarterly architecture review | [System Drift Review](system-drift-review.md) | 2 hours |

**Prerequisites:** Understand [Architecture Decisions](../02-architecture/README.md) for context on why these operational concerns exist.

---

## What's Here

| Document | What You Get |
|----------|--------------|
| [Orchestration](orchestration.md) | Patterns for sequencing agents, tools, and state |
| [Tool Reliability](tool-reliability.md) | Circuit breakers, retries, fallbacks |
| [Eval and Regression](eval-and-regression.md) | Golden sets, LLM-as-judge, drift detection |
| [Safety Surface](safety-surface.md) | Guardrails, abuse prevention, content filtering |
| [Human in the Loop](human-in-the-loop.md) | Approval flows, escalation, ownership |
| [Rollout and Rollback](rollout-and-rollback.md) | Feature flags, canary deploys, reversion |
| [Latency and SLOs](latency-slo-coupling.md) | Latency targets and behavioral feedback |
| [Data Privacy](data-privacy.md) | Retention, deletion, residency requirements |
| [System Drift Review](system-drift-review.md) | Quarterly review template |

---

## Quick Reference: What to Monitor

| Category | Metric | Warning | Critical |
|----------|--------|---------|----------|
| Orchestration | Task completion rate | Below 95% | Below 90% |
| Orchestration | Retry rate | Above 10% | Above 20% |
| Tools | Tool success rate | Below 98% | Below 95% |
| Tools | Tool latency p95 | Above SLO | 2x SLO |
| Quality | Eval pass rate | Below 90% | Below 85% |
| Quality | User regenerate rate | Above 20% | Above 30% |

See [Metrics Reference](../07-examples/metrics-reference.md) for formulas and queries.

---

## How to Use

1. **Identify your operational gap** using the table above
2. **Read the relevant document** (15-30 min each)
3. **Implement the patterns** from [Examples](../07-examples/)
4. **Set up monitoring** using [Metrics Reference](../07-examples/metrics-reference.md)

---

## After Reading

You will be able to:
- Design orchestration for multi-agent systems
- Handle external tool failures gracefully
- Set up quality gates and regression detection
- Define SLOs that account for behavioral feedback
- Plan safe deployments with rollback capability

---

## The Operating Principle

**An AI system is only as controllable as its least observable component.**

| If you cannot... | You cannot... |
|------------------|---------------|
| See what the orchestrator decided | Debug agent behavior |
| Measure tool reliability | Improve tool selection |
| Detect quality drift | Prevent regressions |
| Roll back | Ship safely |

Observability is not optional. It is the foundation of operational control.

---

## Operational Cadence

| Frequency | Activity | Document |
|-----------|----------|----------|
| Daily | Check error rates and latency | [Metrics Reference](../07-examples/metrics-reference.md) |
| Weekly | Full operations review | [Weekly Ops Checklist](../00-templates/weekly-ops-checklist.md) |
| Weekly | Review cost per outcome trend | [Cost Model](../03-economics/cost-model.md) |
| Weekly | Check eval pass rates | [Eval and Regression](eval-and-regression.md) |
| After incidents | Post-mortem analysis | [Incident Post-Mortem](../00-templates/incident-postmortem.md) |
| Quarterly | Architecture drift review | [System Drift Review](system-drift-review.md) |

---

## Related

- [Metrics Reference](../07-examples/metrics-reference.md) - All formulas and queries
- [Examples](../07-examples/) - Production code for orchestration and guardrails
- [First 48 Hours](../00-templates/first-48-hours.md) - When operations break down
