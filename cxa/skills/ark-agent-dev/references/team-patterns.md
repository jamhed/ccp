# Team Patterns Reference

Detailed examples of multi-agent coordination in Ark YAML.

## Graph Team (Sequential Workflow)

Agents execute in a defined order based on graph edges.

### Simple Pipeline

```yaml
# Research agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: researcher
spec:
  prompt: |
    You are a research specialist.
    Gather and compile relevant information on the given topic.
    Pass your findings to the next agent.
---
# Analysis agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: analyzer
spec:
  prompt: |
    You are a data analyst.
    Analyze the research findings and identify key patterns.
    Summarize insights for the final report.
---
# Writing agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: writer
spec:
  prompt: |
    You are a technical writer.
    Create a final report based on the analysis.
    Format clearly with sections and bullet points.
---
# Team definition
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: research-pipeline
spec:
  strategy: graph
  description: "Research workflow: gather → analyze → write"
  maxTurns: 10
  members:
    - name: researcher
      type: agent
    - name: analyzer
      type: agent
    - name: writer
      type: agent
  graph:
    edges:
      - from: researcher
        to: analyzer
      - from: analyzer
        to: writer
---
# Query to invoke team
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: research-query
spec:
  input: "Research the impact of AI on healthcare"
  targets:
    - type: team
      name: research-pipeline
  timeout: 10m
```

### Complex Graph (Multiple Paths)

```yaml
# Agents
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: intake
spec:
  prompt: "Receive and categorize incoming requests."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: technical-review
spec:
  prompt: "Review technical aspects of the request."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: business-review
spec:
  prompt: "Review business implications."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: approver
spec:
  prompt: "Make final approval decision based on reviews."
---
# Team with branching graph
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: approval-workflow
spec:
  strategy: graph
  description: "Approval workflow with parallel reviews"
  maxTurns: 15
  members:
    - name: intake
      type: agent
    - name: technical-review
      type: agent
    - name: business-review
      type: agent
    - name: approver
      type: agent
  graph:
    edges:
      # Intake fans out to both reviewers
      - from: intake
        to: technical-review
      - from: intake
        to: business-review
      # Both reviews converge to approver
      - from: technical-review
        to: approver
      - from: business-review
        to: approver
```

## Round-Robin Team

Agents take turns in sequence.

### Debate Pattern

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: advocate
spec:
  prompt: |
    You argue FOR the proposition.
    Present compelling arguments supporting the position.
    Respond to counterarguments from the critic.
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: critic
spec:
  prompt: |
    You argue AGAINST the proposition.
    Present compelling counterarguments.
    Challenge the advocate's points.
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: debate-team
spec:
  strategy: round-robin
  description: "Structured debate between advocate and critic"
  maxTurns: 6  # 3 rounds each
  members:
    - name: advocate
      type: agent
    - name: critic
      type: agent
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: debate-query
spec:
  input: "Debate: AI will replace most jobs in 10 years"
  targets:
    - type: team
      name: debate-team
```

### Iterative Refinement

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: drafter
spec:
  prompt: |
    Write or improve the draft based on feedback.
    Focus on clarity and completeness.
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: reviewer
spec:
  prompt: |
    Review the draft critically.
    Provide specific, actionable feedback.
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: writing-team
spec:
  strategy: round-robin
  description: "Iterative writing and review"
  maxTurns: 4  # 2 write/review cycles
  members:
    - name: drafter
      type: agent
    - name: reviewer
      type: agent
```

## Selector Team (Coordinator Pattern)

A coordinator agent directs tasks to specialists.

### Basic Coordinator

```yaml
# Planner/coordinator agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: planner
spec:
  prompt: |
    You are a planning agent that coordinates work.

    Your team members are:
    - research-analyst: Researches topics and analyzes data
    - strategy-consultant: Provides strategic advice
    - implementation-expert: Handles technical implementation

    When given a task:
    1. Break it into subtasks
    2. Assign each subtask to appropriate team member
    3. Synthesize results

    Format assignments as:
    <agent-name>: <task description>

    Use the terminate tool when all tasks are complete.
  tools:
    - name: terminate
      type: built-in
---
# Specialist agents
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: research-analyst
spec:
  prompt: |
    You are a research analyst.
    Thoroughly research assigned topics.
    Provide data-driven insights.
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: strategy-consultant
spec:
  prompt: |
    You are a strategy consultant.
    Provide strategic recommendations.
    Consider risks and opportunities.
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: implementation-expert
spec:
  prompt: |
    You are an implementation expert.
    Provide technical implementation details.
    Focus on practical execution.
---
# Selector team
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: consulting-team
spec:
  strategy: selector
  description: "Coordinator delegates to specialists"
  maxTurns: 20
  members:
    - name: planner
      type: agent
    - name: research-analyst
      type: agent
    - name: strategy-consultant
      type: agent
    - name: implementation-expert
      type: agent
```

### Customer Service Team

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: dispatcher
spec:
  prompt: |
    You are a customer service dispatcher.

    Route customer inquiries to specialists:
    - billing-agent: Payment, invoices, refunds
    - technical-agent: Technical issues, bugs
    - general-agent: General inquiries, feedback

    Analyze the customer's question and route appropriately.
  tools:
    - name: terminate
      type: built-in
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: billing-agent
spec:
  prompt: "Handle billing inquiries professionally."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: technical-agent
spec:
  prompt: "Resolve technical issues step by step."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: general-agent
spec:
  prompt: "Handle general inquiries helpfully."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: support-team
spec:
  strategy: selector
  description: "Customer support with specialized agents"
  maxTurns: 15
  members:
    - name: dispatcher
      type: agent
    - name: billing-agent
      type: agent
    - name: technical-agent
      type: agent
    - name: general-agent
      type: agent
```

## Multi-Target Query

Query multiple agents/teams in parallel:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: multi-model-query
spec:
  input: "Explain quantum computing"
  targets:
    # Get responses from different agents
    - type: agent
      name: technical-explainer
    - type: agent
      name: simple-explainer
    # Or different models
    - type: agent
      name: gpt4-agent
    - type: agent
      name: claude-agent
```

## Team Best Practices

### Graph Teams

- Use for sequential workflows with defined order
- Good for: pipelines, approval workflows, staged processing
- Keep graph acyclic (no loops)
- Set appropriate `maxTurns`

### Round-Robin Teams

- Use for alternating perspectives
- Good for: debates, iterative refinement, peer review
- Usually 2-3 agents
- `maxTurns` = cycles × agents

### Selector Teams

- Use when coordinator should decide routing
- Good for: customer service, task delegation, triage
- Coordinator needs clear routing instructions
- Include terminate tool for completion

### General Tips

1. **Clear prompts**: Each agent should know its role
2. **Handoff instructions**: Tell agents to pass relevant info
3. **Reasonable maxTurns**: Prevent infinite loops
4. **Test incrementally**: Start simple, add complexity
