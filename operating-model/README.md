# Operating Model

How to run an agentic system that stays legible, controllable, and auditable.

This section covers the day-to-day operational concerns: orchestration, tool reliability, evals, safety, human oversight, and deployment.

---

## What's Here

| Topic | What It Covers |
|-------|---------------|
| [Orchestration](orchestration.md) | How to sequence agents, tools, and state transitions |
| [Tool Reliability](tool-reliability.md) | How to handle external tool failures gracefully |
| [Eval and Regression](eval-and-regression.md) | How to prevent silent quality drift |
| [Safety Surface](safety-surface.md) | How to limit the abuse surface of agentic systems |
| [Human in the Loop](human-in-the-loop.md) | How to assign ownership for AI outputs |
| [Rollout and Rollback](rollout-and-rollback.md) | How to deploy safely and revert quickly |
| [Latency and SLOs](latency-slo-coupling.md) | How latency creates behavioral feedback loops |
| [Data Privacy](data-privacy.md) | How to handle retention, deletion, and residency |

---

## The Operating Principle

**An AI system is only as controllable as its least observable component.**

If you can't see what the orchestrator decided, you can't debug it.
If you can't measure tool reliability, you can't improve it.
If you can't roll back, you can't ship safely.

Observability is not optional. It's the foundation of operational control.

---

## When to Use This Section

- You're building operational runbooks for an AI system
- You're defining SLOs and escalation paths
- You're preparing for an enterprise security review
- You need to explain your operational model to a customer or auditor
