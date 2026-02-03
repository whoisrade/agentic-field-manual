# The Compliance Question We Couldn't Answer

> **Read this when:** Preparing for enterprise sales, or after losing a deal due to compliance gaps.
>
> **Time:** 15 min to read. Use the question list to audit your own system.
>
> **After reading:** You will know the questions enterprises ask and how to build systems that can answer them.

---

A story about auditability gaps, enterprise deals, and the question that kills.

---

## Related Concepts

Prerequisites:
- [Auditability Gap](../01-failure-modes/auditability-gap.md) - why logging isn't enough
- [Auditability](../04-compliance/auditability.md) - what evidence you need
- [Decision Envelope](../GLOSSARY.md) - the minimum context for reproducibility

---

## Context

AI-powered interview platform. The product conducts initial candidate screenings using conversational AI - automated first-round interviews for high-volume hiring.

First serious enterprise conversations starting.

---

## The Question

Enterprise security review. Large company evaluating the platform for their clients.

The compliance lead asked: "When your AI decides a candidate should advance or not, can you show us exactly what information it used to make that decision?"

The answer should have been simple. It wasn't.

---

## The Investigation

I looked at what we were logging:

| Data Point | Logged? |
|------------|---------|
| Final recommendation | ✓ Yes |
| Transcript of interview | ✓ Yes |
| Timestamp | ✓ Yes |
| Model used | ✗ No |
| Prompt version | ✗ No |
| Scoring criteria applied | ✗ No |
| Confidence level | ✗ No |
| What specific answers influenced the decision | ✗ No |

We could show *what* the AI decided. We couldn't prove *why*.

For a hiring decision - where bias claims are a real legal exposure - "we think it was because..." isn't an answer. This is well-documented in AI ethics literature. See the [EU AI Act](https://artificialintelligenceact.eu/) requirements for high-risk AI systems, which include hiring tools.

---

## The Deeper Problem

The issue wasn't just logging. It was architecture.

The AI would sometimes produce misaligned responses mid-interview. We'd catch them in post-processing and retry. But:
- Retries weren't logged as retries
- The correction logic wasn't versioned
- There was no record of what was rejected and why

If a candidate challenged a decision, we couldn't show the full picture.

---

## The Fix

### Week 1-2: Decision envelope schema

Every AI decision now includes:
- Input data (candidate responses, job criteria)
- Prompt version and model version
- Scoring rubric applied
- Confidence score per criterion
- What was filtered or corrected in post-processing
- Retry count and reasons

### Week 3: Answer-direction guards

Added early confirmation step: before the AI commits to a direction, a lightweight check validates alignment with job criteria.

This reduced expensive misaligned responses - we caught them before generating full outputs, not after.

### Week 4: Immutable decision log

All decision envelopes stored in append-only format. Can't be modified after creation.

Reconstruction test: pick any decision from 30+ days ago, explain it with evidence only. Target: under 10 minutes.

---

## The Aftermath

Three months later, different prospect, similar compliance requirements. Same question: "Can you show us why the AI made this decision?"

This time, we could pull up the decision envelope in under two minutes:
- What the candidate said
- The scoring rubric that was active
- How each answer was scored
- The model and prompt versions
- The confidence level
- What the AI initially produced and what was corrected

The compliance lead said: "This is more documentation than we get from human interviewers."

Deal closed.

---

## The Lesson

For AI decisions with legal or ethical exposure, "trust us" isn't enough.

The compliance question that kills deals:
> "Why did the AI decide X?"

If your answer requires narrative instead of evidence, you'll lose. Enterprise buyers have heard "we think..." too many times.

### The minimum viable audit trail

For any AI output with consequences:

1. **Inputs**: What data was used (snapshot or hash)
2. **Policy**: What model, prompt, and rules were active
3. **Reasoning**: Scores, criteria, confidence
4. **Corrections**: What was filtered or retried
5. **Timestamp**: When, immutably

Build it before the first enterprise conversation, not during.

---

## Further Reading

- [EU AI Act](https://artificialintelligenceact.eu/) - regulatory requirements for high-risk AI systems
- [Responsible AI Practices](https://ai.google/responsibility/principles/) - Google's framework for AI accountability
- [Algorithmic Accountability Act](https://www.congress.gov/bill/117th-congress/house-bill/6580) - US legislative approach to AI transparency
- [Model Cards for Model Reporting](https://arxiv.org/abs/1810.03993) - academic framework for documenting AI systems

---

## The Templates

See: Use [Pre-Ship Checklist](../00-templates/pre-ship-checklist.md) before shipping
See: Reference [Auditability](../04-compliance/auditability.md) for the requirements

---

> *"Logging is not auditability. Reconstructability is auditability."*
