[Home](../../index.md) / [Expectation 5](index.md)

# 3. Practical interview case study: Enterprise AI architecture for a bank

> Part of Expectation 5: Ensure AI solutions align with enterprise requirements for security, privacy, compliance, resiliency, observability, and maintainability

Assume a large bank plans to introduce AI across customer service, loan processing, fraud investigation, and compliance operations.

As Principal Architect, I would approach this through the following steps.

#### Step 1 — Establish enterprise NFRs

First, conduct architecture and business workshops to identify the non-functional requirements for each use case.

| **Requirement** | **Questions to establish** |
| --- | --- |
| Security | Who can access the AI application, models, tools, and retrieved information? |
| Privacy | What personal or confidential information is processed, stored, or sent to external services? |
| Compliance | Which regulations, internal policies, and audit obligations apply? |
| Resiliency | What availability, recovery, and business continuity targets are required? |
| Observability | What must operations, security, and business teams be able to monitor? |
| Maintainability | How will models, prompts, workflows, integrations, and infrastructure be updated? |

Do not impose identical NFRs on all use cases. A customer-facing information assistant and a system supporting financial transactions have different business criticality and risk profiles.

#### Step 2 — Define the security and privacy architecture

Establish shared controls:

- Enterprise identity integration.
- Role- and attribute-based access control.
- Private network connectivity to sensitive services.
- Encryption and secrets management.
- Data classification and PII detection.
- Document-level retrieval authorisation.
- Prompt injection and output-handling protections.
- Agent tool allowlists and least-privilege access.

#### Step 3 — Establish compliance controls

Create an AI governance and compliance framework:

- AI use-case inventory.
- Risk classification.
- Approved model catalogue.
- Model and prompt version records.
- Data lineage and source provenance.
- Audit logging and retention policies.
- Human approval requirements.
- Compliance evidence and periodic assessments.

#### Step 4 — Define resiliency architecture

For critical AI workloads:

- Deploy critical services with appropriate redundancy.
- Introduce model fallback where permitted.
- Use asynchronous execution for long-running tasks.
- Persist workflow state.
- Apply retries, circuit breakers, and idempotency.
- Establish RTO and RPO.
- Define manual business continuity procedures.

#### Step 5 — Establish observability and operations

Create an enterprise AI operations capability:

- Distributed tracing across applications and models.
- Model latency and availability dashboards.
- Token consumption and cost monitoring.
- Retrieval and agent execution telemetry.
- Quality and safety indicators.
- Security events and audit trails.
- Incident alerts and operational runbooks.

#### Step 6 — Establish maintainability standards

Define reusable engineering standards:

- API contracts and modular architecture.
- Model abstraction and configuration management.
- Version-controlled prompts and retrieval configurations.
- Automated testing and evaluation.
- CI/CD and controlled deployment.
- Rollback and recovery procedures.
- Architecture decision records and technical documentation.

#### Step 7 — Introduce architecture governance

I would establish architecture review checkpoints covering:

1. Business requirements and risk classification.
1. Solution architecture and NFR compliance.
1. Security and privacy assessment.
1. AI evaluation and testing evidence.
1. Production-readiness assessment.
1. Operational handover and continuous review.

The result is an AI architecture that can scale across business units while maintaining consistent enterprise controls.

## 4. Architecture decision matrix: What would you prioritise?

In a Principal Architect interview, you may be asked how you balance competing requirements.

| **Scenario** | **Primary architectural decision** | **Trade-off to manage** |
| --- | --- | --- |
| Highly sensitive customer information | Private model deployment or approved protected model service | Cost versus data control |
| High-volume customer assistant | Autoscaling, caching, rate limiting | Latency versus cost |
| Critical loan-processing workflow | Durable orchestration and recovery | Complexity versus reliability |
| Multi-model AI platform | Model abstraction and version management | Flexibility versus abstraction overhead |
| Regulated AI decision support | Traceability, evidence, human oversight | Processing speed versus accountability |
| Rapidly evolving AI application | Modular architecture and automated testing | Initial engineering effort versus long-term maintainability |

A strong answer should explain that architectural controls must be proportionate to business criticality, risk, and regulatory requirements.

## Page navigation

- Previous: [2. How the six enterprise requirements fit together](architecture.md)
- Next: [5. Metrics you should discuss in the interview](preparation.md)
- [Back to Expectation 5](index.md)
- [Main index](../../index.md)
