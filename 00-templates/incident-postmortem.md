# Incident Post-Mortem

> **Use when:** After resolving any P0 or P1 incident, or any incident that affected customers.
>
> **Time:** 1-2 hours to complete. Schedule within 48 hours of resolution.
>
> **After completing:** You will have documented learnings and assigned preventive actions.

---

## Incident Summary

| Field | Value |
|-------|-------|
| Incident ID | |
| Title | |
| Severity | P0 / P1 / P2 |
| Duration | Start: _______ End: _______ Total: _______ |
| Impact | |
| Incident Lead | |
| Post-mortem Lead | |
| Post-mortem Date | |

---

## Timeline

Use UTC timestamps. Include every significant event.

| Time (UTC) | Event |
|------------|-------|
| | First signal detected |
| | Issue confirmed |
| | Incident declared |
| | First mitigation attempted |
| | Mitigation successful |
| | Root cause identified |
| | Resolution confirmed |
| | All-clear declared |

---

## Impact

### Customer Impact

| Metric | Value |
|--------|-------|
| Users affected | |
| Requests failed | |
| Revenue impact (if any) | |
| SLA breached? | [ ] Yes [ ] No |

### System Impact

| Metric | Value |
|--------|-------|
| Services affected | |
| Data loss | [ ] Yes [ ] No |
| Cost incurred | |

### Reputation Impact

| Audience | Impact |
|----------|--------|
| Customers notified | |
| Public communication | |
| Enterprise deals affected | |

---

## Root Cause

### What happened?

Write 2-3 sentences explaining the technical root cause.

### Why did it happen?

Use the 5 Whys technique:

1. **Why?** 
2. **Why?** 
3. **Why?** 
4. **Why?** 
5. **Why?** (This should reach the systemic cause)

### Contributing Factors

| Factor | How it contributed |
|--------|-------------------|
| | |
| | |
| | |

---

## Detection

| Question | Answer |
|----------|--------|
| How was the issue detected? | |
| Who detected it? | |
| How long after start was it detected? | |
| Why wasn't it detected sooner? | |

### Detection Improvements

| Improvement | Priority | Owner |
|-------------|----------|-------|
| | | |
| | | |

---

## Response

| Question | Answer |
|----------|--------|
| Was the incident playbook followed? | [ ] Yes [ ] No [ ] Partially |
| What worked well? | |
| What could have been faster? | |
| Was communication clear and timely? | |

### Response Improvements

| Improvement | Priority | Owner |
|-------------|----------|-------|
| | | |
| | | |

---

## Prevention

### Short-term Actions (This Sprint)

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| | | | [ ] Done [ ] In Progress |
| | | | [ ] Done [ ] In Progress |
| | | | [ ] Done [ ] In Progress |

### Long-term Actions (This Quarter)

| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| | | | [ ] Done [ ] In Progress |
| | | | [ ] Done [ ] In Progress |

---

## Lessons Learned

### What we did well

1. 
2. 
3. 

### What we need to improve

1. 
2. 
3. 

### Systemic issues to address

1. 
2. 

---

## Related Documents

| Document | Purpose |
|----------|---------|
| | Incident log |
| | Slack thread |
| | Monitoring dashboard |
| | Related PRs |

---

## Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Incident Lead | | | |
| Post-mortem Lead | | | |
| Engineering Manager | | | |

---

## Follow-up Schedule

| Date | Check |
|------|-------|
| +1 week | Short-term actions completed? |
| +1 month | Long-term actions on track? |
| +1 quarter | Systemic issues addressed? |

---

## Appendix: Relevant Metrics

Include screenshots or data from:

- [ ] Cost per outcome before/during/after
- [ ] Error rates
- [ ] Latency percentiles
- [ ] Tool success rates
- [ ] Any other relevant metrics

---

## Distribution

Share this post-mortem with:

- [ ] Engineering team
- [ ] Product team
- [ ] Leadership (P0/P1 only)
- [ ] Affected customers (if applicable)
