# API vs Owned

- **Use when**: Evaluating whether to run your own inference, or vendor costs are becoming unsustainable
- **Time**: 25 min read
- **Outcome**: Rent vs own decision framework, migration triggers
- **Related**: [From API to Owned in 90 Days](../08-war-stories/from-api-to-owned-in-90-days.md) ・ [Control Plane Ownership](../02-architecture/control-plane-ownership.md)

---

**The decision between renting inference and owning the compute.**

This is not just about cost. It's about control, compliance, and long-term margin.

---

## The Tradeoffs

| Dimension | API (Rented) | Owned GPU |
|-----------|-------------|-----------|
| Time to start | Hours | Weeks-months |
| Flexibility | High (swap models easily) | Lower (hardware lock-in) |
| Cost at low volume | Lower | Higher |
| Cost at high volume | Higher | Lower |
| Cost predictability | Variable | Fixed |
| Latency control | Limited | Full |
| Auditability | Vendor-dependent | Full |
| Data residency | Vendor's regions | Your regions |
| Incident control | Vendor-dependent | Self-controlled |

---

## When to Stay Rented

**Early-stage experimentation**
You're still figuring out what model works. Switching cost > infrastructure cost.

**Low, spiky demand**
You can't predict usage. Paying for idle GPUs is worse than paying per-call.

**Rapid model iteration**
New models drop monthly. You want to swap without re-provisioning.

**Uncertain product-market fit**
Don't invest in infra for a product that might pivot.

---

## When to Move to Owned

**Stable, predictable demand**
You know your daily/weekly usage patterns. Capacity planning is possible.

**Compliance requirements**
Data locality, auditability, or sovereignty requirements that vendors can't meet.

**Latency or reliability guarantees**
You need deterministic latency that vendors can't promise.

**Unit economics at stake**
If your margin depends on inference cost, and you're at scale, ownership is the only path to sustainable economics.

---

## The Cost Crossover

At some point, owned becomes cheaper than rented. Find your crossover:

```
monthly_api_cost = avg_daily_calls × 30 × cost_per_call
monthly_owned_cost = (gpu_cost + ops_cost + depreciation) / utilization

crossover_point = monthly_owned_cost / cost_per_call
```

If your daily calls exceed the crossover point, owned is cheaper.

Typical crossover for a single A100: ~$3-5K/month in API spend, assuming 70%+ utilization.

---

## The Hybrid Path

You don't have to choose all-or-nothing:

**1. Own the baseline, rent the spikes**
- Owned infrastructure handles predictable daily load
- API handles overflow and experimentation

**2. Own latency-critical, rent the rest**
- User-facing inference on owned hardware
- Batch processing on API

**3. Own regulated, rent unregulated**
- Sensitive data on owned infrastructure (enterprise customers often require this)
- Non-sensitive on API

**4. Own for iteration speed**
- I've seen teams launch on Vercel to maximize iteration speed, then build custom Kubernetes clusters when runtime isolation became key for enterprise adoption
- The first approach is correct for finding product-market fit
- The second is correct when compliance and isolation become requirements

---

## The Transition

See: See [From API to Owned in 90 Days](../08-war-stories/from-api-to-owned-in-90-days.md)

The key steps:
1. Identify workloads that justify ownership
2. Model cost at current and 10x volume
3. Design for hybrid (don't go 100% owned immediately)
4. Plan the migration before you're locked into API contracts
5. Build ops capability before you need it

---

## The Litmus Test

> If your product margin depends on inference cost, do you have an owned path in the roadmap?

If the answer is "we'll figure it out when we scale," you're already behind.

---

> *"API is a phase, not a destination. The earlier you plan your exit, the cheaper it is."*
