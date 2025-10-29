# ARK Operator Testing Examples

Example patterns for testing ARK Kubernetes operator resources. These serve as reference implementations that can be adapted for other operators.

## Table of Contents
1. [ARK Resource Overview](#ark-resource-overview)
2. [RBAC Patterns](#rbac-patterns)
3. [Model Testing](#model-testing)
4. [Agent Testing](#agent-testing)
5. [Query Testing](#query-testing)
6. [Team Testing](#team-testing)
7. [Tool Testing](#tool-testing)

## ARK Resource Overview

ARK operator manages AI agents and queries in Kubernetes. Key Custom Resources:

- **Model**: LLM model configurations (Azure OpenAI, etc.)
- **Agent**: AI agents with prompts and tools
- **Query**: Requests sent to agents/teams
- **Team**: Multi-agent orchestration
- **Tool**: Reusable tools for agents (HTTP, MCP, agent-based)
- **MCPServer**: Model Context Protocol server connections

## RBAC Patterns

ARK Query resources need RBAC permissions to access other resources.

### Essential RBAC Configuration

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: query-test-role
rules:
- apiGroups: ["ark.mckinsey.com"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: query-test-rolebinding
subjects:
- kind: ServiceAccount
  name: default
  namespace: ($namespace)
roleRef:
  kind: Role
  name: query-test-role
  apiGroup: rbac.authorization.k8s.io
```

**Key Points:**
- Use default ServiceAccount
- Grant full access to `ark.mckinsey.com` resources
- Include `secrets` and `configmaps` for parameter resolution
- Use `($namespace)` template for namespace references

### Extended RBAC for Services

When testing with services (MCP, etc.):

```yaml
rules:
- apiGroups: ["ark.mckinsey.com"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["secrets", "configmaps", "services"]
  verbs: ["get", "list", "watch"]
```

## Model Testing

Models provide LLM backends for agents.

### Basic Model Test

```yaml
- name: setup-model
  try:
  # Create secret with API key
  - script:
      skipLogOutput: true
      content: |
        set -u
        echo "{\"token\": \"$E2E_TEST_AZURE_OPENAI_KEY\", \"url\": \"$E2E_TEST_AZURE_OPENAI_BASE_URL\"}"
      outputs:
      - name: azure
        value: (json_parse($stdout))

  - apply:
      resource:
        apiVersion: v1
        kind: Secret
        metadata:
          name: model-token
        type: Opaque
        data:
          token: (base64_encode($azure.token))

  - apply:
      resource:
        apiVersion: ark.mckinsey.com/v1alpha1
        kind: Model
        metadata:
          name: test-model
        spec:
          type: azure
          model:
            value: gpt-4o-mini
          config:
            azure:
              baseUrl:
                value: ($azure.url)
              apiKey:
                valueFrom:
                  secretKeyRef:
                    name: model-token
                    key: token
              apiVersion:
                value: "2024-12-01-preview"

  # Assert model ready
  - assert:
      resource:
        apiVersion: ark.mckinsey.com/v1alpha1
        kind: Model
        metadata:
          name: test-model
        status:
          phase: ready
```

## Agent Testing

Agents execute prompts using models.

### Basic Agent Test

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: test-agent
      spec:
        modelRef:
          name: test-model
        prompt: |
          You are a test agent. Provide helpful responses.

# Agents don't have status.phase, only assert existence
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: test-agent
```

### Agent with OutputSchema

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: structured-agent
      spec:
        modelRef:
          name: test-model
        outputSchema:
          type: object
          properties:
            summary:
              type: string
            score:
              type: number
            tags:
              type: array
              items:
                type: string
          required: ["summary", "score"]
        prompt: |
          Provide structured JSON responses.
```

### Agent with Tools

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: agent-with-tools
      spec:
        modelRef:
          name: test-model
        tools:
        - name: weather-tool
        - name: calculator-tool
        prompt: |
          You can use weather and calculator tools.
```

## Query Testing

Queries send requests to agents and validate responses.

### Basic Query Test

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: test-query
      spec:
        input: Test question for the agent
        targets:
        - type: agent
          name: test-agent

# Assert query completion
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: test-query
      status:
        phase: done
```

### Query Response Validation

```yaml
# Validate response count
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: test-query
      status:
        (length(responses)): 1

# Validate agent responded
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: test-query
      status:
        (contains(responses[*].target.name, 'test-agent')): true

# Validate response content
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: test-query
      status:
        (length(join('', responses[*].content)) > `10`): true
```

### Structured Output Validation

```yaml
# Query agent with outputSchema
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: structured-query
      spec:
        input: Analyze this data
        targets:
        - type: agent
          name: structured-agent

# Validate JSON structure
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: structured-query
      status:
        phase: done
        (json_parse(responses[0].content).summary != null): true
        (json_parse(responses[0].content).score != null): true
        (type(json_parse(responses[0].content).summary) == 'string'): true
        (type(json_parse(responses[0].content).score) == 'number'): true
```

### Query with Parameters

```yaml
# Create ConfigMap with parameter values
- apply:
    resource:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: query-params
      data:
        mode: "verbose"
        style: "formal"

# Agent with parameter templates
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: parameterized-agent
      spec:
        modelRef:
          name: test-model
        prompt: |
          Mode: {{.mode}}
          Style: {{.style}}
          Respond accordingly.

# Query with parameter references
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: param-query
      spec:
        input: Test question
        targets:
        - type: agent
          name: parameterized-agent
        parameters:
        - name: mode
          valueFrom:
            configMapKeyRef:
              name: query-params
              key: mode
        - name: style
          valueFrom:
            configMapKeyRef:
              name: query-params
              key: style
```

## Team Testing

Teams orchestrate multiple agents.

### Sequential Team

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Team
      metadata:
        name: sequential-team
      spec:
        strategy: sequential
        members:
        - type: agent
          name: researcher
        - type: agent
          name: analyzer
        - type: agent
          name: summarizer

# Query team
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: team-query
      spec:
        input: Complex task requiring multiple steps
        targets:
        - type: team
          name: sequential-team

# Validate all agents responded
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: team-query
      status:
        phase: done
        (length(responses)): 3
        (contains(responses[*].target.name, 'researcher')): true
        (contains(responses[*].target.name, 'analyzer')): true
        (contains(responses[*].target.name, 'summarizer')): true
```

### Graph Team

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Team
      metadata:
        name: graph-team
      spec:
        strategy: graph
        members:
        - type: agent
          name: researcher
        - type: agent
          name: reviewer
        - type: agent
          name: writer
        graph:
          edges:
          - from: researcher
            to: reviewer
          - from: reviewer
            to: writer
```

### Round-Robin Team

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Team
      metadata:
        name: round-robin-team
      spec:
        strategy: round-robin
        maxTurns: 3
        members:
        - type: agent
          name: agent-1
        - type: agent
          name: agent-2
        - type: agent
          name: agent-3
```

## Tool Testing

Tools provide reusable capabilities for agents.

### Agent Tool

```yaml
# Create agent to wrap as tool
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: math-solver
      spec:
        modelRef:
          name: test-model
        prompt: Solve mathematical problems

# Create tool wrapping agent
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Tool
      metadata:
        name: math-tool
      spec:
        type: agent
        description: Solve math problems
        inputSchema:
          type: object
          properties:
            problem:
              type: string
          required: ["problem"]
        agent:
          name: math-solver
```

### Fetcher Tool

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Tool
      metadata:
        name: weather-api
      spec:
        type: fetcher
        description: Get weather data
        inputSchema:
          type: object
          properties:
            city:
              type: string
              description: City name
          required: ["city"]
        fetcher:
          url: https://api.weather.com/forecast?city={{.city | urlEncode}}
          method: GET
```

### Agent Using Tools

```yaml
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: tool-user
      spec:
        modelRef:
          name: test-model
        tools:
        - name: math-tool
        - name: weather-api
        prompt: |
          You can use math and weather tools.

# Query and validate tool usage
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: tool-query
      spec:
        input: What's the weather in London and calculate 2+2
        targets:
        - type: agent
          name: tool-user

- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: tool-query
      status:
        phase: done
        (length(responses)): 1
        (contains(responses[0].content, 'London')): true
```

## Complete Test Example

Full example combining all elements:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: complete-ark-test
spec:
  description: Complete ARK operator test with model, agent, and query
  steps:
  - name: setup
    try:
    # Get Azure credentials from environment
    - script:
        skipLogOutput: true
        content: |
          set -u
          echo "{\"token\": \"$E2E_TEST_AZURE_OPENAI_KEY\", \"url\": \"$E2E_TEST_AZURE_OPENAI_BASE_URL\"}"
        outputs:
        - name: azure
          value: (json_parse($stdout))

    # Apply all resources
    - apply:
        file: "manifests/*.yaml"

    # Wait for model ready
    - assert:
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Model
          metadata:
            name: test-model
          status:
            phase: ready

    # Verify agent exists
    - assert:
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Agent
          metadata:
            name: test-agent

  - name: test-query
    try:
    # Wait for query completion
    - assert:
        timeout: 60s
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Query
          metadata:
            name: test-query
          status:
            phase: done

    # Validate response
    - assert:
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Query
          metadata:
            name: test-query
          status:
            (length(responses)): 1
            (contains(responses[*].target.name, 'test-agent')): true
            (length(join('', responses[*].content)) > `10`): true

    catch:
    - events: {}
    - describe:
        apiVersion: ark.mckinsey.com/v1alpha1
        kind: Query
        name: test-query
```

## Common ARK Testing Patterns

### Error Testing (Admission Webhooks)

```yaml
# Test invalid resource rejection
- name: test-invalid-agent
  try:
  - error:
      file: manifests/invalid-agent-missing-prompt.yaml

- name: test-invalid-query
  try:
  - error:
      file: manifests/invalid-query-no-targets.yaml
```

### Label Selector Testing

```yaml
# Agents with labels
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Agent
      metadata:
        name: prod-agent
        labels:
          environment: production
          type: specialist

# Query with selector
- apply:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: selector-query
      spec:
        input: Test
        selector:
          matchLabels:
            environment: production
            type: specialist

# Validate correct agent responded
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      metadata:
        name: selector-query
      status:
        (contains(responses[*].target.name, 'prod-agent')): true
```

These patterns demonstrate ARK-specific testing but the principles apply to any Kubernetes operator testing.
