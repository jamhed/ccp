---
name: ark-agent-dev
description: Expert for developing YAML-based Ark agents - comprehensive patterns for agents, tools, queries, teams, templates, and MCP integration. Use when creating or modifying Ark YAML definitions.
color: blue
---

# Ark YAML Agent Development Guide

This skill provides comprehensive guidance for developing YAML-based Ark agents, including all patterns, best practices, and examples.

## Quick Reference

| Resource | Purpose |
|----------|---------|
| **Agent** | AI agent with prompt and tools |
| **Tool** | External capability (MCP, fetcher, agent) |
| **Query** | Test/invoke agents with parameters |
| **Team** | Coordinate multiple agents |
| **Model** | LLM configuration |
| **MCPServer** | MCP server connection |
| **ConfigMap** | Shared configuration |
| **Secret** | Sensitive data |

## Project Search Patterns

Find existing Ark resources in a project:

```bash
# Find agents
Grep: "kind: Agent" --glob "*.yaml"

# Find tools
Grep: "kind: Tool" --glob "*.yaml"

# Find teams
Grep: "kind: Team" --glob "*.yaml"

# Find queries
Grep: "kind: Query" --glob "*.yaml"

# Find all Ark resources
Grep: "ark.mckinsey.com" --glob "*.yaml"
```

## Validation Checklist

### Agent
- [ ] `apiVersion: ark.mckinsey.com/v1alpha1`
- [ ] `kind: Agent`
- [ ] `metadata.name`: lowercase, hyphenated
- [ ] `spec.prompt`: non-empty string
- [ ] `spec.description`: present if used as tool

### Tool
- [ ] `apiVersion: ark.mckinsey.com/v1alpha1`
- [ ] `kind: Tool`
- [ ] `metadata.name`: lowercase, hyphenated
- [ ] `spec.type`: mcp, agent, fetcher, or built-in
- [ ] `spec.description`: clear description
- [ ] `spec.inputSchema`: valid JSON Schema

### Query
- [ ] `apiVersion: ark.mckinsey.com/v1alpha1`
- [ ] `kind: Query`
- [ ] `metadata.name`: lowercase, hyphenated
- [ ] `spec.input`: non-empty string
- [ ] `spec.targets`: at least one target
- [ ] `spec.timeout`: reasonable value (e.g., `30s`)

## YAML Validation with decl

Use the `decl` CLI to validate Ark YAML files against CRD schemas and business logic.

### Basic Validation Commands

```bash
# Validate a specific file
uv run decl validate -f path/to/agent.yaml

# Validate all resources in a namespace
uv run decl validate -n namespace-name

# Validate all resources of a specific kind
uv run decl validate agent -n namespace-name

# Validate a specific resource by kind/name
uv run decl validate agent/my-agent -n namespace-name

# Validate entire base folder (all namespaces)
uv run decl validate

# Validate with verbose output (shows each resource)
uv run decl validate -v

# Continue validation on errors (collect all errors)
uv run decl validate --continue
```

### Validation Layers

The decl validator performs two-layer validation:

1. **CRD Schema Validation** - Validates against OpenAPI v3 schemas from Ark CRDs
   - Checks required fields (apiVersion, kind, metadata.name)
   - Validates field types and formats
   - Checks enum values

2. **Business Logic Validation** - Ark admission webhook rules
   - Validates filename matches `metadata.name`
   - Checks cross-references (tools, models)
   - Validates parameter configurations

### Validation Output

**Success:**
```
Validation passed!

Resource: Agent
Name: my-agent
Status: Valid (passed CRD and webhook validation)
```

**Failure:**
```
Validation failed for Agent
Name: my-agent
File: namespace/agents/my-agent.yaml

Validation Errors (2 found):

  1. [REQUIRED] spec.prompt
     Error: Field required

  2. [TYPE] spec.tools.0.name
     Error: Input should be a valid string
     Actual: 123
```

### Common Validation Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Field required` | Missing required field | Add the field |
| `Input should be a valid string` | Wrong type | Use correct type |
| `No CRD schema found` | Unknown apiVersion | Check apiVersion spelling |
| `filename_mismatch` | File name ≠ metadata.name | Rename file or update metadata |

