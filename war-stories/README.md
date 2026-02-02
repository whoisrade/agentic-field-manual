# War Stories

These are abstracted accounts based on patterns I've observed across multiple projects. Details have been generalized to protect confidentiality while preserving the lessons.

Each story includes:
- **Related Concepts** - prerequisite reading to understand the context
- **The Pattern** - what happened and why
- **The Fix** - what we did about it
- **Further Reading** - external references for going deeper

---

## What's Here

| Story | The Lesson |
|-------|-----------|
| [The Undo Button That Killed Our Margin](the-undo-button-that-killed-our-margin.md) | Hidden recompute from "free" UI actions |
| [Why We Rebuilt State Twice](why-we-rebuilt-state-twice.md) | State model decisions that close the reversibility window |
| [The Compliance Question We Couldn't Answer](the-compliance-question-we-couldnt-answer.md) | Auditability gaps that kill enterprise deals |
| [From API to Owned in 90 Days](from-api-to-owned-in-90-days.md) | When and how to transition inference ownership |

---

## How to Use These

- **Facing a similar problem?** Read the full story for the investigation pattern.
- **Need to convince someone?** Share the story that matches your situation.
- **Teaching your team?** Use these as case studies in architecture reviews.
- **Want to go deeper?** Follow the "Further Reading" links in each story.

---

## A Note on Specificity

The numbers in these stories are illustrative. The timelines are compressed. The details are abstracted.

What's true: **the patterns**. These failure modes happen. I've seen them. The fixes work.

Each story includes references to external sources - industry frameworks, academic papers, and practitioner resources - so you can verify the underlying principles independently.

---

## Further Reading (General)

These resources inform the thinking across all war stories:

- [Designing Data-Intensive Applications](https://dataintensive.net/) by Martin Kleppmann
- [The Design of Everyday Things](https://www.nngroup.com/books/design-everyday-things-revised/) by Don Norman
- [Architecture Decision Records](https://adr.github.io/)
- [The Twelve-Factor App](https://12factor.net/)
