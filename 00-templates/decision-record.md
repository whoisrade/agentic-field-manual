# Decision Record

> **Use when:** Making or recording any architecture decision that will be hard to reverse.
>
> **Time:** 15-30 min for routine decisions. 30-60 min for complex decisions.
>
> **After completing:** You will have a documented decision with options, trade-offs, and owner.

---

A decision is "hard to reverse" when more than two teams or systems depend on it, or when changing it requires data migration.

---

## Decision Summary

| Field | Value |
|-------|-------|
| Title | |
| Date | |
| Owner | |
| Impact area | Cost / Quality / Compliance / Reliability |
| Reversibility window | Days / Weeks / Months |

---

## Context

**What problem are we solving?**

*Be specific. "Improve performance" is not a problem statement. "Reduce p95 latency from 3s to under 1s for the summarization endpoint" is.*

**What constraints exist now?**

*Technical constraints, team capacity, timeline, budget, compliance requirements.*

**What changes if usage is 10x?**

*This question surfaces hidden assumptions about cost, latency, and architecture.*

---

## Options Considered

### Option A

**Description:**

**Pros:**
- 

**Cons:**
- 

**Risk:**

**Estimated effort:**

### Option B

**Description:**

**Pros:**
- 

**Cons:**
- 

**Risk:**

**Estimated effort:**

### Option C (if applicable)

**Description:**

**Pros:**
- 

**Cons:**
- 

**Risk:**

**Estimated effort:**

---

## Decision

**Which option?**

**Why this option?**

*What evidence supports this choice?*

**What does it trade off?**

*Every decision trades something. Be explicit.*

**What breaks if this is wrong?**

*How would you know? What is the blast radius?*

---

## Reversibility Analysis

**When does this become expensive to reverse?**

*Be specific: after X users, after Y months, after Z teams depend on it.*

**What signals tell us we should revisit?**

*Metrics, user feedback, cost thresholds, team pain.*

**Dependencies that will lock us in:**

| Dependency | Why it locks us in |
|------------|--------------------|
| | |
| | |

---

## Rollback Plan

**How do we unwind this in under 30 days?**

**What data migration or behavior change is required?**

**Who owns the rollback if needed?**

---

## Success Criteria

**What measurable outcome confirms this decision?**

*Specific metrics, thresholds, and timelines.*

| Checkpoint | Date | Owner | Success metric |
|------------|------|-------|----------------|
| | | | |
| | | | |

---

## Decision Threshold

**What concrete signal would force us to choose a different option?**

*Example: "If cost per outcome exceeds $0.05 within 30 days, we revisit Option B."*

---

## The Test

> If this decision is wrong, can you explain how you will detect it within one quarter?

If you cannot answer this, the decision needs more work.

---

**Decision logged by:**

**Date:**

**Reviewed by:**

---

## Quick Format (for routine decisions)

For smaller decisions, use this abbreviated format:

```markdown
## [Title] - [Date]

**Context:** [1-2 sentences on the problem]
**Decision:** [What we chose]
**Rationale:** [Why]
**Trade-offs:** [What we gave up]
**Revisit if:** [Trigger for reconsideration]
**Owner:** [Name]
```