### Quick Syntax Validation

For quick YAML syntax check (without full CRD validation):

```bash
python -c "import yaml; yaml.safe_load(open('path/to/file.yaml'))"
```

## Core Resource Types

### Agent

The main AI agent definition:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: agent-name
  namespace: default
spec:
  description: "Agent description for tool use"  # Required when used as tool
  prompt: |
    Your prompt text here.
    Use {{.parameter}} for template values.
  parameters:
    - name: param_name
      valueFrom:
        queryParameterRef:
          name: param_name
  tools:
    - name: tool-name
  modelRef:
    name: model-name  # Optional, defaults to "default"
  outputSchema:  # Optional, for structured output
    type: object
    properties:
      field:
        type: string
```

### Tool

External capabilities for agents:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: tool-name
spec:
  type: agent | mcp | fetcher | built-in
  description: "Tool description for LLM"
  inputSchema:
    type: object
    properties:
      input:
        type: string
        description: "Parameter description"
    required: [input]
  # Type-specific configuration (see Tool Types section)
```

### Query

Test and invoke agents:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: query-name
spec:
  input: "User input text"
  parameters:
    - name: param
      value: "direct value"
    - name: config_param
      valueFrom:
        configMapKeyRef:
          name: config-name
          key: key-name
  targets:
    - type: agent
      name: agent-name
  timeout: 30s
  ttl: 12h  # How long to keep results
  sessionId: session-123  # For conversation memory
```

### Team

Coordinate multiple agents:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: team-name
spec:
  strategy: graph | round-robin | selector
  description: "Team description"
  maxTurns: 10
  members:
    - name: agent-name
      type: agent
  graph:  # For strategy: graph
    edges:
      - from: agent-a
        to: agent-b
```

### Model

LLM configuration:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Model
metadata:
  name: default
spec:
  type: azure | openai
  model:
    value: gpt-4.1-mini
  config:
    azure:
      baseUrl:
        value: "https://your-endpoint.openai.azure.com"
      apiKey:
        valueFrom:
          secretKeyRef:
            name: secret-name
            key: token
      apiVersion:
        value: "2024-12-01-preview"
```

### MCPServer

MCP server connection:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: MCPServer
metadata:
  name: mcp-server-name
spec:
  address:
    value: "http://localhost:8000/mcp"
    # Or reference a service:
    valueFrom:
      serviceRef:
        name: service-name
        port: "http"
        namespace: default
  path: "/mcp"
  transport: http | sse
  timeout: "30s"
  headers:
    - name: "Authorization"
      value:
        valueFrom:
          secretKeyRef:
            name: token-secret
            key: token
```

---

## Go Template Syntax

Ark uses Go templates for dynamic content in prompts and tools.

### Basic Variable Access

```yaml
prompt: |
  Hello {{.name}}, welcome to {{.company}}.
```

### Conditionals

```yaml
prompt: |
  {{if .verbose}}
  Provide detailed explanations with examples.
  {{else}}
  Be concise and direct.
  {{end}}
```

### Equality Checks

```yaml
prompt: |
  {{if eq .tone "formal"}}
  You are a formal business assistant.
  {{else if eq .tone "casual"}}
  You are a friendly casual assistant.
  {{else}}
  You are a helpful assistant.
  {{end}}
```

### Multiple Conditions

```yaml
prompt: |
  {{if and (eq .skill_level "expert") (eq .verbosity "high")}}
  Provide comprehensive, in-depth explanations.
  {{else if and (eq .skill_level "beginner") (eq .verbosity "low")}}
  Give simple, easy-to-understand answers.
  {{end}}
```

### Optional Parameters

```yaml
prompt: |
  Search query: {{.query}}
  {{- if .category}}
  Category: {{.category}}
  {{- end}}
  {{- if .max_results}}
  Limit: {{.max_results}}
  {{- end}}
```

### Whitespace Control

```yaml
# {{- trims whitespace before
# -}} trims whitespace after
prompt: |
  {{- if .prefix}}{{.prefix}} {{- end}}
  Main content here.
```

### Template Functions

