# From API to Owned in 90 Days

- **Use when**: API costs are unsustainable, or evaluating whether to run your own inference
- **Time**: 20 min read
- **Outcome**: API vs owned decision framework, migration timeline
- **Related**: [API vs Owned](../03-economics/api-vs-owned.md) ・ [Control Plane Ownership](../02-architecture/control-plane-ownership.md)

---

A story about inference economics, infrastructure ownership, and the transition that changes your cost structure.

---

## Related Concepts

Prerequisites:
- [API vs Owned](../03-economics/api-vs-owned.md) - the decision framework
- [Margin Fragility](../01-failure-modes/margin-fragility.md) - why this matters for unit economics
- [Capacity Planning](../03-economics/capacity-planning.md) - forecasting demand for AI workloads

---

## Context

AI-powered productivity platform. The kind of product where users interact with AI frequently throughout their workday - not one-off queries, but sustained usage.

Growing revenue, but margins under pressure. The unit economics conversation was getting uncomfortable.

---

## The Problem

Inference costs were eating margin.

The pattern was familiar: early-stage, move fast, use API providers for everything. Makes sense when you're iterating on product-market fit.

But now usage was predictable. Patterns were stable. And API costs were growing faster than revenue.

The question: when does owned infrastructure make sense?

---

## The Analysis

### Step 1: Map the workload

First, I categorized the inference workload:

| Workload Type | % of Compute | Latency Requirement | Complexity |
|--------------|--------------|---------------------|------------|
| User-facing generation | ~40% | Low (streaming) | High |
| Background processing | ~35% | Flexible | Medium |
| Simple classification | ~25% | Low | Low |

Not all workloads are equal. Some justify API pricing. Some don't.

### Step 2: Identify what doesn't need cutting-edge

The simple classification tasks - routing, categorization, intent detection - were using the same expensive model as generation.

These tasks don't need the most expensive model. They need fast, cheap, good-enough.

### Step 3: Model the crossover point

For the background processing workload, owned infrastructure was significantly cheaper at our volume. For user-facing generation, the math was closer. API still made sense for spiky, latency-sensitive work.

This crossover analysis is covered in depth in various cloud economics resources. See [The Duckbill Group's work on cloud cost optimization](https://www.duckbillgroup.com/) for frameworks on when to buy vs rent.

---

## The Decision

Hybrid approach:
1. **Own the predictable, high-volume work** (background processing, classification)
2. **Rent the spiky, latency-critical work** (user-facing generation)
3. **Build the foundation now** for eventually owning more

---

## The 90-Day Execution

### Days 1-20: Infrastructure foundation

Set up Kubernetes cluster on dedicated infrastructure. The goal wasn't just this workload - it was building operational muscle for future workloads.

Key decisions:
- Tenant isolation from day one (enterprise requirement)
- Runtime sandboxing (security requirement)
- Autoscaling based on queue depth, not just CPU

### Days 21-40: Model selection and testing

For classification tasks, tested smaller open-source models. Found options that matched API quality at a fraction of the cost.

For background processing, used a mid-tier model. Slightly lower quality ceiling, but the use case was tolerant.

### Days 41-60: Gradual rollout

- Week 7: 10% of background processing to owned
- Week 8: 30%
- Week 9: 60%
- Week 10: 90%

Each step: monitor quality, latency, reliability. No degradation observed.

### Days 61-90: Optimization

- Implemented prompt caching: large parts of the context were identical across users
- Reduced per-request cost without affecting quality
- Added request coalescing for batch-friendly workloads

---

## The Results

### After 90 days

| Dimension | Before | After |
|-----------|--------|-------|
| Background processing cost | API pricing | ~70% reduction |
| Classification cost | API pricing | ~85% reduction |
| User-facing generation | API | API (unchanged) |
| Operational complexity | Lower | Higher (but manageable) |

### The hidden benefits

**Cost predictability:** Fixed infrastructure cost vs. variable API cost. Finance could actually forecast.

**Quality iteration:** Could fine-tune and experiment without per-call costs.

**Enterprise readiness:** Data stays on owned infrastructure. Opens doors that API-only couldn't.

**Future optionality:** The hardest part of ownership is building the operational foundation. Now it exists.

---

## What Made It Work

### 1. Hybrid, not binary

The goal wasn't "own everything." It was "own what makes economic sense."

User-facing generation stayed on API. The latency requirements and spiky traffic patterns favored rental. Background processing moved to owned. The predictable, high-volume pattern favored ownership.

### 2. Operational investment upfront

Didn't try to minimize infrastructure complexity. Built a proper Kubernetes setup with isolation, sandboxing, and monitoring from day one.

More work in month one. Less firefighting in month six.

### 3. Workload categorization

The insight was treating different workloads differently. Not all AI is equal. Classification doesn't need the same model as generation.

### 4. Gradual rollout

10% See: 30% See: 60% See: 90%

Each step was reversible. If quality degraded, roll back. It didn't.

---

## The Lesson

API vs. owned isn't a religious debate. It's a math problem.

The variables:
- Predictability of demand
- Latency requirements
- Compliance/data residency needs
- Operational capability
- Workload composition

For early-stage, high-uncertainty products: API makes sense. Iterate fast, don't build infrastructure you might not need.

For stable, high-volume, predictable workloads: owned makes sense. The economics shift.

The transition is easier than it looks - if you approach it as a workload-by-workload decision rather than all-or-nothing.

---

## Further Reading

- [The Duckbill Group](https://www.duckbillgroup.com/) - cloud cost optimization expertise
- [Kelsey Hightower's Kubernetes resources](https://github.com/kelseyhightower/kubernetes-the-hard-way) - understanding Kubernetes from first principles
- [vLLM](https://github.com/vllm-project/vllm) - high-throughput LLM serving
- [Modal](https://modal.com/) and [Replicate](https://replicate.com/) - serverless GPU alternatives to full ownership

---

## The Templates

See: Use [Decision Record](../00-templates/decision-record.md) before committing to infrastructure ownership
See: Reference [API vs Owned](../03-economics/api-vs-owned.md) for the framework

---

> *"API is a phase, not a destination. The earlier you plan your exit, the cheaper it is."*
