# Control Plane Ownership

**Who can see, change, and guarantee system behavior under pressure.**

Control plane ownership determines whether you're running your system or your vendors are.

---

## Why It's Hard to Undo

Ownership decisions harden because:
- Vendor contracts have lock-in periods
- Data migrations are expensive and risky
- Teams build operational muscle around specific platforms
- Compliance certifications are tied to specific architectures

By the time you realize you need ownership, the exit cost is high.

---

## The Problem

External dependencies become your default operating model. If you don't own the control plane, you can't guarantee:
- Auditability at the infrastructure layer
- Incident response timelines
- Resilience testing without vendor permission
- Stable pricing and capacity

When a vendor outage becomes your incident, you don't own the plane.

---

## The Signals

Measure these quarterly:

| Signal | Threshold |
|--------|-----------|
| Failover requires vendor support | Any critical path |
| Cannot provide infra-level audit trails on request | Any regulated customer |
| Vendor pricing/policy changes shift your SLOs | Any occurrence |
| Cannot test resilience without vendor permission | Any critical system |

---

## Owned vs Rented

| Dimension | Rented (API) | Owned |
|-----------|-------------|-------|
| Speed to start | Fast | Slow |
| Flexibility | High | Lower |
| Cost at scale | Unpredictable | Predictable |
| Auditability | Limited | Full |
| Incident control | Vendor-dependent | Self-controlled |
| Compliance | Vendor's certifications | Your certifications |

---

## When to Own

**Stay rented when:**
- You're early-stage and experimenting
- Demand is low and spiky
- Product-market fit is uncertain
- You need rapid model iteration

**Move to owned when:**
- Demand is stable and predictable
- Compliance requires data locality or auditability
- You need deterministic latency guarantees
- Unit economics depend on inference cost
- A vendor outage would be a regulatory incident

---

## The Transition

The best time to plan your exit is before you're locked in.

**1. Identify critical workloads early**

Which workloads require isolation, auditability, or guaranteed latency? These are candidates for ownership.

**2. Separate control plane from execution plane**

Even if you rent execution (inference), you can own the orchestration, logging, and policy layers.

**3. Build runbooks that don't require vendor escalation**

For every critical path, document: "What do we do if the vendor is unreachable?"

**4. Model cost at 10x before committing**

If rented pricing breaks your unit economics at scale, ownership isn't optional - it's inevitable. Plan for it.

See: See [From API to Owned in 90 Days](../war-stories/from-api-to-owned-in-90-days.md)

---

## The Template

See: Use the [Decision Log](../templates/decision-log.md) before committing to a platform
See: See [API vs Owned](../economics/api-vs-owned.md) for the cost analysis

---

## The Litmus Test

> If a vendor outage becomes a regulatory incident for you, do you own the control plane?

If your answer is "we'd have to escalate to the vendor," you don't own it.

---

> *"Treat managed platforms as a phase, not a destination. The earlier you design an exit, the cheaper it is."*
