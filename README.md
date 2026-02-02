# Agentic Field Manual

### Production patterns for teams building autonomous AI systems

---

Agentic systems fail silently, then expensively, then catastrophically.

This is how to stay in control.

---

## Who This Is For

- **Principal engineers** who own the architecture and need to make decisions that will be hard to reverse
- **CTOs** who need to explain AI system risk to boards, investors, and enterprise customers
- **Teams shipping agentic systems** with real constraints: compliance, margin pressure, scale

This is not about model selection. It's about the system around the model: behavior, state, recompute, latency, and ownership.

---

## The Thesis

Agentic systems don't fail gracefully. They fail silently, then expensively, then catastrophically.

The failure mode is always the same: **you lose the ability to trace what happened.**

If you can explain why the system did what it did, you still have control.
If you cannot, you're negotiating with your own product.

---

## Start Here

| If You Need... | Go To |
|----------------|-------|
| Diagnose a problem | [Failure Modes](failure-modes/) |
| Plan architecture | [Irreversible Decisions](irreversible-decisions/) |
| Something for Monday | [Templates](templates/) |
| Real examples | [War Stories](war-stories/) |
| Code to implement | [Examples](examples/) |

---

## The 4 Failure Modes

| Mode | What It Looks Like |
|------|-------------------|
| **Legibility Loss** | "Why did it do that?" takes 2 hours to answer |
| **Control Surface Drift** | Margin erodes but traffic is flat |
| **Auditability Gap** | You can show outputs but not rationale |
| **Margin Fragility** | Success creates cost curves you can't sustain |

See: [failure-modes/](failure-modes/)

---

## The 3 Irreversible Decisions

Every AI product has a reversibility window. These three decisions close it the fastest:

| Decision | What It Controls |
|----------|-----------------|
| **State Model** | What you persist and how you prove it |
| **Interaction Contract** | What user behavior can mutate state |
| **Control Plane Ownership** | What you own vs rent |

Get these right, and the rest stays flexible. Get them wrong, and you'll pay for years.

See: [irreversible-decisions/](irreversible-decisions/)

---

## What's In This Repo

| Section | What It Covers | Start Here? |
|---------|---------------|-------------|
| [failure-modes/](failure-modes/) | The 4 ways agentic systems break | If diagnosing |
| [irreversible-decisions/](irreversible-decisions/) | The 3 decisions you can't undo | If architecting |
| [operating-model/](operating-model/) | Orchestration, safety, evals, rollout | Reference |
| [economics/](economics/) | Cost models and margin protection | If margin is eroding |
| [compliance/](compliance/) | Auditability, sovereignty, independence | If enterprise deals |
| [templates/](templates/) | Checklists and frameworks for Monday | **Yes** |
| [war-stories/](war-stories/) | Abstracted lessons from real systems | **Yes** |
| [examples/](examples/) | Code, schemas, and SQL queries | **Yes** |
| [glossary.md](glossary.md) | How to explain this to your board | Reference |

---

## The One Thing to Remember

> **If you can explain the output, you have control. If you cannot, you're negotiating with your own product.**

Every section in this repo is designed to help you maintain or restore that explanatory power.

---

## About the Author

15+ years engineering SaaS systems. Recent years: LLM-driven products and agentic infrastructure.

Systems I've built have survived:
- 1.5M+ monthly active users
- 30M+ monthly API calls
- 50K+ orchestrated agents
- Enterprise compliance audits
- The moment when the CFO asks "why is our margin collapsing?"

This repo is what I learned when AI changed the failure modes.

See: [AUTHOR.md](AUTHOR.md)

---

## If You Need to Communicate Up

This repo gives you the language to explain agentic system risk to leadership.

- Facing margin erosion? Send them [Margin Fragility](failure-modes/margin-fragility.md)
- Worried about compliance? Send them [Auditability](compliance/auditability.md)
- Planning architecture? Send them [Irreversible Decisions](irreversible-decisions/)

---

## If This Helped

The best way to support this work:
1. Star the repo
2. Share the specific doc that helped you
3. [Open an issue](https://github.com/whoisrade/agentic-field-manual/issues) with what's missing

---

## Navigation

- [Visual map of how everything connects](MAP.md)
- [Quick reference glossary](glossary.md)

---

*"Agentic systems don't fail gracefully. They fail silently, then expensively, then catastrophically."*
