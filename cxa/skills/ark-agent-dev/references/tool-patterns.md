# Tool Patterns Reference

Detailed examples of tool types and patterns in Ark YAML.

## Agent as Tool

### Basic Agent Tool

```yaml
# Worker agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: translator
spec:
  description: "Translates text between languages"
  prompt: |
    You are a professional translator.
    Translate the given text accurately, preserving meaning and tone.
---
# Tool definition
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: translator-tool
spec:
  type: agent
  description: "Translate text between languages"
  inputSchema:
    type: object
    properties:
      text:
        type: string
        description: "Text to translate"
      source_language:
        type: string
        description: "Source language (e.g., 'English')"
      target_language:
        type: string
        description: "Target language (e.g., 'Spanish')"
    required: [text, target_language]
  agent:
    name: translator
    namespace: default
```

### Agent Tool with Complex Schema

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: feedback-analyzer
spec:
  type: agent
  description: "Analyzes customer feedback with customizable focus"
  inputSchema:
    type: object
    properties:
      feedback_text:
        type: string
        description: "Customer feedback to analyze"
      focus_area:
        type: string
        description: "Area to focus analysis"
        enum: ["sentiment", "issues", "suggestions", "overall"]
        default: "overall"
      output_format:
        type: string
        description: "Output format preference"
        enum: ["summary", "detailed", "bullet_points"]
        default: "summary"
      priority_level:
        type: string
        enum: ["low", "medium", "high", "critical"]
        default: "medium"
    required: [feedback_text]
    additionalProperties: false
  agent:
    name: feedback-analyzer-agent
```

### Coordinator Pattern

```yaml
# Specialist agents
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: math-expert
spec:
  description: "Mathematical problem solver"
  prompt: "Solve math problems step by step."
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: writing-expert
spec:
  description: "Writing and editing assistant"
  prompt: "Help with writing, editing, and proofreading."
---
# Tools wrapping specialists
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: math-tool
spec:
  type: agent
  description: "Solve mathematical problems"
  inputSchema:
    type: object
    properties:
      problem:
        type: string
    required: [problem]
  agent:
    name: math-expert
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: writing-tool
spec:
  type: agent
  description: "Help with writing tasks"
  inputSchema:
    type: object
    properties:
      task:
        type: string
      text:
        type: string
    required: [task]
  agent:
    name: writing-expert
---
# Coordinator agent
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: coordinator
spec:
  prompt: |
    You coordinate tasks by delegating to specialists.

    Available specialists:
    - math-tool: For mathematical problems
    - writing-tool: For writing and editing

    Analyze user requests and use appropriate tools.
  tools:
    - name: math-tool
    - name: writing-tool
```

## Fetcher Tools

### GET Request

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: get-user
spec:
  type: fetcher
  description: "Get user information by ID"
  inputSchema:
    type: object
    properties:
      user_id:
        type: integer
        description: "User ID"
    required: [user_id]
  fetcher:
    url: "https://api.example.com/users/{{.user_id}}"
    method: GET
    headers:
      - name: Authorization
        value:
          valueFrom:
            secretKeyRef:
              name: api-credentials
              key: token
```

### POST Request with Body

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: create-post
spec:
  type: fetcher
  description: "Create a new blog post"
  inputSchema:
    type: object
    properties:
      title:
        type: string
        description: "Post title"
      content:
        type: string
        description: "Post content"
      tags:
        type: array
        items:
          type: string
        description: "Post tags"
      published:
        type: boolean
        default: false
    required: [title, content]
  fetcher:
    url: "https://api.example.com/posts"
    method: POST
    headers:
      - name: Content-Type
        value:
          value: "application/json"
      - name: Authorization
        value:
          valueFrom:
            secretKeyRef:
              name: api-credentials
              key: token
    body: |
      {
        "title": {{.title | quote}},
        "content": {{.content | quote}},
        "tags": {{.tags | json}},
        "published": {{.published}}
      }
