# Latency and SLO Coupling

- **Use when**: Users are complaining about speed, or retries are spiking without traffic increase
- **Time**: 15 min read
- **Outcome**: Latency-behavior feedback loop understanding, break patterns
- **Related**: [Metrics Reference](../07-examples/metrics-reference.md) ・ [Control Surface Drift](../01-failure-modes/control-surface-drift.md)

---

**The feedback loop where latency changes user behavior, and behavior changes system load.**

In AI products, latency is not just a metric. It's a behavioral driver.

---

## The Feedback Loop

```
High latency
    ↓
Users retry
    ↓
Retries increase load
    ↓
Load increases latency
    ↓
Latency reduces trust
    ↓
Reduced trust See: more retries
    ↓
(repeat)
```

This is SLO coupling: your latency SLO and your user behavior are entangled.

---

## The Effects

| Effect | Consequence |
|--------|-------------|
| High latency increases retries | More compute, more cost |
| Retries increase recompute | Margin erosion |
| Latency reduces trust | Users abandon or retry impatiently |
| Trust loss increases churn | Lost revenue |

---

## Control Strategy

**1. Define SLOs per user outcome, not per request**

A successful outcome might require multiple requests. Measure the whole thing:
- Time to first useful output
- Time to committed result
- User satisfaction at end of flow

**2. Identify where latency shifts behavior**

Instrument to detect:
- Retry rate by latency bucket
- Abandonment rate by latency
- User behavior changes after slow responses

**3. Gate expensive actions when SLOs degrade**

If the system is slow, don't make it worse:
```python
if current_latency > slo_threshold:
    queue_expensive_action()  # Don't execute now
    return cached_or_preview_response()
```

**4. Separate preview latency from commit latency**

Users tolerate different latency for different actions:
- Preview: needs to be fast (user is exploring)
- Commit: can be slower (user is waiting for result)

Design accordingly.

---

## The Litmus Test

> If your latency spikes are followed by user retries, you have SLO coupling.

Map the relationship. Build gates before the loop runs away.

---

> *"In AI products, latency is not just a metric. It's a behavioral driver."*
