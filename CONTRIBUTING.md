# Contributing to Agentic Field Manual

Thank you for your interest in contributing. This manual is designed to be practical and battle-tested, so contributions should reflect real production experience.

---

## What We're Looking For

### High-Value Contributions

- **War stories**: Real incidents (anonymized) with specific lessons
- **Code examples**: Production-tested patterns in any language
- **SQL queries**: Diagnostic queries that solved real problems
- **Conversation scripts**: Stakeholder communication that worked
- **Template improvements**: Filling gaps in existing templates
- **Corrections**: Factual errors, broken links, outdated patterns

> [!NOTE]
> **What We'll Likely Decline**: Theoretical patterns without production evidence, vendor-specific implementations, marketing-style content, major structural reorganization without prior discussion, or AI-generated content that hasn't been validated in production.

---

## How to Contribute

### Small Fixes

For typos, broken links, or small clarifications:
1. Fork the repo
2. Make your change
3. Submit a PR with a clear description

### New Content

For new documents, significant additions, or structural changes:
1. **Open an issue first** describing what you want to add and why
2. Wait for feedback before investing time
3. Include the production context: scale, environment, outcome
4. Submit a PR referencing the issue

### War Stories

We especially value real-world case studies. When submitting:
- Anonymize company/product names
- Include specific numbers (users, costs, timeline)
- Focus on what went wrong and how it was fixed
- Be honest about mistakes—that's where the learning is

---

## Style Guide

### Voice and Tone

- Direct and practical, not academic
- Opinionated but acknowledging trade-offs
- No marketing language or hype
- No emojis

### Formatting

- Use standard Markdown (compatible with GitHub rendering)
- Tables for structured data
- Code blocks with language tags
- Use `&emsp;` padding in fill-in table cells (see existing templates)

### Document Structure

Each document should include:

```markdown
# Title

| | |
|:--|:--|
| **Use when** | [situation] |
| **Time** | [reading/working time] |
| **Outcome** | [what reader will achieve] |
| **Related** | [links to related documents] |

---

[Content]

---

## The Litmus Test

> [Core question to validate understanding]

- [Link to related doc]
```

---

## Code Examples

When adding code:
- Include language in code fence (```python, ```sql, etc.)
- Comment non-obvious lines
- Keep examples minimal but complete
- Test before submitting

---

## Questions?

Open an issue with the "question" label or reach out to [@whoisrade](https://twitter.com/whoisrade).

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
