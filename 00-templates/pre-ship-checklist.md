# Pre-Ship Checklist

> **Use when:** Deploying any agentic feature or major AI system change.
>
> **Time:** 1-2 hours to complete thoroughly.
>
> **After completing:** You will have a signed-off deployment with all traceability gates met.

---

Use before deploying any agentic feature. If any critical item is unchecked, deployment is blocked.

---

## Feature Overview

| Field | Value |
|-------|-------|
| Feature name | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Owner | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Target ship date | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Reviewer | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## 1. Traceability

Every output must be explainable after the fact.

### Inputs

- [ ] All user actions generate a trace ID
- [ ] Inputs are versioned and logged
- [ ] Model version is recorded with each request
- [ ] Prompt version is recorded with each request
- [ ] Active policies are recorded at decision time

<details>
<summary><strong>Example: Minimum input logging</strong></summary>

```json
{
  "trace_id": "uuid",
  "timestamp": "iso8601",
  "user_action": "generate",
  "user_id": "string",
  "session_id": "string",
  "model_version": "gpt-4-0125-preview",
  "prompt_version": "v2.3.1",
  "policies_active": ["content-filter-v2", "rate-limit-standard"]
}
```

</details>

### State

- [ ] State deltas are persisted (not just final state)
- [ ] Draft vs committed state is explicit
- [ ] Provenance is attached to all state changes
- [ ] Prior state is preserved on mutations

<details>
<summary><strong>Example: State with provenance</strong></summary>

```json
{
  "output_id": "uuid",
  "state": "draft | committed | rejected",
  "created_at": "iso8601",
  "prior_state_id": "uuid | null",
  "provenance": {
    "trace_id": "uuid",
    "triggered_by": "user_action | system | retry",
    "model_version": "string",
    "prompt_version": "string"
  }
}
```

</details>

### Actions

- [ ] Tool calls are logged with inputs and outputs
- [ ] Retries are recorded with cause
- [ ] Orchestration decisions are traceable
- [ ] Failures are recorded with full context

### Outputs

- [ ] Output includes trace ID for correlation
- [ ] Decision rationale is stored (or reconstructable)
- [ ] Human approvals are captured when required
- [ ] Output is tied to policy and model versions

---

## 2. Auditability

Can you prove what the system knew and why it acted?

- [ ] A random output can be reconstructed end-to-end
- [ ] Evidence is retained for compliance windows (check your requirements)
- [ ] Reconstruction does not require live systems
- [ ] Reconstruction has been tested, not just designed

<details>
<summary><strong>Test: Reconstruction verification</strong></summary>

Pick 3 random outputs from the last 24 hours. For each:

1. Retrieve the decision envelope
2. Identify the inputs, model version, and prompt version
3. Confirm you could reproduce the decision context without calling any external APIs

If any fail, you have an auditability gap.

</details>

---

## 3. Cost Controls

Do you know what this feature will cost at 10x usage?

- [ ] Cost per successful outcome is measurable
- [ ] Hidden recompute sources are identified (retries, auto-saves, undo flows)
- [ ] Cost caps or alerts are in place
- [ ] Cost at 10x usage has been modeled

| Metric | Estimate |
|--------|----------|
| Expected cost per outcome | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Expected outcomes per day | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Daily cost at current usage | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| Daily cost at 10x usage | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## 4. Failure Handling

What happens when things break?

- [ ] Circuit breakers are configured for external dependencies
- [ ] Retry limits are set (not unlimited)
- [ ] Graceful degradation path exists
- [ ] Failure states are logged with context
- [ ] Rollback procedure is documented

---

## 5. Safety

What could go wrong and how is it prevented?

- [ ] Input validation is in place
- [ ] Output filtering is in place (if applicable)
- [ ] Rate limits are configured
- [ ] Escalation path exists for flagged content

---

## Blockers

| Unchecked Item | Reason | Remediation | Owner |
|----------------|--------|-------------|-------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## Ship Decision

- [ ] All items checked - approved to ship
- [ ] Items unchecked but risk accepted (document below)
- [ ] Blocked - fix required before ship

**Risk acceptance notes (if applicable):**

**Accepted by:**

---

## Verification

The test for this checklist:

Pick a random output from this feature. Can you reconstruct inputs, tool calls, and policy versions in under 10 minutes?

If yes, ship. If no, fix.

---

**Checklist completed by:**
**Date:**
**Approved by:**
