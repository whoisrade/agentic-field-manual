# Anti-Patterns in Agentic Systems

| | |
|:--|:--|
| **Use when** | Reviewing architecture, conducting code reviews, or debugging unexpected behavior |
| **Time** | 15 min read, ongoing to apply |
| **Outcome** | Recognition of common mistakes before they become expensive |
| **Related** | [Before/After Patterns](07-examples/before-after-patterns.md) ・ [Failure Modes](01-failure-modes/README.md) |

---

The patterns below look reasonable in demos but cause problems at scale. Each has been observed in production systems.

---

## Architecture Anti-Patterns

### 1. Stateless Illusion

**What it looks like:**
```python
# "Stateless" endpoint that isn't
@app.post("/generate")
async def generate(request: Request):
    context = await fetch_user_context(request.user_id)  # DB call
    history = await fetch_conversation(request.session_id)  # DB call
    return await llm.generate(context + history + request.prompt)
```

**Why it fails:** You think you're stateless, but you've hidden state in context assembly. When that context changes mid-session (another tab, mobile sync), users get inconsistent results and blame the AI.

**The fix:** Make state explicit. Use session snapshots, version context, and expose staleness to users.

See: [State Model](02-architecture/state-model.md)

---

### 2. Free User Actions

**What it looks like:**
```javascript
// "Free" undo button
<button onClick={() => regenerateResponse()}>
  Try Again
</button>
```

**Why it fails:** Every regenerate is an inference call. At $0.01/call and 10% regeneration rate, you've added 10% to costs invisibly. Some users regenerate 20+ times per session.

**The fix:** Track trigger types. Make regeneration costs visible in metrics. Consider rate limits or confirmations.

See: [Interaction Contract](02-architecture/interaction-contract.md), [Hidden Recompute](03-economics/hidden-recompute.md)

---

### 3. Optimistic Logging

**What it looks like:**
```python
# Log after, not during
response = await llm.generate(prompt)
logger.info(f"Generated response for user {user_id}")  # What prompt? What model?
return response
```

**Why it fails:** When something goes wrong 6 months later, you can prove the output exists but not why it was generated. Auditors ask "what did the system know at decision time?" and you can't answer.

**The fix:** Log the decision envelope before the call, update with result after.

See: [Auditability Gap](01-failure-modes/auditability-gap.md), [Before/After Patterns](07-examples/before-after-patterns.md)

---

### 4. Implicit Versioning

**What it looks like:**
```python
SYSTEM_PROMPT = """You are a helpful assistant..."""  # What version is this?

async def generate(user_input):
    return await llm.generate(SYSTEM_PROMPT + user_input)
```

**Why it fails:** Prompt changes are invisible in production. When quality regresses, you don't know which prompt was running when. A/B testing becomes impossible.

**The fix:** Version prompts explicitly. Store prompt version with every output. Keep a prompt registry.

See: [Legibility Loss](01-failure-modes/legibility-loss.md)

---

### 5. Monolithic Agents

**What it looks like:**
```python
class MegaAgent:
    def __init__(self):
        self.tools = [tool1, tool2, tool3, ..., tool47]
    
    async def run(self, task):
        # One agent does everything
        return await self.process_with_all_tools(task)
```

**Why it fails:** Debugging is impossible. Cost attribution is impossible. One broken tool breaks everything. Prompt length grows unbounded.

**The fix:** Decompose into specialized agents with clear boundaries. Use orchestration patterns.

See: [Orchestration](06-operations/orchestration.md)

---

## Economics Anti-Patterns

### 6. Averaging Costs

**What it looks like:**
```python
# "Average cost per user"
total_cost = sum(all_inference_costs)
avg_cost = total_cost / total_users  # Looks fine!
```

**Why it fails:** Cost distribution is heavily skewed. 5% of users often drive 50% of costs. Your "average" user doesn't exist.

**The fix:** Track percentiles (P50, P90, P99). Identify cost outliers. Understand what behaviors drive high costs.

See: [Cost Model](03-economics/cost-model.md), [Margin Fragility](01-failure-modes/margin-fragility.md)

---

### 7. Ignoring Token Ratios

**What it looks like:**
```python
# Treating all tokens equally
total_tokens = input_tokens + output_tokens
```

**Why it fails:** Output tokens often cost 3-4x input tokens. A verbose response costs more than a concise one. You're optimizing the wrong thing.

**The fix:** Track input/output ratios. Price outputs correctly. Tune for conciseness.

---

### 8. Missing Trigger Attribution

**What it looks like:**
```python
async def inference(request):
    result = await llm.generate(request.prompt)
    log_cost(result.cost)  # But what caused this call?
    return result
```

