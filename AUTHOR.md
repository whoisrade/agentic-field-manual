# About the Author

I'm Rade Joksimovic. 15+ years engineering SaaS systems. Recent years focused on LLM-driven products and agentic infrastructure.

I specialize in high-leverage system decisions - the kind that are difficult to reverse and expensive to get wrong.

---

## What I Work On

Much of my work focuses on preventing failure modes that don't appear in early demos but become catastrophic at scale:

- **Cost runaway** - when inference costs grow faster than revenue
- **UX-driven recomputation** - when user behavior triggers hidden compute
- **Architectural overcommitment** - when early decisions close future options
- **Incentive misalignment** - when the system optimizes for the wrong thing

I treat AI, infrastructure, and UX as economic systems, not abstractions.

---

## How I Work

My approach is observation-driven:
1. Measure real usage (session recordings, telemetry, cost breakdowns)
2. Identify failure patterns before they compound
3. Change the architecture to match reality - not the other way around

I take ownership of the parts that keep CTOs up at night - and make them stop thinking about it.

---

## Background

I operate as a Principal IC across AI SaaS products, owning end-to-end system decisions where engineering, UX, and economics intersect.

**Scale I've operated at:**
- Products with 1.5M+ monthly active users
- Systems handling 30M+ monthly API calls
- Infrastructure orchestrating 50K+ agents

**Recent work includes:**
- Taking products from architecture decision to production-ready enterprise infrastructure (Kubernetes, tenant isolation, runtime sandboxing) in weeks, not months
- Choosing data layers based on observed usage patterns - document stores for read-heavy, low-write systems; Postgres for sustained write volumes
- Re-architecting AI suggestion systems after observing undo behavior in session recordings, reducing unnecessary recomputation
- Adding early answer-direction confirmation and post-processing guards to reduce expensive misaligned AI responses
- Implementing shared context caching after confirming large parts of AI context were identical across users

Earlier in my career, I founded and led venture-backed companies, raised capital, and managed teams of up to 30 people. Operating under board and investor pressure sharpened my judgment around second-order effects, tradeoffs, and decision accountability.

That experience directly informs how I design systems today - with durability, cost ceilings, and organizational reality in mind.

---

## Why This Repo

This repo is everything I've learned about building agentic systems that stay legible, controllable, and auditable as they scale.

It's opinionated. It reflects what I've observed, not universal truth. Your context is different. Your constraints are different. But the failure modes are the same.

If you're facing margin fragility at 2am, this is what I would want to have.

---

## Get In Touch

If you're building something where this matters, I'd like to hear about it.

- **Twitter/X:** [@whoisrade](https://twitter.com/whoisrade)
- **LinkedIn:** [linkedin.com/in/radejoksimovic](https://linkedin.com/in/radejoksimovic)
- **Email:** rade.joksimovic@gmail.com

---

## If You Found Value

The best way to support this work:

1. **Star the repo** - helps others find it
2. **Share the specific doc that helped** - more useful than sharing the whole repo
3. **Tell me what's missing** - I'm still learning
4. **Tell me what worked** - I'd love to hear your war stories

---

*Fully remote. Based in Serbia (CET).*
