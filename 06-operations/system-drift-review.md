# System Drift Review

> **Read this when:** Conducting your quarterly architecture review, or after noticing unexplained changes in system behavior.
>
> **Time:** 2-4 hours with your team.
>
> **After reading:** You will have identified drift in cost, quality, control surface, and architecture.
>
> **Prerequisites:** Access to cost data, quality metrics, and user behavior analytics.

---

Quarterly review template for detecting and correcting system drift before it becomes a failure mode.

---

## Review Period

| Field | Value |
|-------|-------|
| Period | Q_ 20__ |
| Review date | |
| Facilitator | |
| Attendees | |

---

## 1. Cost Drift

Has the cost structure changed?

### Metrics

| Metric | Start of Quarter | End of Quarter | Delta |
|--------|------------------|----------------|-------|
| Cost per successful outcome | | | |
| Hidden recompute ratio | | | |
| Cost per active user | | | |
| Inference cost as % of revenue | | | |

### Analysis

**Did cost per outcome rise?** [ ] Yes [ ] No

If yes, what drove it?
- [ ] Increased model costs
- [ ] Increased recompute
- [ ] Increased orchestration overhead
- [ ] Increased retry rates
- [ ] User behavior changes
- [ ] Other: ___________

**Action items:**

| Action | Owner | Timeline |
|--------|-------|----------|
| | | |

---

## 2. Quality Drift

Has output quality changed?

### Metrics

| Metric | Start of Quarter | End of Quarter | Delta |
|--------|------------------|----------------|-------|
| Eval pass rate | | | |
| User regenerate rate | | | |
| User undo rate | | | |
| Escalation rate | | | |
| Support tickets (AI-related) | | | |

### Analysis

**Did quality metrics decline?** [ ] Yes [ ] No

If yes, what drove it?
- [ ] Model version change
- [ ] Prompt drift
- [ ] Data distribution shift
- [ ] Edge case accumulation
- [ ] Eval coverage gap
- [ ] Other: ___________

**Action items:**

| Action | Owner | Timeline |
|--------|-------|----------|
| | | |

---

## 3. Reliability Drift

Has system reliability changed?

### Metrics

| Metric | Start of Quarter | End of Quarter | Delta |
|--------|------------------|----------------|-------|
| Task completion rate | | | |
| Tool success rate | | | |
| Latency p95 | | | |
| Error rate | | | |
| Incident count | | | |

### Analysis

**Did reliability metrics decline?** [ ] Yes [ ] No

If yes, what drove it?
- [ ] External tool degradation
- [ ] Vendor reliability issues
- [ ] Increased load
- [ ] Circuit breaker issues
- [ ] Timeout configuration
- [ ] Other: ___________

**Action items:**

| Action | Owner | Timeline |
|--------|-------|----------|
| | | |

---

## 4. Traceability Drift

Can we still explain what happened?

### Assessment

| Question | Yes | No | Notes |
|----------|-----|----|-------|
| Can we reconstruct any output in under 10 minutes? | | | |
| Are all decision envelopes complete? | | | |
| Is policy versioning maintained? | | | |
| Are tool calls logged with context? | | | |
| Is evidence retention on schedule? | | | |

### Gaps Identified

| Gap | Impact | Remediation | Owner |
|-----|--------|-------------|-------|
| | | | |

---

## 5. Architecture Drift

Have architecture decisions drifted from original intent?

### Decision Review

| Decision | Original Intent | Current Reality | Drift? |
|----------|-----------------|-----------------|--------|
| State model | | | |
| Interaction contract | | | |
| Control plane ownership | | | |

### Reversibility Check

| Decision | Still reversible? | Cost to change now |
|----------|-------------------|-------------------|
| | | |

---

## 6. Dependency Drift

Have vendor or dependency risks changed?

### Vendor Assessment

| Vendor/Dependency | Risk Level Last Quarter | Risk Level Now | Change |
|-------------------|-------------------------|----------------|--------|
| | | | |
| | | | |

### New Dependencies Added

| Dependency | Why Added | Risk Assessment | Contingency |
|------------|-----------|-----------------|-------------|
| | | | |

---

## 7. Compliance Drift

Are we still audit-ready?

### Assessment

| Requirement | Status Last Quarter | Status Now | Gap? |
|-------------|---------------------|------------|------|
| Decision logging | | | |
| Data residency | | | |
| Retention policy | | | |
| Access control | | | |

---

## Summary

### Key Findings

1. 
2. 
3. 

### Priority Actions

| Priority | Action | Owner | Timeline |
|----------|--------|-------|----------|
| P0 | | | |
| P1 | | | |
| P2 | | | |

### Decisions Needed

| Decision | Options | Recommendation | Decision Maker |
|----------|---------|----------------|----------------|
| | | | |

---

## Next Review

| Field | Value |
|-------|-------|
| Next review date | |
| Owner | |
| Focus areas | |

---

**Review completed by:**
**Date:**
