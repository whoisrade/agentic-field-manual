# How This Compares to Alternatives

> [!NOTE]
> **Read this when:** Evaluating whether to use this manual vs other resources.

| | |
|---|---|
| **Time** | 5 min read |
| **Outcome** | Clarity on when to use this manual vs alternatives |
| **Related** | [Adoption Guide](ADOPTION.md) ・ [README](README.md) |

---

## What This Manual Is

**Operational patterns and decision frameworks** for production AI systems.

It is:
- Technology-agnostic (works with any LLM provider, any language)
- Focused on operations, not building
- Designed for systems already in production or about to ship
- Opinionated based on real production experience

It is not:
- A framework or library you install
- Vendor-specific documentation
- A tutorial on building AI applications
- An academic treatment of AI safety

---

## Comparison Matrix

| Resource | Focus | Best For | Gaps |
|----------|-------|----------|------|
| **This Manual** | Operations at scale | Principal engineers running production AI | No code framework, requires implementation |
| **LangSmith/LangChain** | Tracing and debugging | Teams using LangChain, quick observability | Vendor lock-in, LangChain-specific |
| **Braintrust** | Evals and testing | Eval-first development, prompt iteration | Less focus on operations/economics |
| **Weights & Biases** | Experiment tracking | ML teams tracking training runs | More ML-focused than LLM app-focused |
| **Datadog LLM Observability** | Monitoring | Teams already on Datadog | Generic, less prescriptive |
| **Provider Docs** (OpenAI, Anthropic) | API usage | Understanding API capabilities | No operational guidance |
| **Academic Papers** | Research | Deep understanding of techniques | Not actionable for production |

---

## When to Use This Manual

**Use this manual when:**

- You need to explain a production incident to leadership
- Your AI costs are higher than expected and you don't know why
- An enterprise customer is asking audit questions you can't answer
- You're inheriting a system and need to assess its operational health
- You're about to ship and want a pre-flight checklist
- You need conversation scripts for stakeholder communication

**Use something else when:**

- You need a tracing SDK (use LangSmith, Datadog, or roll your own)
- You want a complete framework (use LangChain, LlamaIndex, etc.)
- You're doing research, not production
- You need provider-specific optimization (use provider docs)

---

## This Manual + Other Tools

This manual is complementary to tooling. Here's how they work together:

### With LangSmith/LangFuse

LangSmith gives you the **tracing infrastructure**. This manual tells you **what to trace and why it matters**.

```
LangSmith: "Here's your trace visualization"
This Manual: "Here's why trigger_type matters and how to use it to find hidden recompute"
```

### With Braintrust

Braintrust gives you **eval infrastructure**. This manual tells you **what to eval, when to gate on it, and how to handle failures**.

```
Braintrust: "Here's your eval pass/fail rate"
This Manual: "Here's how to interpret that rate and what to do when it drops"
```

### With Observability Platforms

Datadog/New Relic/Grafana give you **dashboards and alerting**. This manual tells you **which metrics to track and what thresholds to set**.

```
Datadog: "Alert when metric exceeds threshold"
This Manual: "Hidden recompute ratio above 20% is warning, above 40% is critical"
```

### With Provider APIs

OpenAI/Anthropic/etc. give you **model capabilities**. This manual tells you **how to wrap those capabilities for production operation**.

```
OpenAI: "Here's how to use function calling"
This Manual: "Here's how to build circuit breakers around function calling"
```

---

## What's Unique About This Manual

### 1. Economics-First Perspective

Most AI documentation ignores cost. This manual treats cost as a first-class concern:
- Cost per outcome (not cost per call)
- Hidden recompute tracking
- Margin fragility analysis
- Capacity planning

### 2. Operational Reality

Written from operating systems with 1.5M+ MAU, not demos. Patterns come from incidents, not theory.

### 3. Stakeholder Communication

Includes conversation scripts, board explainers, and stakeholder glossaries. Technical patterns are necessary but not sufficient.

### 4. Failure Mode Taxonomy

Four specific failure modes (legibility loss, control surface drift, auditability gap, margin fragility) that map to observable symptoms. Not generic "things can go wrong."

### 5. Irreversible Decision Framework

Explicit treatment of decisions that become hard to reverse: state model, interaction contract, control plane ownership.

---

## Mapping to Common Frameworks

If you're familiar with other frameworks, here's how concepts map:

| This Manual | LangChain/LangSmith | Braintrust | Traditional SRE |
|-------------|---------------------|------------|-----------------|
| Trace ID | Run ID | Log ID | Trace ID |
| Decision Envelope | Run metadata | Eval record | Span + context |
| Hidden Recompute | N/A | N/A | Retry metrics |
| Trigger Type | N/A | N/A | Request source |
| Legibility Loss | Debugging difficulty | Eval failure | Incident RCA time |
| Cost per Outcome | Token cost | Eval cost | Cost per transaction |

---

## Integration Recommendations

### Minimal Stack

1. **This manual** for patterns and decision frameworks
2. **Your observability platform** (Datadog, Grafana, etc.) for dashboards
3. **Provider SDK** (OpenAI, Anthropic, etc.) for inference

### Recommended Stack

1. **This manual** for patterns and decision frameworks
2. **LangFuse or LangSmith** for tracing (open source option: LangFuse)
3. **Braintrust or custom** for evals
4. **Your observability platform** for alerting
5. **Postgres** for decision envelope storage (see [schema](07-examples/traceability-postgres-schema.sql))

### Enterprise Stack

1. **This manual** for patterns and decision frameworks
2. **Custom tracing** built on your platform (for data residency)
3. **Custom eval infrastructure** (for IP protection)
4. **Full decision envelope system** (for audit compliance)
5. **Owned inference** where required (see [API vs Owned](03-economics/api-vs-owned.md))

---

## Related

- [Adoption Guide](ADOPTION.md) - How to implement these patterns
- [ASSESS.md](ASSESS.md) - Evaluate your current state
- [Control Plane Ownership](02-architecture/control-plane-ownership.md) - Build vs buy decisions
