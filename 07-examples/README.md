# Examples

Production-ready code you can adapt for your stack.

---

## When to Use This Section

| Situation | Start Here | Time |
|-----------|------------|------|
| Need to fix common anti-patterns | [before-after-patterns.md](before-after-patterns.md) | 20 min to learn, 1-2 hours to fix |
| Need to block prompt injection | [guardrails.py](guardrails.py) | 2-4 hours to adapt |
| Need to coordinate multiple agents | [orchestrator.py](orchestrator.py) | 4-8 hours to adapt |
| Need to trace decisions after the fact | [fastapi-provenance-middleware.py](fastapi-provenance-middleware.py) | 2-4 hours to adapt |
| Need to gate deployments on quality | [eval-gate.yml](eval-gate.yml) | 1-2 hours to adapt |
| Need to find margin leaks | [diagnostic-queries.sql](diagnostic-queries.sql) | 30 min to run |
| Need to track any metric | [metrics-reference.md](metrics-reference.md) | Reference as needed |

> [!NOTE]
> These examples use Python, PostgreSQL, and GitHub Actions. Translate the patterns, not the syntax.

---

## What's Here

### Infrastructure

| Example | What You Get |
|---------|--------------|
| [guardrails.py](guardrails.py) | Layered defense: regex rules, classifier, LLM-as-guard |
| [orchestrator.py](orchestrator.py) | Multi-agent orchestrator with circuit breakers and checkpoints |
| [fastapi-provenance-middleware.py](fastapi-provenance-middleware.py) | Request tracing and decision envelope capture |

### Evaluation

| Example | What You Get |
|---------|--------------|
| [llm-as-judge-prompts.md](llm-as-judge-prompts.md) | Production prompts for helpfulness, accuracy, safety |
| [eval-gate.yml](eval-gate.yml) | GitHub Action that blocks deploy on eval failure |

### Data and Queries

| Example | What You Get |
|---------|--------------|
| [diagnostic-queries.sql](diagnostic-queries.sql) | Complete health check queries - run in 30 min |
| [diagnostic-queries.sql](diagnostic-queries.sql) | SQL for cost, health checks, and dashboard queries |
| [traceability-postgres-schema.sql](traceability-postgres-schema.sql) | Database schema for decision envelopes |

### Reference

| Example | What You Get |
|---------|--------------|
| [before-after-patterns.md](before-after-patterns.md) | 7 common anti-patterns with copy-paste fixes |
| [decision-envelope-schema.json](decision-envelope-schema.json) | JSON schema for provenance data |
| [metrics-reference.md](metrics-reference.md) | Formulas and queries for every metric in this manual |

---

## How to Use

1. **Find the example that matches your problem** in the table above
2. **Read the code and comments** - they explain WHY, not just WHAT
3. **Copy and adapt** for your stack - translate patterns, not syntax
4. **Start minimal** - every example has a minimum viable version. Ship that first.

---

## After Using

You will have:
- Working guardrails for your production system
- Multi-agent orchestration with cost control
- Provenance tracking for auditability
- Eval gates blocking bad deploys
- Queries for cost investigation

---

## Design Principles

| Principle | Application |
|-----------|-------------|
| Cheap operations first | Guardrails: regex (1ms) before classifier (50ms) before LLM (2000ms) |
| Fail open with logging | If a guard errors, continue with a log. Silent blocks are worse. |
| Circuit breakers everywhere | Any external dependency can fail. Prevent cascades. |
| Cost tracking at orchestration | Individual agents do not know global budget. Orchestrator enforces it. |
| Checkpoints for resumability | Save state after each step. Failures resume, not restart. |

---

## Production Checklist

Before deploying these patterns:

- [ ] Secrets management - API keys not in code
- [ ] Rate limiting - Do not exhaust quotas
- [ ] Structured logging with trace IDs
- [ ] Metrics for latency, cost, error rates
- [ ] Alerts for circuit breaker trips, budget exceeded, eval failures
- [ ] Graceful degradation defined for each component

---

## What's NOT Here

Solved problems you should use your existing stack for:

- Authentication/authorization
- Database connection pooling
- Production logging (Datadog, etc.)
- Error tracking (Sentry, Bugsnag)

Do not reinvent these.

---

## Related

- [Orchestration](../06-operations/orchestration.md) - Conceptual overview
- [Safety Surface](../06-operations/safety-surface.md) - Guardrails design
- [Pre-Ship Checklist](../00-templates/pre-ship-checklist.md) - Requirements before deploying
