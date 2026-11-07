[Home](../../index.md) / [Expectation 5](index.md)

# 5. Metrics you should discuss in the interview

> Part of Expectation 5: Ensure AI solutions align with enterprise requirements for security, privacy, compliance, resiliency, observability, and maintainability

These are examples of measurable enterprise architecture outcomes. Actual targets should be agreed through business and operational requirements.

| **Area** | **Metrics** |
| --- | --- |
| Security | Critical vulnerabilities, unauthorised access incidents, security test pass rate |
| Privacy | PII exposure incidents, privacy control compliance, data deletion completion |
| Compliance | Control coverage, audit findings, unresolved exceptions, evidence completeness |
| Resiliency | Availability, MTTR, RTO/RPO achievement, recovery-test success |
| Observability | Trace coverage, alert detection time, incident resolution time |
| Maintainability | Deployment frequency, change failure rate, rollback time, regression-test coverage |
| Performance | P95/P99 latency, throughput, timeout rate |
| Cost | Cost per request, cost per successful task, infrastructure utilisation |

I would also connect these technical measures to business outcomes:

- Reduced operational disruption.
- Faster production releases.
- Lower security and compliance exposure.
- Reduced maintenance costs.
- Increased reuse of enterprise AI capabilities.
- Improved business process continuity.

## 6. Preparation guide and recommended resources

These are the resources I would prioritise for interview preparation.

### A. Enterprise security and AI security

