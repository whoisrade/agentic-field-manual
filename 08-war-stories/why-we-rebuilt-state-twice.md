# Why We Rebuilt State Twice

> **Read this when:** Designing your state model, or struggling with expensive migrations.
>
> **Time:** 15 min to read. Use the decision factors for your own architecture.
>
> **After reading:** You will understand when to use document vs relational state and how to avoid costly migrations.

---

A story about state model decisions, reversibility windows, and the migrations that could have been avoided.

---

## Related Concepts

Prerequisites:
- [State Model](../02-architecture/state-model.md) - the foundational principles
- [Speculative State](../glossary.md) - why AI outputs are different from CRUD data
- Martin Kleppmann's work on [Designing Data-Intensive Applications](https://dataintensive.net/) - the definitive reference on data layer decisions

---

## Context

Two AI products. Different domains, different scales, different outcomes. Both taught me the same lesson about state model decisions.

---

## Product A: The Read-Heavy System

First product was an AI-powered content system. Low write volume, high read volume, predictable access patterns.

### The initial decision

Early on, I had to choose the data layer. Usage patterns were clear:
- Infrequent writes
- Frequent reads
- Predictable, low-cost queries
- No complex relational needs

I chose a document store. Scales reads effortlessly, cost-proportional to usage. For this pattern, it was ideal.

### Why it held

18 months later, the decision still held. The product scaled significantly without architectural changes. Costs grew linearly with value delivered.

**The lesson:** Match the data layer to observed usage patterns, not anticipated complexity.

---

## Product B: The Write-Heavy System

Second product was an AI-assisted editing tool. Very different pattern.

### The initial assumption

Early instinct was to use the same stack - it worked before, it should work again.

But I paused and looked at actual usage patterns:
- Sustained, debounced writes (users editing continuously)
- AI-generated content being written frequently
- Relational queries across multiple entity types
- Need for transactional consistency across AI operations

### The decision

Chose Postgres. Relational structure for the queries, transactional guarantees for AI operations, and a cost model that fit sustained write patterns better.

### Why it mattered

Six months in, we needed to add collaborative features. With a relational database, this was a migration. With a document store, it would have been a rebuild.

The initial decision - based on observing actual patterns, not assuming - saved months of work.

---

## The Counter-Example: When We Got It Wrong

Earlier in my career, I was involved with a product where the state model was designed for speed, not durability.

### The original design

```json
{
  "document_id": "uuid",
  "content": "full text",
  "updated_at": "timestamp"
}
```

Every AI generation overwrote the previous. No version history. No provenance.

### Why it made sense at the time

- Ship fast, iterate fast
- "We can add history later"
- Storage is cheap

### When it broke

Four months in. First enterprise conversation. The prospect asked: "Can we see the edit history for compliance purposes?"

Answer: No. Every generation overwrote the previous.

The conversation ended there.

### The migration

Adding version history after the fact required:
- Schema migration
- Backfill logic (partially reconstructing history from logs)
- Changes to every write path
- Testing across all AI operations

Three weeks of work that could have been two days at the start.

---

## The Pattern

State model decisions have a short reversibility window:

| Timeline | Effort to Change |
|----------|------------------|
| Week 1 | Hours |
| Month 1 | Days |
| Month 6 | Weeks |
| Month 12 | Months |

This pattern is well-documented in the software architecture literature. See: [ADR (Architecture Decision Records)](https://adr.github.io/) for a framework on documenting these decisions before they become irreversible.

### What closes the window

- Teams build on your schema
- External integrations depend on your structure
- Enterprise customers require audit trails
- Data volume makes migrations expensive

### The minimum viable AI state model

For any AI product, start with:

```json
{
  "output_id": "uuid",
  "trace_id": "uuid",
  "state": "draft | committed",
  "created_at": "timestamp",
  "prompt_version": "string",
  "model_version": "string"
}
```

This adds maybe a day at launch. It saves weeks later.

---

## The Lesson

Observe actual usage patterns before choosing infrastructure. Don't assume this product is like the last one.

The two products I described had opposite patterns:
- Product A: read-heavy, infrequent writes See: document store
- Product B: write-heavy, relational needs See: relational database

Both decisions were correct. The deciding factor was observation, not preference.

---

## Further Reading

- [Designing Data-Intensive Applications](https://dataintensive.net/) by Martin Kleppmann - Chapter 2 on data models
- [Architecture Decision Records](https://adr.github.io/) - a lightweight format for documenting architectural decisions
- [The Twelve-Factor App](https://12factor.net/) - particularly the sections on backing services and dev/prod parity

---

## The Templates

See: Use [Decision Record](../00-templates/decision-record.md) before committing to a state model
See: Reference [State Model](../02-architecture/state-model.md) for the principles

---

> *"Every decision has a reversibility window. Most teams don't notice it closing until it's shut."*
