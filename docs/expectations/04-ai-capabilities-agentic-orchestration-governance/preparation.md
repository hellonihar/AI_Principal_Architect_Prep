[Home](../../index.md) / [Expectation 4](index.md)

# 5. Preparation guide and recommended resources

> Part of Expectation 4: Provide architectural leadership for capabilities, agentic workflows, AI orchestration, evaluations, AI observability, and AI governance

I recommend preparing these topics in the following order.

### A. Agentic architecture and orchestration

| **Topic to study** | **What you should understand** | **Resource** |
| --- | --- | --- |
| Agent architecture | Agent runtime, tools, memory, context, identity, lifecycle | [Microsoft Foundry Agent Service](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/overview?utm_source=chatgpt.com) |
| Enterprise agent adoption | Agent charters, boundaries, orchestration strategy, enterprise governance | [Microsoft: Build agents across your organisation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai-agents/build-secure-process?utm_source=chatgpt.com) |
| Stateful agent orchestration | Graph-based workflows, state management, retries, persistence, human approval | [LangGraph documentation](https://github.com/langchain-ai/langgraph/blob/main/README.md?utm_source=chatgpt.com) |
| Enterprise agent architecture | Scaling, evaluation, agent operations and governance | [Microsoft AI Landing Zones – Agent Operations](https://azure.github.io/AI-Landing-Zones/ai-gateway-landing-zone/blueprint/layer-2-agent-operations/?utm_source=chatgpt.com) |

### B. AI evaluation and quality engineering

| **Topic to study** | **What you should understand** | **Resource** |
| --- | --- | --- |
| RAG evaluation | Retrieval relevance, groundedness, answer relevance, citation quality | [Microsoft Foundry evaluation resources](https://microsoft.github.io/agent-resources/microsoft-foundry/?utm_source=chatgpt.com) |
| Agent evaluation | Task completion, tool selection accuracy, agent behaviour | [Evaluating AI agents at scale](https://learn.microsoft.com/en-us/azure/architecture/solution-ideas/articles/ai-agents-at-scale?utm_source=chatgpt.com) |
| Continuous evaluation | Evaluation datasets, regression testing, production evaluation | [Microsoft Foundry Control Plane](https://azure.microsoft.com/en-us/products/ai-foundry/control-plane?utm_source=chatgpt.com) |
| Evaluation strategy | Component-level and end-to-end testing | [Enterprise agents: evaluation and operations series](https://developer.microsoft.com/en-us/reactor/series/s-1705/?utm_source=chatgpt.com) |

### C. AI observability and operations

| **Topic to study** | **What you should understand** | **Resource** |
| --- | --- | --- |
| Distributed tracing | Trace IDs, spans, parent-child relationships, cross-service correlation | [OpenTelemetry trace conventions](https://opentelemetry.io/docs/specs/semconv/general/trace/?utm_source=chatgpt.com) |
| AI observability | Model calls, token usage, tool calls, latency, failures and cost | [OpenTelemetry GenAI spans](https://github.com/open-telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-spans.md?utm_source=chatgpt.com) |
| AI metrics | Token usage, model duration and inference metrics | [GenAI metrics conventions](https://github.com/microsoft/opentelemetry-semantic-conventions/blob/main/docs/gen-ai/gen-ai-metrics.md?utm_source=chatgpt.com) |
| Production monitoring | Logs, alerts, cost anomalies, output drift and operational impact | [AWS agentic AI observability guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-serverless/observability-and-monitoring.html?utm_source=chatgpt.com) |

### D. AI governance and responsible AI

| **Topic to study** | **What you should understand** | **Resource** |
| --- | --- | --- |
| AI risk management | Govern, map, measure and manage AI risks | [NIST AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework?utm_source=chatgpt.com) |
| Generative AI risks | Hallucination, privacy, information integrity, security and governance | [NIST Generative AI Profile](https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence?utm_source=chatgpt.com) |
| Agent governance | Agent inventory, access controls, boundaries and monitoring | [Microsoft enterprise agent governance guidance](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ai-agents/build-secure-process?utm_source=chatgpt.com) |
| Enterprise AI control plane | Centralised observability, evaluation, guardrails and security | [Microsoft Foundry Control Plane](https://azure.microsoft.com/en-us/products/ai-foundry/control-plane?utm_source=chatgpt.com) |

## 6. Interview questions you should prepare

These questions are particularly relevant to a Principal AI Architect interview.

Enterprise AI capabilities

1. How would you design a shared enterprise AI platform for multiple business units?
1. Which AI capabilities should be centralised, and which should remain within individual product teams?
1. How would you prevent duplication of AI services across the organisation?
1. How would you design a model gateway supporting multiple foundation models?

Agentic workflows and orchestration
5. How do you decide between an AI agent and a traditional workflow engine?
6. When would you use a single-agent architecture versus a multi-agent architecture?
7. How would you manage agent permissions when agents interact with enterprise systems?
8. How would you design a long-running agentic workflow with retries, failures, and human approvals?

Evaluation
9. How do you evaluate the quality of an agent beyond measuring the quality of its final response?
10. How would you implement an evaluation framework for an enterprise RAG solution?
11. How would you prevent a new model or prompt version from degrading production quality?

Observability
12. What should be captured in an AI execution trace?
13. How would you troubleshoot an agent that repeatedly invokes the wrong tools?
14. How would you monitor hallucination, latency, token consumption, and cost in production?

Governance
15. How would you establish enterprise-wide AI governance?
16. How would you govern autonomous agents that can initiate business transactions?
17. How would you ensure traceability and accountability for AI-generated decisions?

## 7. Metrics you should discuss in the interview

A Principal Architect should connect architecture performance to business and operational outcomes.

| **Dimension** | **Example metrics** |
| --- | --- |
| Platform adoption | Number of applications using shared AI capabilities; reuse percentage |
| Engineering productivity | Time to onboard a new AI application; development lead time |
| Agent performance | Task completion rate; tool-call accuracy; successful hand-off rate |
| Workflow efficiency | Process cycle-time reduction; straight-through processing rate |
| AI quality | Groundedness; retrieval precision; extraction accuracy; evaluation pass rate |
| Observability | Mean time to detect; mean time to resolve; trace coverage |
| Reliability | Availability; failure rate; retry rate; recovery time |
| Cost efficiency | Cost per successful task; tokens per transaction; cost per application |
| Governance | Percentage of registered AI systems; policy compliance; unresolved risk exceptions |
| Human oversight | Escalation rate; human override rate; unauthorised action prevention |

Avoid treating metrics such as a 95% accuracy rate as universal targets. Establish baselines and acceptance thresholds based on the use case, risk classification, and business impact.

## 8. A suggested 10-day preparation plan

| **Days** | **Preparation focus** | **Practical exercise** |
| --- | --- | --- |
| 1–2 | Enterprise AI capabilities | Design a shared enterprise AI platform |
| 3–4 | Agentic workflows | Design a loan-processing agent with controlled tools |
| 5 | AI orchestration | Compare workflow, sequential, parallel, and supervisor-worker patterns |
| 6–7 | AI evaluation | Create an evaluation scorecard for a RAG application and an agent |
| 8 | AI observability | Design an end-to-end trace and AI operations dashboard |
| 9 | AI governance | Define an AI governance framework and agent control policies |
| 10 | Architecture leadership | Present the complete enterprise AI reference architecture |

## Page navigation

- Previous: [4. Practical interview case study: Enterprise AI platform for a bank](exercises.md)
- Next: [9. Your interview-ready closing statement](positioning.md)
- [Back to Expectation 4](index.md)
- [Main index](../../index.md)
