# Margin Fragility

**Unit economics degrade as usage scales, often without a clear cause.**

Your product can be "successful" and still become unprofitable. Margin fragility is when growth makes you poorer.

---

## The Drivers

1. **Rising recompute per user** - users develop expensive habits
2. **Increased orchestration overhead** - multi-agent systems multiply calls
3. **Safety and compliance layers added late** - retrofit is expensive
4. **API pricing volatility** - vendor changes break your model

---

## The Signals

Measure these weekly:

| Signal | Threshold |
|--------|-----------|
| Cost per successful outcome rising (traffic flat) | Any increase |
| Cache hit rate declining | > 15% drop quarter-over-quarter |
| Infrastructure spend outpacing gross margin | Any sustained period |

---

## The Cost

The uncomfortable question: "Why is our inference spend up but output volume isn't?"

I've investigated this pattern multiple times. The answer is almost always one of two things:

1. **Hidden recompute** - compute happening without creating user value (undo loops, auto-save triggers, silent retries)
2. **Context waste** - large parts of the AI context are identical across users but being recomputed every time

The fix for #2 is often straightforward: implement shared system and tool-prompt caching. If large parts of context are identical across users, cache them. This can reduce per-conversation cost significantly without affecting response quality.

See: Read the full story: [The Undo Button That Killed Our Margin](../war-stories/the-undo-button-that-killed-our-margin.md)

---

## The Fix

**1. Track cost per successful outcome, not per request**

The formula:
```
cost_per_outcome = (inference_cost + orchestration_overhead + retry_cost) / successful_outputs
```

If this number rises while traffic is flat, you have hidden recompute.

**2. Eliminate hidden recompute**

Sources to investigate:
- Silent retries
- Context invalidation from user actions
- Partial failures that restart tool chains
- Auto-saves triggering full pipeline runs

**3. Treat pricing, UX, and infra as one economic system**

Your margin is not set by your model choice. It's set by the interaction between:
- What users do (UX)
- What that triggers (system)
- What that costs (infra)

Optimize all three together.

**4. Build a roadmap for inference ownership**

If margin depends on inference cost, you need a plan for ownership. API-only is a phase, not a destination.

See: See [API vs Owned](../economics/api-vs-owned.md)

---

## The Margin Fragility Test

> At 10x usage, do your unit economics improve, stay flat, or collapse?

| Answer | What It Means |
|--------|--------------|
| Improve | You have scale |
| Flat | You have a business |
| Collapse | You have a demo |

If you can't model this, you're not ready for growth.

---

## The Template

See: Use the [Cost Model](../economics/cost-model.md) to instrument your system
See: Run the [System Drift Review](../templates/system-drift-review.md) to find recompute sources

---

## The Litmus Test

> Can you show stable or improved unit economics at 10x usage in a simple model?

If the answer is "we haven't modeled that," you have margin fragility. You just haven't felt it yet.

---

> *"AI systems don't fail gracefully. They fail silently, then expensively, then catastrophically."*
