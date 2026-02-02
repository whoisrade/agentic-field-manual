# First 48 Hours

Crisis playbook for when margin is collapsing, quality is dropping, or the system is breaking.

Use this when you don't have time for a full investigation. Act first, understand later.

---

## Hour 0-2: Triage

### Identify the signal

| Question | Answer |
|----------|--------|
| What metric is broken? | |
| When did it start? | |
| What changed around that time? | |
| How bad is it? (1-10) | |
| Is it getting worse? | |

### Immediate containment

- [ ] Can we rollback the last deploy?
- [ ] Can we disable the affected feature?
- [ ] Can we rate-limit the affected path?
- [ ] Can we route traffic away from the problem?

**Action taken:**


---

## Hour 2-8: Instrument

### Get visibility

- [ ] Cost per outcome for last 7 days (find the spike)
- [ ] Recompute ratio (total compute / successful outputs)
- [ ] Top 5 trigger types by cost
- [ ] Retry rates by tool/endpoint
- [ ] Latency percentiles (p50, p95, p99)

### Find the smoking gun

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Cost per outcome | | | |
| Recompute ratio | | | |
| Retry rate | | | |
| Latency p95 | | | |
| Cache hit rate | | | |

**Most likely root cause:**


---

## Hour 8-24: Fix the Bleeding

### Short-term mitigations

Pick the fastest path to stability:

- [ ] Cache the expensive path
- [ ] Gate the expensive action
- [ ] Reduce retry limits
- [ ] Increase rate limits
- [ ] Disable non-critical features
- [ ] Roll back recent changes

**Mitigation deployed:**


**Impact:**


---

## Hour 24-48: Understand

### Root cause analysis

| Question | Answer |
|----------|--------|
| What was the root cause? | |
| Why didn't we catch it earlier? | |
| What would have prevented this? | |
| Is this a symptom of a deeper problem? | |

### Long-term fixes

| Fix | Owner | Timeline | Priority |
|-----|-------|----------|----------|
| | | | |
| | | | |
| | | | |

---

## Communication

### Internal

| Stakeholder | Update sent? | By whom? |
|-------------|-------------|----------|
| CEO/CTO | | |
| Eng team | | |
| Product | | |
| Support | | |

### External (if customer-impacting)

| Stakeholder | Update sent? | By whom? |
|-------------|-------------|----------|
| Affected customers | | |
| Status page | | |
| Sales (for active deals) | | |

---

## Post-Incident

- [ ] Post-mortem scheduled
- [ ] Monitoring improved to catch this earlier
- [ ] Runbook updated
- [ ] This incident added to system drift review

---

## The Litmus Test

> Can you explain what happened, why, and what you're doing about it in 2 minutes?

Practice the explanation. You will need it.

---

*Incident lead:*
*Start time:*
*Resolution time:*
*Status:*
