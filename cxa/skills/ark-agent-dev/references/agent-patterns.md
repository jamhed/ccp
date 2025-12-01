# Agent Patterns Reference

Detailed examples of common agent patterns in Ark YAML.

## Simple Agent

Basic agent with just a prompt:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: simple-assistant
spec:
  prompt: |
    You are a helpful assistant.
    Answer questions clearly and concisely.
```

## Parameterized Agent

Agent with query parameters:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: context-aware
spec:
  parameters:
    - name: context
      valueFrom:
        queryParameterRef:
          name: context
    - name: format
      valueFrom:
        queryParameterRef:
          name: format
  prompt: |
    Context: {{.context}}

    {{if eq .format "brief"}}
    Be concise.
    {{else if eq .format "detailed"}}
    Provide thorough explanations with examples.
    {{else}}
    Use a balanced approach.
    {{end}}

    Help the user with their request.
```

## Conditional Agent

Agent with complex conditional logic:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: adaptive-assistant
spec:
  parameters:
    - name: skill_level
      valueFrom:
        queryParameterRef:
          name: skill_level
    - name: verbosity
      valueFrom:
        queryParameterRef:
          name: verbosity
    - name: language
      valueFrom:
        queryParameterRef:
          name: language
  prompt: |
    {{- if and (eq .skill_level "expert") (eq .verbosity "high") }}
    You are an advanced technical assistant. Provide comprehensive, in-depth
    explanations with technical details and code examples.
    {{- else if and (eq .skill_level "expert") (eq .verbosity "low") }}
    You are a technical assistant for experts. Be concise and precise.
    {{- else if eq .skill_level "beginner" }}
    You are a patient teacher. Explain concepts from the ground up with
    clear examples and analogies.
    {{- else }}
    You are a helpful assistant providing balanced explanations.
    {{- end }}

    {{- if .language }}
    Respond in {{.language}}.
    {{- end }}
```

## Tool-Using Agent

Agent with multiple tools:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: research-assistant
spec:
  description: "Research assistant with search and analysis tools"
  prompt: |
    You are a research assistant with access to search and analysis tools.

    When users ask questions:
    1. Use search tools to find relevant information
    2. Analyze and synthesize findings
    3. Present clear, well-sourced answers

    Always cite your sources.
  tools:
    - name: web-search
    - name: document-analyzer
    - name: citation-formatter
```

## Agent with ConfigMap Parameters

Shared configuration:

```yaml
# ConfigMap with shared guidelines
apiVersion: v1
kind: ConfigMap
metadata:
  name: assistant-config
data:
  behavior: |
    Be concise and direct.
    Do not ask follow-up questions unless absolutely necessary.
    Do not apologize excessively.
  formatting: |
    Use bullet points for lists.
    Use code blocks for code.
    Bold key terms.
---
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: configured-assistant
spec:
  parameters:
    - name: behavior
      valueFrom:
        configMapKeyRef:
          name: assistant-config
          key: behavior
    - name: formatting
      valueFrom:
        configMapKeyRef:
          name: assistant-config
          key: formatting
  prompt: |
    You are a helpful assistant.

    ## Behavior Guidelines
    {{.behavior}}

    ## Formatting Guidelines
    {{.formatting}}
```

## Agent with Structured Output

JSON output schema:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: data-extractor
spec:
  description: "Extracts structured data from text"
  prompt: |
    Extract the following information from the provided text:
    - Key entities (people, organizations, locations)
    - Main topics discussed
    - Sentiment (positive, negative, neutral)
    - Action items if any
  outputSchema:
    type: object
    properties:
      entities:
        type: array
        items:
          type: object
          properties:
            name:
              type: string
            type:
              type: string
              enum: ["person", "organization", "location", "other"]
            confidence:
              type: number
              minimum: 0
              maximum: 1
      topics:
        type: array
        items:
          type: string
      sentiment:
        type: object
        properties:
          label:
            type: string
            enum: ["positive", "negative", "neutral", "mixed"]
          score:
            type: number
      action_items:
        type: array
        items:
          type: object
          properties:
            task:
              type: string
            assignee:
              type: string
            priority:
              type: string
              enum: ["high", "medium", "low"]
    required: ["entities", "topics", "sentiment"]
```

## Agent with Model Reference

Using specific model:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: creative-writer
spec:
  prompt: |
    You are a creative writing assistant.
    Help users with storytelling, poetry, and creative content.
  modelRef:
    name: creative-model  # Reference to a Model resource
```

## Agent with Optional Parameters

Handling missing parameters gracefully:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: flexible-assistant
spec:
  parameters:
    - name: user_name
      valueFrom:
        queryParameterRef:
          name: user_name
    - name: preferences
      valueFrom:
        queryParameterRef:
          name: preferences
    - name: max_length
      valueFrom:
        queryParameterRef:
          name: max_length
  prompt: |
    {{- if .user_name }}
    Hello {{.user_name}}!
    {{- else }}
    Hello!
    {{- end }}

    You are a helpful assistant.

    {{- if .preferences }}

    User preferences: {{.preferences}}
    {{- end }}

    {{- if .max_length }}

    Keep responses under {{.max_length}} words.
    {{- end }}
```

## Agent for Tool Use (with Description)

When agent is used as a tool:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: code-reviewer
spec:
  # IMPORTANT: description is required when used as tool
  description: "Reviews code for bugs, style issues, and improvements"
  prompt: |
    You are an expert code reviewer.

    When reviewing code:
    1. Check for bugs and logic errors
    2. Identify style and formatting issues
    3. Suggest performance improvements
    4. Note security concerns

    Provide specific, actionable feedback with line references.
```