**Why it fails:** You can't distinguish user-initiated work from system-initiated work (retries, auto-save, undo). 40% of your costs might be "hidden recompute."

**The fix:** Log trigger type with every call: user_explicit, undo, retry, auto_save, background_refresh.

See: [Hidden Recompute](03-economics/hidden-recompute.md), [Control Surface Drift](01-failure-modes/control-surface-drift.md)

---

## Operations Anti-Patterns

### 9. No Circuit Breakers

**What it looks like:**
```python
async def call_tool(request):
    while True:  # Retry forever!
        try:
            return await external_api.call(request)
        except Exception:
            await asyncio.sleep(1)
            continue
```

**Why it fails:** When an external service is down, you hammer it with requests, run up costs, and cascade the failure.

**The fix:** Implement circuit breakers with failure thresholds and recovery timeouts.

See: [Tool Reliability](06-operations/tool-reliability.md)

---

### 10. Testing Against Live Models

**What it looks like:**
```python
def test_response_quality():
    response = await openai.generate("Test prompt")
    assert len(response) > 100  # This will randomly fail
```

**Why it fails:** Model outputs are non-deterministic. Your tests are flaky. CI costs money. You can't reproduce failures.

**The fix:** Use recorded responses for unit tests. Reserve live calls for eval suites with proper tolerance.

See: [Eval and Regression](06-operations/eval-and-regression.md)

---

### 11. Manual Rollback

**What it looks like:**
"To rollback, revert the commit, redeploy, and manually update the feature flag in the database..."

**Why it fails:** When it's 2am and the system is on fire, you will make mistakes. Manual processes take 10x longer under stress.

**The fix:** One-command rollback. Test it regularly. Document nothing that requires interpretation at 2am.

See: [Rollout and Rollback](06-operations/rollout-and-rollback.md)

---

### 12. Guards as Afterthoughts

**What it looks like:**
```python
response = await llm.generate(prompt)
if is_inappropriate(response):  # Check after the expensive call
    return "I can't help with that"
```

**Why it fails:** You pay for the generation even when blocking it. Adversarial inputs still hit the model. You're defending at the wrong layer.

**The fix:** Layer guardrails: input validation first, then classification, then model, then output filtering.

See: [Safety Surface](06-operations/safety-surface.md), [Guardrails Example](07-examples/guardrails.py)

---

## Compliance Anti-Patterns

### 13. Logs Without Provenance

**What it looks like:**
```
2024-01-15 10:23:45 INFO Generated response for user_123
2024-01-15 10:23:46 INFO Response: "The answer is 42"
```

**Why it fails:** You can prove what the system said but not how it got there. Auditors need the full decision context: inputs, model version, policy applied, tools called.

**The fix:** Decision envelopes. Store the complete context with every output.

See: [Auditability](04-compliance/auditability.md), [Decision Envelope Schema](07-examples/decision-envelope-schema.json)

---

### 14. PII in Prompts

**What it looks like:**
```python
prompt = f"User {user.name} from {user.company} at {user.email} asked: {question}"
```

**Why it fails:** PII flows to model providers. You may violate GDPR, CCPA, or customer contracts. Logs become toxic.

**The fix:** Pseudonymize before sending. Map back in post-processing. Document what leaves your boundary.

See: [Data Privacy](06-operations/data-privacy.md), [Sovereignty](04-compliance/sovereignty.md)

---

### 15. Assuming Model Stability

**What it looks like:**
"We're using GPT-4, it'll behave the same forever."

**Why it fails:** Providers update models without notice. Behavior changes. Quality regresses. Your evals pass because they're testing the new behavior, not validating against requirements.

**The fix:** Pin model versions. Run evals against golden datasets. Alert on behavioral drift.

See: [Eval and Regression](06-operations/eval-and-regression.md), [Control Plane Ownership](02-architecture/control-plane-ownership.md)

---

## The Pattern Behind the Anti-Patterns

Most anti-patterns share a root cause: **optimizing for build speed over operational reality.**

In demos, everything works. At scale:
- Hidden state surfaces as inconsistency
- Free actions surface as cost overruns
- Missing logs surface as audit failures
- Implicit versions surface as debugging nightmares

The fix is always the same: **make the implicit explicit, before production.**

---

## Related

- [Failure Modes](01-failure-modes/README.md) - The outcomes of these anti-patterns
- [Before/After Patterns](07-examples/before-after-patterns.md) - Code transformations
- [Pre-Ship Checklist](00-templates/pre-ship-checklist.md) - Catch these before launch
