# Conversation Scripts

| | |
|:--|:--|
| **Use when** | You have a meeting with executives, customers, or auditors about AI system concerns |
| **Time** | 5 min to find scenario, then practice |
| **Outcome** | Ready-to-use scripts with follow-up question answers |
| **Related** | [Stakeholder Glossary](stakeholder-glossary.md) ・ [Board Explainer](board-explainer.md) |

Exact words to use in common stakeholder conversations.

---

## CFO: "Why are AI costs going up?"

### Opening

> "We've identified that **[X]%** of our compute is hidden recompute - work the system does that users don't directly trigger. The main drivers are **[undo flows / auto-save / retries]**."

### If they ask "What's hidden recompute?"

> "Every time a user clicks undo, we re-run the entire AI pipeline. Users are clicking undo **[N]** times per session on average. That's **[M]** extra inference calls per day we weren't accounting for."

### If they ask "Why didn't we catch this?"

> "Our cost tracking was per-API-call, not per-successful-outcome. We saw the calls but didn't connect them to the trigger. We're fixing that now."

### If they ask "What's the fix?"

> "Three things:
> 1. **Short-term (this week):** Cache repeated computations and add confirmation steps for expensive actions
> 2. **Medium-term (this month):** Redesign the undo flow to use stored state instead of recomputing
> 3. **Long-term:** Cost-aware UX that makes expensive actions feel expensive"

### If they ask "When will costs stabilize?"

> "With the short-term fix, we expect costs to drop **[X]%** within **[Y]** days. I'll have a more precise forecast by **[date]**."

### Close

> "I'll send you a one-pager with the numbers and timeline by end of day."

---

## CEO: "Are we ready for enterprise?"

### Opening

> "We're **[ready / close / not yet]**. The main gap is **[auditability / sovereignty / operational independence]**."

### If auditability is the gap

> "Enterprise customers will ask 'why did your system make this recommendation?' We can currently show **what** happened but not **why**. We need decision envelopes - structured records that capture the reasoning behind each output."

### If sovereignty is the gap

> "Enterprise customers in **[EU / regulated industries]** need to prove data stays in specific regions. We currently **[can / cannot]** guarantee that. The fix requires **[architectural changes / vendor changes / both]**."

### If they ask "How long to fix?"

> "**[X]** weeks for the minimum viable fix. **[Y]** months for full compliance. I can prioritize this if we have an active deal."

### If they ask "What do we need?"

> "**[Budget / headcount / architectural decision]** to **[specific action]**. I can have a detailed proposal by **[date]**."

### Close

> "I recommend we **[specific next step]**. Want me to prepare a decision document for the next leadership meeting?"

---

## Enterprise Customer: "How do you handle data?"

### Opening

> "All data is processed in **[region]** and stored in **[region]**. We can provide documentation for your security review."

### If they ask "Can you prove it?"

> "Yes. We log data location with every operation. I can show you an audit trail for any time period you specify."

### If they ask about model providers

> "We use **[provider]** for inference. Their data handling policy is **[summary]**. We can provide their SOC 2 report and data processing agreement."

### If they ask about retention

> "We retain **[type of data]** for **[period]**. This is **[configurable / fixed]** per customer. Deletion is **[automatic / on-request]** and verifiable."

### If they ask about isolation

> "Your data is **[isolated in dedicated infrastructure / logically isolated / shared infrastructure with access controls]**. We can provide architecture documentation."

### Close

> "I'll send over our security documentation package. What's the best email for your security team?"

---

## Auditor: "Show me how a decision was made"

### Opening

> "I can walk you through our decision record for any output. Let me show you an example."

### Walkthrough

> "For this output from **[date]**:
> 1. **Trigger:** User action was **[action]** at **[timestamp]**
> 2. **Context:** The system had access to **[what data]** - here's the hash for verification
> 3. **Model:** We used **[model version]** with **[prompt version]**
> 4. **Tool calls:** The system called **[tools]** - here are the input/output hashes
> 5. **Output:** The result was **[summary]** - here's the content hash
> 6. **Approval:** **[Human / system]** approved at **[timestamp]**"

### If they ask "Can you reproduce this?"

> "Yes. With the stored context and policy versions, we can re-run the decision and get the same result. Want me to demonstrate?"

### If they ask about retention

> "We retain decision records for **[period]**. This meets **[regulation]** requirements. The data is stored in **[location]** with **[encryption/access controls]**."

### If they ask about changes over time

> "All policy versions are tracked. I can show you what policies were in effect at any point in time and when they changed."

### Close

> "I can export a full audit trail for any time period you need. What format works for your process?"

---

## Board: "What are the risks with our AI?"

### Opening

> "AI systems have four distinct risk categories. Let me summarize where we stand on each."

### The Four Risks

> "**1. Legibility Risk:** Can we explain why the system did what it did?
> - Current status: **[Good / Concerning / Critical]**
> - Impact if it fails: Cannot defend decisions to customers or regulators
>
> **2. Economic Risk:** Do our unit economics work at scale?
> - Current status: **[Good / Concerning / Critical]**  
> - Impact if it fails: Growth makes us less profitable
>
> **3. Audit Risk:** Can we prove our compliance?
> - Current status: **[Good / Concerning / Critical]**
> - Impact if it fails: Lost enterprise deals, regulatory exposure
>
> **4. Operational Risk:** Can we fail gracefully?
> - Current status: **[Good / Concerning / Critical]**
> - Impact if it fails: Outages, cascading failures, slow recovery"

### If they ask "What are you doing about it?"

> "Our priority is **[highest risk area]**. We're **[specific action]** which will **[specific outcome]** by **[date]**."

### If they ask about budget

> "To address **[risk area]**, we need **[amount]** for **[purpose]**. The alternative is **[consequence of not investing]**."

### Close

> "I'll include a risk scorecard in future board updates so you can track progress. Any questions on specific areas?"

---

## Team Member: "Why do we need all this logging?"

### Opening

> "Because without it, we can't debug, we can't audit, and we can't control costs."

### The Pitch

> "Three reasons:
>
> **1. Debugging:** When something goes wrong, we need to know what the system knew at the time. Without logs, we're guessing.
>
> **2. Compliance:** Enterprise customers ask 'why did you recommend X?' We need to answer with evidence, not narrative.
>
> **3. Economics:** Hidden compute is killing our margin. We can only find it if we log trigger types."

### If they say "It's extra work"

> "It's 5 lines of code per call. The alternative is spending hours debugging when something breaks, losing enterprise deals, or discovering our unit economics don't work at scale."

### If they say "It'll slow things down"

> "Structured logging adds <1ms per call. The provenance middleware handles most of it automatically. I can show you the implementation."

### Close

> "Let me pair with you on the first integration. Once you see the pattern, it's straightforward."

---

## How to Use These Scripts

1. **Find your scenario** in the table of contents
2. **Customize the brackets** with your actual numbers
3. **Practice out loud** at least twice
4. **Prepare for follow-ups** by reading the linked documents
5. **Have data ready** - executives ask for specifics

---

## Related

- [Board Explainer](board-explainer.md) - Full presentation template
- [Stakeholder Glossary](stakeholder-glossary.md) - Term translations
- [Cost Model](../03-economics/cost-model.md) - Get your numbers
- [Metrics Reference](../07-examples/metrics-reference.md) - Query your data