| **Topic** | **What to study** | **Resource** |
| --- | --- | --- |
| AI application architecture | Security controls across AI components and layers | [Microsoft: Architecture patterns for AI workloads](https://learn.microsoft.com/en-us/azure/well-architected/ai/architecture-pattern?trk=article-ssr-frontend-pulse_little-text-block&utm_source=chatgpt.com) |
| LLM security | Prompt injection, sensitive information disclosure, excessive agency, supply-chain risks | [OWASP Top 10 for LLM Applications – 2026](https://github.com/GenAI-Security-Project/GenAI-LLM-Top10/blob/main/2026/README.md?utm_source=chatgpt.com) |
| AI threat modelling | Threat identification, security testing, agent permissions | [AWS: Agentic AI security guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-security/owasp-top-ten.html?utm_source=chatgpt.com) |
| Cloud security architecture | Identity, encryption, network isolation, security design principles | [Azure Well-Architected: AI design principles](https://learn.microsoft.com/en-us/azure/well-architected/ai/design-principles?trk=article-ssr-frontend-pulse_little-text-block&utm_source=chatgpt.com) |

The 2026 OWASP LLM list is especially relevant because it explicitly covers risks such as prompt injection, excessive agency, and vector and embedding weaknesses.

GitHub+1

### B. Privacy and compliance

| **Topic** | **What to study** | **Resource** |
| --- | --- | --- |
| AI risk management | Risk identification, assessment, mitigation and monitoring | [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework?utm_source=chatgpt.com) |
| Generative AI risk | GenAI-specific risks and mitigations | [NIST AI RMF and Generative AI Profile](https://www.nist.gov/itl/ai-risk-management-framework?utm_source=chatgpt.com) |
| Privacy engineering | Privacy risk management and organisational controls | [NIST Privacy Framework](https://www.nist.gov/privacy-framework?utm_source=chatgpt.com) |
| Security and privacy controls | Enterprise control catalogues and assessment | [NIST Risk Management Framework](https://csrc.nist.gov/projects/risk-management?utm_source=chatgpt.com) |

For interviews, be prepared to explain how you translate an obligation into an architectural control, how you test the control, and how you retain evidence that it is working.

### C. Resiliency and reliability

| **Topic** | **What to study** | **Resource** |
| --- | --- | --- |
| Cloud reliability | Availability, recovery, redundancy and fault isolation | [Azure Well-Architected Framework](https://learn.microsoft.com/en-gb/azure/well-architected?utm_source=chatgpt.com) |
| AI workload reliability | Model and data-store dependencies, retries, fallback and failure analysis | [Azure AI workload design principles](https://learn.microsoft.com/en-us/azure/well-architected/ai/design-principles?trk=article-ssr-frontend-pulse_little-text-block&utm_source=chatgpt.com) |
| Generative AI reliability | Model availability, inference resilience, distributed processing | [AWS Generative AI Well-Architected Lens](https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/?utm_source=chatgpt.com) |
| Resilience patterns | Circuit breakers, bulkheads, retry, failover | [Azure AI reliability guidance](https://learn.microsoft.com/en-us/azure/well-architected/ai/design-principles?trk=article-ssr-frontend-pulse_little-text-block&utm_source=chatgpt.com) |

### D. Observability and maintainability

| **Topic** | **What to study** | **Resource** |
| --- | --- | --- |
| AI workload architecture | Layered architecture, deployment and operations | [Azure AI architecture patterns](https://learn.microsoft.com/en-us/azure/well-architected/ai/architecture-pattern?trk=article-ssr-frontend-pulse_little-text-block&utm_source=chatgpt.com) |
| Application telemetry | Logs, metrics, traces and standard attributes | [OpenTelemetry semantic conventions](https://opentelemetry.io/docs/concepts/semantic-conventions/?utm_source=chatgpt.com) |
| AI operations | Model lifecycle, evaluation, monitoring and safe deployment | [Azure AI operational excellence](https://learn.microsoft.com/en-us/azure/well-architected/ai/design-principles?trk=article-ssr-frontend-pulse_little-text-block&utm_source=chatgpt.com) |
| Generative AI operations | Model quality, traceability, lifecycle and cost optimisation | [AWS Generative AI Lens](https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/?utm_source=chatgpt.com) |

Microsoft's AI workload architecture guidance is particularly useful because it connects layered AI design with identity, security, monitoring, lifecycle management, and deployment practices.

Microsoft Learn+1

## 7. Interview questions you should prepare

Security

1. How would you secure an enterprise RAG application that accesses confidential documents?
1. How would you protect an agent from prompt injection and unauthorised tool invocation?
1. How would you design identity propagation from a user to an AI agent and its enterprise tools?

Privacy and compliance
4. How would you prevent personal information from being exposed through prompts, embeddings, or logs?
5. How would you ensure that an AI solution complies with different regulatory requirements across geographies?
6. How would you make an AI-supported decision auditable?

Resiliency
7. What happens if the foundation model provider becomes unavailable?
8. How would you design a long-running agentic workflow that must recover after a failure?
9. How would you define RTO and RPO for an AI application?

Observability
10. How would you troubleshoot an AI application that is available but producing poor-quality responses?
11. What should be included in an end-to-end AI execution trace?
12. How would you monitor agent behaviour, model quality, latency, and cost?

Maintainability
13. How would you prevent vendor lock-in in an enterprise AI platform?
14. How would you safely introduce a new model version into production?
15. How would you design AI applications to support independent evolution of business logic, orchestration, and model services?

## 8. A suggested 7-day preparation plan

| **Day** | **Focus** | **Practical exercise** |
| --- | --- | --- |
| 1 | Enterprise security | Design security architecture for a banking RAG application |
| 2 | Privacy and compliance | Create a privacy and compliance control matrix |
| 3 | Resiliency | Design failure-handling patterns for a loan-processing agent |
| 4 | Observability | Design an AI monitoring and distributed-tracing architecture |
| 5 | Maintainability | Design a modular, model-independent AI application architecture |
| 6 | Enterprise NFRs | Create an NFR checklist and architecture review template |
| 7 | Interview simulation | Present and defend the complete architecture |

## Page navigation

- Previous: [3. Practical interview case study: Enterprise AI architecture for a bank](exercises.md)
- Next: [9. Your interview-ready closing statement](positioning.md)
- [Back to Expectation 5](index.md)
- [Main index](../../index.md)
