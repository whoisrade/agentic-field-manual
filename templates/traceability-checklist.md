# Traceability Checklist

Use before shipping any major AI system change. If any item is unchecked, ship is blocked.

---

## Feature/Change

| Field | Value |
|-------|-------|
| **Feature name** | |
| **Owner** | |
| **Ship date** | |
| **Reviewer** | |

---

## Inputs

- [ ] All user actions generate a trace ID
- [ ] Inputs are versioned and logged
- [ ] Policies in effect are recorded
- [ ] Model version is recorded
- [ ] Prompt version is recorded

**Notes:**


---

## State

- [ ] State deltas are persisted (not just final state)
- [ ] Draft vs final state is explicit
- [ ] Provenance is attached to state
- [ ] Context envelope is stored with state
- [ ] Prior state is preserved on mutations

**Notes:**


---

## Actions

- [ ] Tool calls are logged with inputs/outputs
- [ ] Retries are recorded with cause
- [ ] Orchestration decisions are traceable
- [ ] Escalations are logged with owners
- [ ] Failures are recorded with context

**Notes:**


---

## Outputs

- [ ] Output includes trace ID
- [ ] Decision rationale is stored
- [ ] Human approvals are captured when required
- [ ] Output is tied to policy version
- [ ] Output is tied to model version

**Notes:**


---

## Audit

- [ ] A random output can be reconstructed end-to-end
- [ ] Evidence is retained for compliance windows
- [ ] Audit trail is reproducible without live systems
- [ ] Reconstruction has been tested (not just designed)

**Notes:**


---

## Blockers

| Unchecked Item | Reason | Remediation | Owner |
|----------------|--------|-------------|-------|
| | | | |
| | | | |

---

## Ship Decision

- [ ] All items checked - approved to ship
- [ ] Items unchecked but risk accepted (document below)
- [ ] Blocked - fix required before ship

**Risk acceptance notes (if applicable):**


**Accepted by:**

---

## The Litmus Test

> Pick a random output from this feature. Can you reconstruct inputs, tool calls, and policy versions in under 10 minutes?

---

*Checklist completed by:*
*Date:*
*Approved by:*