```yaml
# In fetcher tools:
url: https://api.example.com/search?q={{.query | urlEncode}}
body: |
  {
    "title": {{.title | quote}},
    "tags": {{.tags | json}},
    "email": "{{.email | lower}}"
  }
```

Available functions:
- `urlEncode` - URL encode string
- `quote` - Add JSON quotes
- `json` - Convert to JSON
- `upper` / `lower` - Case conversion
- `join` - Join array elements

---

## Tool Types

### Agent as Tool

Use one agent as a tool for another:

```yaml
# Worker agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: math-solver
spec:
  prompt: |
    You are a mathematical problem solver.
    Solve step by step and provide the final answer.
---
# Tool wrapping the agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: math-solver-tool
spec:
  type: agent
  description: "Solve mathematical problems"
  inputSchema:
    type: object
    properties:
      input:
        type: string
        description: "Mathematical problem to solve"
    required: [input]
  agent:
    name: math-solver
    namespace: default  # Optional, defaults to same namespace
---
# Coordinator agent using the tool
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: coordinator
spec:
  prompt: |
    You help users by delegating to specialized agents.
    Use math-solver-tool for math questions.
  tools:
    - name: math-solver-tool
```

### MCP Tool

Use MCP server tools:

```yaml
# First define the MCP server
apiVersion: ark.mckinsey.com/v1alpha1
kind: MCPServer
metadata:
  name: github-mcp
spec:
  address:
    value: "https://api.githubcopilot.com/mcp"
  transport: http
  timeout: "30s"
  headers:
    - name: "Authorization"
      value:
        valueFrom:
          secretKeyRef:
            name: github-token
            key: token
---
# Reference MCP tools in agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: github-assistant
spec:
  prompt: |
    You help users with GitHub repositories.
  tools:
    - name: github-mcp-search-repositories
    - name: github-mcp-get-me
```

### Fetcher Tool

HTTP API calls:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: get-weather
spec:
  type: fetcher
  description: "Get weather for a location"
  inputSchema:
    type: object
    properties:
      city:
        type: string
        description: "City name"
    required: [city]
  fetcher:
    url: "https://api.weather.com/v1/search?q={{.city | urlEncode}}"
    method: GET
    headers:
      - name: Authorization
        value:
          valueFrom:
            secretKeyRef:
              name: weather-api-key
              key: key
```

Fetcher with POST body:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: create-resource
spec:
  type: fetcher
  description: "Create a new resource"
  inputSchema:
    type: object
    properties:
      title:
        type: string
      content:
        type: string
    required: [title, content]
  fetcher:
    url: "https://api.example.com/resources"
    method: POST
    headers:
      - name: Content-Type
        value:
          value: "application/json"
    body: |
      {
        "title": {{.title | quote}},
        "content": {{.content | quote}}
      }
```

### Built-in Tools

```yaml
tools:
  - name: terminate
    type: built-in  # Ends the conversation
```

---

## Parameter Patterns

### Query Parameters

Parameters passed from Query to Agent:

```yaml
# Query
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: test-query
spec:
  input: "Analyze this topic"
  parameters:
    - name: topic
      value: "machine learning"
    - name: depth
      value: "detailed"
  targets:
    - type: agent
      name: analyzer
---
# Agent receiving parameters
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: analyzer
spec:
  parameters:
    - name: topic
      valueFrom:
        queryParameterRef:
          name: topic
    - name: depth
      valueFrom:
        queryParameterRef:
          name: depth
  prompt: |
    Analyze {{.topic}} at {{.depth}} level.
```

### ConfigMap Parameters

Shared configuration:

```yaml
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-config
data:
  guidelines: |
    Be concise and direct.
    Do not ask follow-up questions.
  tone: professional
---
# Agent using ConfigMap
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: configured-agent
spec:
  parameters:
    - name: guidelines
      valueFrom:
        configMapKeyRef:
          name: agent-config
          key: guidelines
    - name: tone
      valueFrom:
        configMapKeyRef:
          name: agent-config
          key: tone
  prompt: |
    You are a {{.tone}} assistant.
    {{.guidelines}}
```

### Static Parameters