```

### Dynamic URL with Template Functions

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: search-api
spec:
  type: fetcher
  description: "Search API with filters"
  inputSchema:
    type: object
    properties:
      query:
        type: string
      category:
        type: string
      limit:
        type: integer
        default: 10
    required: [query]
  fetcher:
    url: "https://api.example.com/search?q={{.query | urlEncode}}&category={{.category | urlEncode}}&limit={{.limit}}"
    method: GET
```

### Complex Template Body

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: advanced-api
spec:
  type: fetcher
  description: "Advanced API call with nested data"
  inputSchema:
    type: object
    properties:
      userId:
        type: integer
      title:
        type: string
      content:
        type: string
      metadata:
        type: object
        properties:
          category:
            type: string
          priority:
            type: integer
      author:
        type: object
        properties:
          name:
            type: string
          email:
            type: string
    required: [userId, title, content]
  fetcher:
    url: "https://api.example.com/users/{{.userId}}/posts"
    method: POST
    headers:
      - name: Content-Type
        value:
          value: "application/json"
      - name: X-Author
        value:
          value: "{{.author.name | upper}}"
    body: |
      {
        "title": {{.title | quote}},
        "content": {{.content | quote}},
        "metadata": {{.metadata | json}},
        "author": {
          "name": "{{.author.name}}",
          "email": "{{.author.email | lower}}"
        }
      }
```

## MCP Tools

### MCP Server Definition

```yaml
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
    - name: "User-Agent"
      value:
        value: "ark-agent/1.0"
```

### Using MCP Tools in Agent

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: github-assistant
spec:
  prompt: |
    You help users with GitHub operations.
    Use available tools to search repos, manage issues, etc.
  tools:
    # MCP tools are named: {mcp-server-name}-{tool-name}
    - name: github-mcp-search-repositories
    - name: github-mcp-get-me
    - name: github-mcp-list-issues
```

### MCP Server with Service Reference

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: MCPServer
metadata:
  name: internal-mcp
spec:
  address:
    valueFrom:
      serviceRef:
        name: mcp-service
        port: "http"
        namespace: default
  path: "/mcp"
  transport: http
  timeout: "60s"
```

## Partial Tool Application

### Basic Partial

```yaml
# Base tool
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: geocode
spec:
  type: fetcher
  description: "Get coordinates for location"
  inputSchema:
    type: object
    properties:
      city:
        type: string
      country:
        type: string
      format:
        type: string
        enum: ["json", "xml"]
    required: [city]
  fetcher:
    url: "https://geo.api.com/search?city={{.city}}&country={{.country}}&format={{.format}}"
---
# Agent with partial tool
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: us-location-finder
spec:
  prompt: "Help users find locations in the United States."
  tools:
    - name: us-geocode
      description: "Find US locations (country pre-set)"
      partial:
        name: geocode
        parameters:
          - name: country
            value: "United States"
          - name: format
            value: "json"
```

### Partial with Query Parameters

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: dynamic-partial
spec:
  parameters:
    - name: default_country
      valueFrom:
        queryParameterRef:
          name: country
  prompt: "Help users find locations."
  tools:
    - name: location-search
      partial:
        name: geocode
        parameters:
          - name: country
            value: "{{ .Query.default_country }}"
```

### Partial with nil (Intentionally Empty)

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: simple-search
spec:
  parameters:
    - name: city
      valueFrom:
        queryParameterRef:
          name: city
  prompt: "Search for locations."
  tools:
    - name: city-only-search
      partial:
        name: geocode
        parameters:
          - name: city
            value: "{{ .Query.city }}"
          - name: country
            value: nil  # Not filled by LLM
          - name: format
            value: "json"
```

## Built-in Tools

### Terminate Tool

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: task-agent
spec:
  prompt: |
    Complete the assigned task.
    When finished, use the terminate tool to end the conversation.
  tools:
    - name: terminate
      type: built-in
```
