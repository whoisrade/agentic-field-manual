# Templates

Actionable documents you copy and fill in.

---

## When to Use

| Situation | Template | Time Required |
|-----------|----------|---------------|
| System is failing, margin collapsing, quality dropping | [Crisis Playbook](crisis-playbook.md) | 2-8 hours |
| Costs spiked unexpectedly | [Cost Spike Runbook](cost-spike-runbook.md) | 30-60 min |
| Weekly operations review | [Weekly Ops Checklist](weekly-ops-checklist.md) | 30 min |
| After resolving a P0/P1 incident | [Incident Post-Mortem](incident-postmortem.md) | 1-2 hours |
| Deploying an agentic feature | [Pre-Ship Checklist](pre-ship-checklist.md) | 1-2 hours |
| Making or recording an architecture decision | [Decision Record](decision-record.md) | 15-60 min |

---

## How to Use

1. Copy the template into your project docs (wiki, Notion, etc.)
2. Fill in all blank fields
3. Share with your team for review
4. Store in version control

---

## After Using These

| Template | You Will Have |
|----------|---------------|
| Crisis Playbook | Containment action taken, visibility into metrics, fix underway |
| Cost Spike Runbook | Root cause identified, mitigation applied, alert created |
| Weekly Ops Checklist | Early warning of drift, action items assigned |
| Incident Post-Mortem | Documented learnings, preventive actions assigned |
| Pre-Ship Checklist | Signed-off deployment with traceability gates met |
| Decision Record | Documented decision with options, trade-offs, and owner |

---

## Quick Diagnostics

Run these checks to assess your current state:

### Traceability

Pick a random output from yesterday. Can you explain it in under 10 minutes?

- Under 10 min: Healthy
- 10-60 min: Warning - see [Legibility Loss](../01-failure-modes/legibility-loss.md)
- Over 1 hour: Critical - use [Crisis Playbook](crisis-playbook.md)

### Economics

Do you know your cost per successful outcome?

- Yes, and stable or declining: Healthy
- Yes, but rising: Warning - see [Cost Investigation](../03-economics/cost-investigation.md)
- No: Critical - see [Cost Model](../03-economics/cost-model.md)

### Auditability

For any output, can you prove what the system knew at decision time?

- Yes, with evidence: Healthy
- Yes, with narrative: Warning - see [Auditability Gap](../01-failure-modes/auditability-gap.md)
- No: Critical - see [Audit Preparation](../04-compliance/audit-preparation.md)
