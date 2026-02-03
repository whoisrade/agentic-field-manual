# Sovereignty

- **Use when**: Enterprise customers ask about data residency, or you are entering regulated markets
- **Time**: 25 min read
- **Outcome**: Regulatory landscape understanding, architecture checklist
- **Related**: [Operational Independence](operational-independence.md) ・ [Data Privacy](../06-operations/data-privacy.md)

---

**The architecture that guarantees where data lives, who can access it, and under which jurisdiction it operates.**

In 2026, sovereignty is no longer a "future" concern. It's a vendor-selection requirement for enterprise customers.

---

## The Regulatory Landscape (2025-2026)

| Regulation | Scope | Key Requirements | Effective |
|------------|-------|------------------|-----------|
| **EU AI Act** | AI systems in EU | Risk classification, conformity assessment, technical documentation | Feb 2025 (phased) |
| **GDPR** | Personal data of EU residents | Data residency, right to explanation, DPO requirements | Active |
| **Digital Markets Act** | Gatekeepers in EU | Interoperability, data portability | Active |
| **DORA** | Financial services in EU | Operational resilience, ICT risk management | Jan 2025 |
| **NIS2** | Critical infrastructure | Incident reporting, supply chain security | Oct 2024 |
| **US State Privacy Laws** | CA, VA, CO, CT, etc. | Varying data rights, opt-out requirements | Active |
| **China PIPL** | Personal info in China | Localization requirements, cross-border restrictions | Active |

> [!IMPORTANT]
> Regulations are converging on requiring *proof* of control, not just *claims* of compliance.

---

## The Core Questions

Every enterprise customer will ask:

| Question | You Need To Answer | Evidence Required |
|----------|-------------------|-------------------|
| Where is data stored? | Specific regions, specific providers | Architecture diagrams, provider contracts |
| Where is data processed? | Inference location, not just storage | Processing logs, endpoint documentation |
| Can you prove locality under audit? | Evidence, not assurance | Audit logs with geographic proof |
| Can you isolate tenants by region? | Per-tenant, per-policy routing | Configuration docs, test results |
| Can you operate without third-party dependency? | For critical functions | Failover documentation, test results |
| What's your CLOUD Act exposure? | US jurisdiction applicability | Legal analysis, architecture choices |

---

## Why It Matters Now

**Regulatory pressure**
GDPR, DMA, national AI regulations are tightening. "Our vendor handles it" is not an answer.

**Enterprise requirements**
Large customers (especially in Europe, healthcare, government) require data residency as a procurement condition.

**The AI-specific challenge**
AI adds complexity: where does inference happen? Where are prompts processed? Where are model weights stored? If you use a US-based API, even with EU storage, you may have a sovereignty gap.

**Competitive differentiation**
If your competitor can prove sovereignty and you can't, you lose the deal.

---

## Design Principles

**1. Explicit data boundaries**

Data is tagged at ingestion with residency requirements:
```python
class DataObject:
    residency: str          # "eu-west-1", "us-east-1"
    classification: str     # "pii", "confidential", "public"
    tenant: str             # Tenant identifier
    jurisdiction: str       # Legal jurisdiction for this data
    retention_policy: str   # How long, under what rules
```

Boundaries are enforced at every layer: storage, processing, inference.

**2. Local inference for regulated workloads**

If data can't leave a region, inference must happen in that region. API providers in US-only regions don't work for EU-regulated data.

**Options for EU inference:**
| Option | Latency | Control | Cost |
|--------|---------|---------|------|
| Azure OpenAI (EU regions) | Low | Medium | High |
| AWS Bedrock (EU regions) | Low | Medium | High |
| Self-hosted (Hetzner, OVH, etc.) | Low | High | Variable |
| Mistral (EU-native) | Low | High | Medium |

**3. Jurisdiction-aware routing**

Route requests based on tenant policy:
```python
class JurisdictionRouter:
    def route(self, request, tenant):
        policy = self.get_policy(tenant)

        return RouterConfig(
            inference_endpoint=self.endpoints[policy.jurisdiction],
            storage=self.storage[policy.jurisdiction],
            cache=self.cache[policy.jurisdiction],
            # Even observability must be jurisdiction-aware
            observability=self.observability[policy.jurisdiction]
        )
```

**4. Operational independence for regulated customers**

Critical functions must work without:
- Vendor support
- Cross-border API calls
- Third-party dependencies that can't prove residency

---

## The Inference Sovereignty Problem

**The challenge most teams miss**: Even if you store data in EU, if you call OpenAI's US API with that data, you've transferred it.

| Approach | Data Residency | Inference Residency | Complexity |
|----------|----------------|---------------------|------------|
| US API + EU storage | EU | US (gap) | Low |
| Azure OpenAI EU | EU | EU | Medium |
| Self-hosted in EU | EU | EU | High |
| EU-native provider | EU | EU | Medium |

**For regulated workloads**, you need both storage AND inference residency.

---

## The Evidence You Need

For any audit or customer request:

| Evidence Type | What To Provide | How To Collect |
|---------------|-----------------|----------------|
| **Data flow diagram** | Where data moves end-to-end | Architecture documentation |
| **Residency proof** | Logs showing data stayed in region | Storage access logs with region |
| **Processing proof** | Inference happened in compliant location | API call logs with endpoint region |
| **Access logs** | Who touched data, from where | IAM logs, application logs |
| **Isolation proof** | Tenant A's data never touched tenant B | Request traces, tenant tagging |
| **Encryption proof** | Data encrypted at rest and in transit | Certificate logs, key management records |

---

## Implementation: Regional Configuration

```python
REGIONAL_CONFIG = {
    "eu": {
        "storage": "eu-central-1",
        "inference": "https://eu.inference.example.com",
        "cache": "eu-redis.example.com",
        "observability": "eu-logs.example.com",
        "backup": "eu-west-1",  # Secondary EU region
        "model_provider": "azure-openai-eu"
    },
    "us": {
        "storage": "us-east-1",
        "inference": "https://us.inference.example.com",
        # ...
    }
}

def get_regional_config(tenant):
    jurisdiction = tenant.get_jurisdiction()
    return REGIONAL_CONFIG[jurisdiction]
```

---

## The Litmus Test

> If a regulator asks "prove the data never left this region," can you answer with evidence rather than assurance?

If you'd have to say "we believe it didn't" instead of "here's the log," you have a sovereignty gap.

---

## Further Reading

- [EU AI Act Full Text](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32024R1689) - The official regulation
- [GDPR Text](https://gdpr-info.eu/) - Searchable GDPR reference
- [CLOUD Act Implications](https://www.lawfaremedia.org/article/what-cloud-act-and-what-does-it-do) - US law affecting data access
- [Schrems II Ruling](https://iapp.org/news/a/the-schrems-ii-decision-eu-us-data-transfers-in-question/) - EU-US data transfer restrictions
- [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework) - US government AI risk guidance

---

> *"Sovereignty is not a future concern. It's a vendor-selection requirement."*
