# Audit Preparation

> **Read this when:** An enterprise customer requests a security review, or you are preparing for a compliance audit.
>
> **Time:** 2-4 hours to complete the full preparation. Start at least 1 week before the audit.
>
> **After reading:** You will have all documentation ready, evidence queued, and talking points prepared.
>
> **Prerequisites:** You should have basic logging in place. If not, see [Auditability Gap](../01-failure-modes/auditability-gap.md) first.

---

Step-by-step process for preparing for enterprise security reviews and compliance audits.

Use this when a customer or regulator asks for evidence of how your AI system makes decisions.

---

## Pre-Audit Checklist

### Documentation Ready

- [ ] System architecture diagram showing data flows
- [ ] Decision logging schema documented
- [ ] Retention policies documented
- [ ] Data residency policies documented
- [ ] Incident response procedures documented

### Technical Capability

- [ ] Can reconstruct any decision from the last [retention period]
- [ ] Can prove data locality for any request
- [ ] Can demonstrate tenant isolation
- [ ] Can show policy enforcement logs

### Evidence Samples

- [ ] Sample decision envelope prepared
- [ ] Sample audit trail prepared
- [ ] Sample data deletion proof prepared

---

## Step 1: Understand What They Will Ask

### Common Enterprise Questions

| Category | Typical Questions |
|----------|-------------------|
| **Decision Making** | How does the AI make decisions? Can you show me why it produced a specific output? |
| **Data Handling** | Where is data stored? Who has access? How long is it retained? |
| **Model Governance** | How do you version and deploy models? What testing do you do? |
| **Security** | How do you prevent prompt injection? What input validation exists? |
| **Human Oversight** | When does a human review AI outputs? How is this enforced? |

### Prepare Answers With Evidence

For each category, prepare:
1. A written explanation (1 paragraph)
2. Technical documentation reference
3. Evidence sample (log, screenshot, or query result)

---

## Step 2: Prepare Decision Reconstruction

The core audit question is: "For any AI output, can you prove why it happened?"

### What You Need to Produce

For any random output, demonstrate:

| Component | Evidence |
|-----------|----------|
| Triggering action | User action log with timestamp |
| Inputs | Context snapshot or hash at decision time |
| Model version | Recorded in decision envelope |
| Prompt version | Recorded in decision envelope |
| Policies active | Policy version log |
| Tool calls | Tool call logs with inputs/outputs |
| Output | Final output with state (draft/committed) |
| Approval | Human approval log if applicable |

### Sample Decision Envelope

<details>
<summary><strong>Example: Minimal decision envelope</strong></summary>

```json
{
  "trace_id": "550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2025-01-15T14:30:00Z",
  "inputs": {
    "user_action": "generate",
    "user_id": "user_123",
    "session_id": "session_456",
    "context_hash": "sha256:abc123..."
  },
  "policy": {
    "prompt_version": "v2.3.1",
    "model_version": "gpt-4-0125-preview",
    "guardrails_version": "v1.2.0"
  },
  "tool_calls": [
    {
      "tool": "search",
      "timestamp": "2025-01-15T14:30:01Z",
      "input_hash": "sha256:def456...",
      "output_hash": "sha256:ghi789...",
      "latency_ms": 234
    }
  ],
  "output": {
    "result_id": "output_789",
    "state": "committed",
    "content_hash": "sha256:jkl012..."
  },
  "cost": {
    "inference_cost_usd": 0.0123,
    "input_tokens": 1500,
    "output_tokens": 500
  }
}
```

</details>

---

## Step 3: Prepare Data Residency Evidence

If customers ask where data is processed:

### Documentation Required

| Item | Content |
|------|---------|
| Data flow diagram | Shows where data enters, is processed, and is stored |
| Infrastructure configuration | Proves regional deployment |
| Vendor list | All third parties that touch data |
| DPA agreements | Data processing agreements with vendors |

### Common Questions and Answers

| Question | What They Want | Evidence Type |
|----------|----------------|---------------|
| Where is data stored? | Region and provider | Infrastructure config, DPA |
| Does data leave the region? | Any cross-border transfer | Data flow diagram, vendor list |
| Who has access? | Access control documentation | IAM policies, access logs |
| How is data encrypted? | Encryption at rest and in transit | Security documentation |

---

## Step 4: Prepare Human Oversight Evidence

Auditors want to know when humans are in the loop.

### Document Your Oversight Model

| Scenario | Human Involvement | How It Is Enforced |
|----------|-------------------|-------------------|
| High-risk decisions | Required approval before action | Policy gate in orchestrator |
| Edge cases | Escalation to human reviewer | Confidence threshold routing |
| New patterns | Review before system learns | Eval gate on training data |
| Customer complaints | Mandatory human review | Ticket workflow |

### Evidence to Prepare

- [ ] Escalation policy documentation
- [ ] Sample escalation logs (anonymized)
- [ ] Approval workflow screenshots
- [ ] Threshold configuration documentation

---

## Step 5: Prepare Model Governance Evidence

How do you manage model changes?

### Version Control

| Component | Versioning Strategy | Evidence |
|-----------|---------------------|----------|
| Prompts | Git-controlled with semantic versioning | Repository link |
| Model selection | Configuration as code | Config file history |
| Guardrails | Versioned with prompts | Same repository |
| Evaluation criteria | Documented per version | Eval specification |

### Deployment Process

| Step | Description | Evidence |
|------|-------------|----------|
| Testing | Eval suite run before deploy | CI/CD logs |
| Staging | Tested in non-production | Environment documentation |
| Rollout | Gradual rollout with monitoring | Deployment logs |
| Rollback | Automated rollback on regression | Runbook, incident logs |

---

## Step 6: Dry Run

Before the actual audit, do a dry run.

### Internal Audit Simulation

1. Pick 5 random outputs from the last 30 days
2. For each, attempt full reconstruction:
   - Retrieve decision envelope
   - Identify all inputs
   - Confirm model and prompt versions
   - Verify policy configuration
   - Trace any tool calls
3. Time each reconstruction (target: under 10 minutes)

### Document Gaps

| Output | Reconstruction Time | Missing Elements | Remediation |
|--------|---------------------|------------------|-------------|
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |
| &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; | &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; |

---

## Audit Day Checklist

### Before the Audit

- [ ] Audit room prepared with screen sharing capability
- [ ] Sample queries ready to run
- [ ] Documentation accessible (not behind VPN issues)
- [ ] Technical team on standby
- [ ] Escalation path for questions you cannot answer

### During the Audit

- [ ] Take notes on all questions asked
- [ ] Note any gaps identified
- [ ] Confirm follow-up items with auditor
- [ ] Avoid over-promising (say "I will confirm" rather than guessing)

### After the Audit

- [ ] Compile list of gaps identified
- [ ] Prioritize remediation
- [ ] Send follow-up documentation promised
- [ ] Schedule remediation work

---

## Common Gaps and Fixes

| Gap | Quick Fix | Proper Fix |
|-----|-----------|------------|
| No decision envelopes | Start logging now | Backfill and schema design |
| Missing policy versions | Log current versions | Version control prompts |
| No reconstruction capability | Document manual process | Build reconstruction tooling |
| Unclear data residency | Document current state | Architecture for isolation |

---

## Related Documents

- [Auditability](auditability.md) - Detailed auditability requirements
- [Pre-Ship Checklist](../00-templates/pre-ship-checklist.md) - Traceability requirements
- [State Model](../02-architecture/state-model.md) - Decision envelope architecture
