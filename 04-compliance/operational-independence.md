# Operational Independence

- **Use when**: Assessing vendor risk, designing failover, or after a vendor outage affected you
- **Time**: 20 min read
- **Outcome**: Vendor risk assessment framework, resilience patterns
- **Related**: [API vs Owned](../03-economics/api-vs-owned.md) ・ [Control Plane Ownership](../02-architecture/control-plane-ownership.md)

---

**The ability to maintain critical functions without depending on vendor intervention.**

Operational independence is not about ideology. It's about resilience, sovereignty, and auditability.

---

## The 2025-2026 Reality

**The concentration problem**: Most AI systems depend on a small number of inference providers. When one has an outage, half the industry stops.

| Dependency Type | Single Provider Risk | Multi-Provider Complexity |
|-----------------|----------------------|---------------------------|
| Model inference | High (API outages) | Model differences, testing overhead |
| Embedding models | Medium | Embedding space incompatibility |
| Vector databases | Medium | Migration, index rebuilding |
| Observability | Low | Log format standardization |

**The trend**: Enterprise customers increasingly require documented failover plans and proof of vendor independence.

---

## The Indicators

You have operational independence when:

| Capability | Test | Evidence Required |
|------------|------|-------------------|
| Failover | Can you do it without calling your vendor? | Documented runbook, tested quarterly |
| Incident response | Do you control the timeline? | Escalation paths that don't require vendor |
| Audit trails | Can you provide infra-level evidence? | Logs you own, not vendor dashboards |
| Resilience testing | Can you test without vendor permission? | Chaos engineering practice |
| Capacity changes | Can you scale without vendor approval? | Autoscaling, no manual gating |
| Model switching | Can you switch providers in < 24 hours? | Abstraction layer, tested failover |

---

## Why It Matters

**When regulations tighten**
Dependence on opaque platforms becomes a liability. Regulators want to see your controls, not your vendor's. The EU AI Act and DORA both require documented operational resilience.

**When vendors fail**
Their outage becomes your incident. If you can't act without them, you can't respond. The 2024 OpenAI outages affected companies for hours because they had no fallback.

**When customers audit**
Enterprise customers want to see your operational controls. "We use AWS" is not an answer.

**When prices change**
Vendor lock-in means you can't negotiate or switch. Independence is leverage.

---

## Practical Steps

**1. Identify critical workloads and dependencies**

Map every critical function to its dependencies:

```python
DEPENDENCY_MAP = {
    "user_authentication": {
        "vendors": ["auth0"],
        "criticality": "critical",
        "fallback": "local_jwt_validation",
        "tested": "2025-01-15"
    },
    "ai_inference": {
        "vendors": ["openai", "anthropic"],
        "criticality": "critical",
        "fallback": "secondary_provider",
        "tested": "2025-01-20"
    },
    "document_storage": {
        "vendors": ["s3"],
        "criticality": "high",
        "fallback": "gcs_mirror",
        "tested": "2024-12-01"
    }
}
```

**2. Separate control plane from execution plane**

Even if you rent execution (inference, storage), you can own:
- Orchestration logic
- Logging and tracing
- Policy enforcement
- Routing decisions

```python
# Abstraction layer for inference
class InferenceRouter:
    def __init__(self, providers: List[InferenceProvider]):
        self.providers = providers
        self.primary = providers[0]

    def generate(self, prompt, **kwargs):
        try:
            return self.primary.generate(prompt, **kwargs)
        except ProviderUnavailable:
            for fallback in self.providers[1:]:
                try:
                    return fallback.generate(prompt, **kwargs)
                except ProviderUnavailable:
                    continue
            raise AllProvidersUnavailable()
```

Owning the control plane means you can switch execution providers.

**3. Build migration paths before mandatory**

For every vendor dependency, document:

| Vendor | Alternative | Migration Effort | Data Portability | Tested Cutover Time |
|--------|-------------|------------------|------------------|---------------------|
| OpenAI | Anthropic | Low (API similar) | N/A | 2 hours |
| Pinecone | Weaviate | Medium (reindex) | Export available | 4 hours |
| Auth0 | Cognito | High (SDK changes) | User export | 2 weeks |

**4. Create runbooks that don't require vendor escalation**

For every critical incident type:
- What can you do yourself?
- What requires vendor support?
- What's your workaround if vendor is unreachable?

**5. Test failover regularly**

```yaml
# Quarterly failover test schedule
Q1:
  - test: "inference_provider_failover"
    action: "Block primary provider, verify secondary handles traffic"
    success_criteria: "< 5 min degradation, no data loss"

Q2:
  - test: "storage_failover"
    action: "Simulate S3 outage, verify GCS mirror"
    success_criteria: "Read operations continue, < 1 min failover"
```

---

## The Independence Spectrum

| Level | Description | Example |
|-------|-------------|---------|
| **Dependent** | Can't function without vendor | Single inference provider, no fallback |
| **Resilient** | Can survive vendor degradation | Degraded mode, reduced features |
| **Independent** | Can operate without vendor for critical paths | Full failover, secondary providers |
| **Sovereign** | Full control, no external dependencies | Self-hosted everything |

Most companies should aim for **Independent** on critical paths, **Resilient** everywhere else. **Sovereign** is rarely worth the operational overhead.

---

## Cost of Independence

| Independence Level | Engineering Overhead | Operational Overhead | Risk Reduction |
|--------------------|----------------------|----------------------|----------------|
| Dependent | Low | Low | None |
| Resilient | Medium | Medium | Significant |
| Independent | High | High | High |
| Sovereign | Very High | Very High | Maximum |

**The trade-off**: Independence isn't free. Build it for critical paths, accept dependency for non-critical ones.

---

## The Litmus Test

> If a vendor outage becomes a regulatory incident for you, do you have operational independence?

If your incident response depends on vendor support, you don't control your own destiny.

---

## Further Reading

- [DORA Regulation](https://www.digital-operational-resilience-act.com/) - EU financial services operational resilience requirements
- [AWS Well-Architected: Reliability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html) - Cloud resilience patterns
- [The Site Reliability Workbook](https://sre.google/workbook/table-of-contents/) - Google's SRE practices
- [Chaos Engineering](https://principlesofchaos.org/) - Principles of resilience testing

---

> *"Operational independence is not about ideology. It's about resilience."*
