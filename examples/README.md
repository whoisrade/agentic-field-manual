# Examples

Production-ready implementations you can adapt for your stack.

These aren't toy examples - they're the patterns used in systems processing millions of requests. Fork them, adapt them, ship them.

---

## What's Here

### Infrastructure

| Example | What It Shows | Lines |
|---------|--------------|-------|
| [guardrails.py](guardrails.py) | Layered defense system (rules See: classifier See: output guards) | 450+ |
| [orchestrator.py](orchestrator.py) | Multi-agent orchestrator with circuit breakers and checkpoints | 500+ |
| [fastapi-provenance-middleware.py](fastapi-provenance-middleware.py) | Request tracing and provenance capture | 400+ |

### Evaluation

| Example | What It Shows | Lines |
|---------|--------------|-------|
| [llm-as-judge-prompts.md](llm-as-judge-prompts.md) | Production eval prompts (helpfulness, accuracy, safety, comparison) | 300+ |
| [eval-gate.yml](eval-gate.yml) | GitHub Action that blocks deploy on eval failure | 350+ |

### Data & Queries

| Example | What It Shows | Lines |
|---------|--------------|-------|
| [cost-attribution-queries.sql](cost-attribution-queries.sql) | SQL for cost per outcome, hidden recompute, margin analysis | 250+ |
| [recompute-dashboard-queries.md](recompute-dashboard-queries.md) | Dashboard queries for recompute tracking | 280+ |
| [traceability-postgres-schema.sql](traceability-postgres-schema.sql) | Database schema for provenance | 240+ |

### Schemas

| Example | What It Shows | Lines |
|---------|--------------|-------|
| [decision-envelope-schema.json](decision-envelope-schema.json) | JSON schema for the decision envelope concept | 220+ |

---

## How to Use These

### 1. Start with the problem you're solving

| If You Need... | Start Here |
|----------------|------------|
| Block prompt injection in production | [guardrails.py](guardrails.py) |
| Coordinate multiple agents reliably | [orchestrator.py](orchestrator.py) |
| Gate deployments on quality | [eval-gate.yml](eval-gate.yml) + [llm-as-judge-prompts.md](llm-as-judge-prompts.md) |
| Find where margin is leaking | [cost-attribution-queries.sql](cost-attribution-queries.sql) |
| Trace what happened after the fact | [fastapi-provenance-middleware.py](fastapi-provenance-middleware.py) |

### 2. Adapt to your stack

These examples use:
- **Python 3.11+** with asyncio
- **PostgreSQL** for data storage
- **GitHub Actions** for CI/CD

Translate the patterns, not the syntax.

### 3. Start minimal, then extend

Every example has a "minimum viable" version. Ship that first. Add complexity when you need it.

---

## Design Principles in These Examples

**1. Cheap operations first**

Guardrails: regex rules (1ms) See: classifier (50ms) See: LLM-as-guard (2000ms)

Always order operations by cost. Reject early when possible.

**2. Fail open with logging, not fail closed silently**

If a guard errors, the request continues (with a log). Silent blocks are worse than missed attacks because you can't debug what you can't see.

**3. Circuit breakers everywhere**

Any external dependency (model API, tool, database) can fail. The orchestrator pattern shows how to prevent cascade failures.

**4. Cost tracking at the orchestration layer**

Individual agents don't know the global budget. The orchestrator enforces it. This prevents "death by a thousand retries."

**5. Checkpoints for resumability**

Long-running operations should be resumable. The orchestrator saves state after each step, so failures don't restart from zero.

---

## Production Checklist

Before deploying these patterns:

- [ ] **Secrets management** - API keys not in code
- [ ] **Rate limiting** - Don't blow your quotas
- [ ] **Logging** - Structured logs with trace IDs
- [ ] **Metrics** - Latency, cost, error rates per component
- [ ] **Alerts** - Circuit breaker trips, budget exceeded, eval failures
- [ ] **Graceful degradation** - What happens when a component fails?

---

## What's NOT Here

These examples intentionally don't include:

- **Authentication/authorization** - Use your existing auth system
- **Database connection pooling** - Use your ORM/connection manager
- **Production logging** - Use your observability stack (Datadog, etc.)
- **Error tracking** - Use Sentry, Bugsnag, etc.

These are solved problems. Don't reinvent them.

---

## Contributing Examples

If you've adapted these patterns and want to contribute back:

1. Keep examples self-contained (single file when possible)
2. Include extensive comments explaining WHY, not just WHAT
3. Show the minimum viable version, not every possible feature
4. Include production notes (what to watch out for)