Direct values in agent:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: static-params-agent
spec:
  parameters:
    - name: prefix
      value: "Always start with 'Greetings!'"
    - name: max_words
      value: "100"
  prompt: |
    {{.prefix}}
    Keep responses under {{.max_words}} words.
```

### Mixed Parameters

Combine static, ConfigMap, and Query parameters:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: mixed-params-agent
spec:
  parameters:
    # Static value
    - name: version
      value: "2.0"
    # From ConfigMap
    - name: guidelines
      valueFrom:
        configMapKeyRef:
          name: shared-config
          key: guidelines
    # From Query
    - name: user_context
      valueFrom:
        queryParameterRef:
          name: context
  prompt: |
    Agent v{{.version}}
    {{.guidelines}}
    User context: {{.user_context}}
```

---

## Partial Tool Application

Pre-configure tool parameters using templates:

```yaml
# Base tool
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: get-coordinates
spec:
  type: fetcher
  description: "Get coordinates for a city"
  inputSchema:
    type: object
    properties:
      city:
        type: string
      country:
        type: string
    required: [city]
  fetcher:
    url: "https://api.geo.com/search?city={{.city}}&country={{.country}}"
---
# Agent using partial tool
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: location-aware
spec:
  parameters:
    - name: default_country
      valueFrom:
        queryParameterRef:
          name: country
  prompt: |
    Help users find locations.
  tools:
    - name: get-location
      description: "Get coordinates (country pre-configured)"
      partial:
        name: get-coordinates
        parameters:
          - name: country
            value: "{{ .Query.default_country }}"
```

### Partial with nil (Skip Parameter)

```yaml
tools:
  - name: get-location-simple
    partial:
      name: get-coordinates
      parameters:
        - name: city
          value: "{{ .Query.city }}"
        - name: country
          value: nil  # Intentionally not filled by agent
```

### Partial with Transformation

```yaml
tools:
  - name: formatted-search
    partial:
      name: base-search
      parameters:
        - name: format
          value: "{{ .Query.format }} with detailed explanations"
```

---

## Team Patterns

### Graph Team (Sequential Workflow)

```yaml
# Define specialized agents
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: researcher
spec:
  prompt: "You research and gather information on topics."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: analyzer
spec:
  prompt: "You analyze research findings and identify patterns."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: writer
spec:
  prompt: "You write final reports based on analysis."
---
# Team with graph workflow
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: research-team
spec:
  strategy: graph
  description: "Research workflow team"
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
```

### Round-Robin Team

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: debate-team
spec:
  strategy: round-robin
  maxTurns: 6
  members:
    - name: advocate
      type: agent
    - name: critic
      type: agent
```

### Selector Team (Coordinator Pattern)

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: planner
spec:
  prompt: |
    You are a planning agent.
    Your team members are:
      - research-analyst: Research and data analysis
      - strategy-consultant: Strategic advice

    Delegate tasks using:
    1. <agent>: <task>
  tools:
    - name: terminate
      type: built-in
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Team
metadata:
  name: consulting-team
spec:
  strategy: selector
  members:
    - name: planner
      type: agent
    - name: research-analyst
      type: agent
    - name: strategy-consultant
      type: agent
```

---

## Structured Output

Define JSON output schema:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: entity-extractor
spec:
  description: "Extracts entities from text"
  prompt: |
    Extract named entities from the input text.
  outputSchema:
    type: object
    properties:
      summary:
        type: string
        description: "Brief summary"
      entities:
        type: array
        items:
          type: object
          properties:
            name:
              type: string
            type:
              type: string
              enum: ["person", "organization", "location"]
      sentiment:
        type: string
        enum: ["positive", "negative", "neutral"]
    required: ["summary", "entities", "sentiment"]
    additionalProperties: false
```

---

## Memory and Sessions

Enable conversation memory:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: conversation-query
spec:
  input: "What did I tell you earlier?"
  sessionId: "user-session-123"  # Links conversations
  targets:
    - type: agent
      name: assistant
```

With explicit memory reference:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: memory-query
spec:
  input: "Continue our conversation"
  memory:
    name: postgres-memory
  sessionId: "session-456"
  targets:
    - type: agent
      name: assistant
