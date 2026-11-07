[Home](../../index.md) / [Expectation 4](index.md)

# 4. Practical interview case study: Enterprise AI platform for a bank

> Part of Expectation 4: Provide architectural leadership for capabilities, agentic workflows, AI orchestration, evaluations, AI observability, and AI governance

Assume a bank wants to introduce AI across five areas:

- Customer service assistant
- Loan application processing
- Fraud investigation support
- Compliance knowledge assistant
- Employee productivity assistant

As Principal Architect, I would propose the following approach.

#### Step 1 — Establish shared capabilities

Create an enterprise AI platform with:

- Approved model gateway and model catalogue.
- Prompt management and version control.
- Enterprise RAG and document intelligence.
- Agent tool registry and API integration.
- Shared identity, secrets, and access management.

#### Step 2 — Define agentic workflow patterns

Start with three bounded use cases:

| **Use case** | **Agent responsibility** | **Controlled business execution** |
| --- | --- | --- |
| Customer service | Understand queries and retrieve relevant information | CRM updates through authorised APIs |
| Loan processing | Extract and validate information; identify missing documents | Credit checks and approval through governed services |
| Fraud investigation | Correlate evidence and summarise suspicious activity | Case creation and escalation through existing systems |

#### Step 3 — Implement evaluation

Define acceptance thresholds for each use case. For example:

- Customer assistant: answer relevance, groundedness, policy compliance, escalation accuracy.
- Loan processing: extraction accuracy, completeness, fairness, exception detection.
- Fraud support: evidence coverage, false-positive review, investigator usefulness.

Use a combination of automated test sets, domain-expert review, adversarial testing, and production feedback.

#### Step 4 — Implement observability

Provide a central AI operations dashboard showing:

- Model and agent execution traces.
- Token consumption and cost per task.
- Tool invocation success and failure.
- Retrieval quality and citation coverage.
- Workflow completion and exception rates.
- Human overrides and escalations.
- Security and policy violations.

#### Step 5 — Implement governance

Establish:

- AI use-case and agent inventory.
- Risk classification and approval process.
- Model and prompt change control.
- Agent permissions and tool access policies.
- Human approval for consequential actions.
- Audit trails and periodic risk reviews.

#### Step 6 — Scale through architecture governance

Introduce architecture review checkpoints, reusable reference patterns, platform onboarding standards, and a clear ownership model between central AI platform teams and business-domain teams.

## Page navigation

- Previous: [2. How the six capabilities fit together](architecture.md)
- Next: [5. Preparation guide and recommended resources](preparation.md)
- [Back to Expectation 4](index.md)
- [Main index](../../index.md)