```

---

## Complete Example: Weather Agent

```yaml
# Secret for API key
apiVersion: v1
kind: Secret
metadata:
  name: weather-api-token
type: Opaque
stringData:
  token: "${WEATHER_API_KEY}"
---
# Model configuration
apiVersion: ark.mckinsey.com/v1alpha1
kind: Model
metadata:
  name: default
spec:
  type: azure
  model:
    value: gpt-4.1-mini
  config:
    azure:
      baseUrl:
        value: "https://your-endpoint.openai.azure.com"
      apiKey:
        valueFrom:
          secretKeyRef:
            name: weather-api-token
            key: token
      apiVersion:
        value: "2024-12-01-preview"
---
# Geocoding tool
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: get-coordinates
spec:
  type: fetcher
  description: "Get coordinates for a city"
  inputSchema:
    type: object
    properties:
      city:
        type: string
        description: "City name"
    required: [city]
  fetcher:
    url: "https://geocoding-api.example.com/search?name={{.city | urlEncode}}&count=1"
---
# Weather tool
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: get-weather
spec:
  type: fetcher
  description: "Get weather forecast"
  inputSchema:
    type: object
    properties:
      latitude:
        type: number
      longitude:
        type: number
    required: [latitude, longitude]
  fetcher:
    url: "https://weather-api.example.com/forecast?lat={{.latitude}}&lon={{.longitude}}"
---
# Weather agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: weather-assistant
spec:
  description: "Weather forecasting assistant"
  prompt: |
    You are a helpful weather assistant.
    Use available tools to get weather information.
    Be concise and provide temperature and conditions.
  tools:
    - name: get-coordinates
    - name: get-weather
---
# Test query
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: test-weather
spec:
  input: "What's the weather in Chicago?"
  targets:
    - type: agent
      name: weather-assistant
  timeout: 30s
```

---

## Best Practices

### Agent Design

1. **Clear, focused prompts** - One responsibility per agent
2. **Use description** - Always add when agent is used as tool
3. **Handle edge cases in prompt** - Guide LLM for unusual inputs
4. **Keep prompts concise** - Avoid verbose instructions

### Tool Design

1. **Clear descriptions** - LLM uses this to decide when to call
2. **Explicit inputSchema** - Define all parameters with descriptions
3. **Use enums** - Constrain values where appropriate
4. **Required vs optional** - Mark appropriately

### Parameter Design

1. **Meaningful names** - Self-documenting
2. **Use ConfigMaps** - For shared configuration
3. **Use Secrets** - For sensitive data
4. **Handle missing params** - Use conditionals in templates

### Testing

1. **Create test queries** - For every agent
2. **Test edge cases** - Missing params, unusual input
3. **Set reasonable timeouts** - Don't hang forever
4. **Use TTL** - Clean up old query results

### File Organization

```
namespace/
├── agents/
│   ├── main-agent.yaml
│   └── helper-agent.yaml
├── tools/
│   ├── api-tool.yaml
│   └── agent-tool.yaml
├── queries/
│   ├── test-basic.yaml
│   └── test-edge-case.yaml
├── models/
│   └── default.yaml
├── secrets/
│   └── api-keys.yaml
└── configmaps/
    └── shared-config.yaml
```

---

## Common Patterns Reference

| Pattern | Use Case | Key Config |
|---------|----------|------------|
| **Simple Agent** | Basic assistant | Just prompt |
| **Parameterized** | Customizable | parameters + template |
| **Conditional** | Dynamic behavior | {{if}} in prompt |
| **Tool-Using** | External capabilities | tools list |
| **Agent-as-Tool** | Delegation | Tool type: agent |
| **Partial Tool** | Pre-configured | partial in tools |
| **Team Graph** | Sequential workflow | strategy: graph |
| **Team Round-Robin** | Turn-based | strategy: round-robin |
| **Coordinator** | Task delegation | selector + planner |
| **Structured Output** | JSON response | outputSchema |
| **Memory** | Conversation | sessionId |

## See Also

- **references/agent-patterns.md** - Detailed agent examples
- **references/tool-patterns.md** - Tool type examples
- **references/team-patterns.md** - Multi-agent coordination
- **references/template-syntax.md** - Go template reference
