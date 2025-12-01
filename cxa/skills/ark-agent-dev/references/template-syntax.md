# Go Template Syntax Reference

Complete reference for Go templates in Ark YAML definitions.

## Basic Syntax

### Variable Access

```yaml
# Simple variable
prompt: "Hello {{.name}}"

# Nested object
prompt: "User: {{.user.name}}, Email: {{.user.email}}"

# Array element (0-indexed)
prompt: "First item: {{index .items 0}}"
```

### Whitespace Control

```yaml
# {{- trims leading whitespace
# -}} trims trailing whitespace

prompt: |
  {{- if .title}}
  Title: {{.title}}
  {{- end}}
  Content here.

# Without whitespace control:
#
#   Title: Example
#
#   Content here.

# With whitespace control:
#   Title: Example
#   Content here.
```

## Conditionals

### If Statement

```yaml
prompt: |
  {{if .condition}}
  This shows when condition is truthy.
  {{end}}
```

### If-Else

```yaml
prompt: |
  {{if .premium}}
  Welcome, premium user!
  {{else}}
  Welcome! Upgrade to premium for more features.
  {{end}}
```

### If-Else-If Chain

```yaml
prompt: |
  {{if eq .level "admin"}}
  Full administrative access.
  {{else if eq .level "moderator"}}
  Moderation tools available.
  {{else if eq .level "user"}}
  Standard user access.
  {{else}}
  Guest access only.
  {{end}}
```

### Negation

```yaml
prompt: |
  {{if not .disabled}}
  Feature is enabled.
  {{end}}
```

## Comparison Operators

### Equality

```yaml
# String equality
{{if eq .status "active"}}Active{{end}}

# Not equal
{{if ne .status "inactive"}}Not inactive{{end}}

# Numeric equality
{{if eq .count 0}}Empty{{end}}
```

### Numeric Comparisons

```yaml
# Less than
{{if lt .age 18}}Minor{{end}}

# Less than or equal
{{if le .age 65}}Working age{{end}}

# Greater than
{{if gt .score 90}}Excellent{{end}}

# Greater than or equal
{{if ge .score 60}}Passing{{end}}
```

### Boolean Operators

```yaml
# AND
{{if and .authenticated .authorized}}
Access granted.
{{end}}

# OR
{{if or .isAdmin .isModerator}}
Elevated privileges.
{{end}}

# Complex conditions
{{if and (eq .role "admin") (gt .experience 5)}}
Senior admin.
{{end}}

# Nested boolean
{{if or (eq .tier "gold") (and (eq .tier "silver") (gt .years 2))}}
Premium benefits.
{{end}}
```

## Loops

### Range Over Array

```yaml
prompt: |
  Items:
  {{range .items}}
  - {{.}}
  {{end}}
```

### Range with Index

```yaml
prompt: |
  {{range $index, $item := .items}}
  {{$index}}: {{$item}}
  {{end}}
```

### Range Over Map

```yaml
prompt: |
  {{range $key, $value := .config}}
  {{$key}} = {{$value}}
  {{end}}
```

### Range with Else (Empty Check)

```yaml
prompt: |
  {{range .items}}
  - {{.}}
  {{else}}
  No items found.
  {{end}}
```

## Variables

### Define Variable

```yaml
prompt: |
  {{$greeting := "Hello"}}
  {{$greeting}}, {{.name}}!
```

### Conditional Variable

```yaml
prompt: |
  {{$status := "unknown"}}
  {{if .active}}
    {{$status = "active"}}
  {{else}}
    {{$status = "inactive"}}
  {{end}}
  Status: {{$status}}
```

## Template Functions

### String Functions

```yaml
# URL encode
url: "https://api.com/search?q={{.query | urlEncode}}"

# JSON quote (adds quotes)
body: '{"name": {{.name | quote}}}'

# Convert to JSON
body: '{"tags": {{.tags | json}}}'

# Uppercase
header: "{{.name | upper}}"

# Lowercase
email: "{{.email | lower}}"
```

### String Manipulation

```yaml
# Trim whitespace
{{.text | trim}}

# Trim specific chars
{{.text | trimPrefix "http://"}}
{{.text | trimSuffix "/"}}

# Replace
{{.text | replace "old" "new"}}

# Contains check (in condition)
{{if contains .text "keyword"}}
Found keyword.
{{end}}

# Has prefix/suffix
{{if hasPrefix .url "https"}}Secure{{end}}
{{if hasSuffix .file ".yaml"}}YAML file{{end}}
```

### Default Values

```yaml
# Use default if empty
prompt: "Language: {{.language | default "English"}}"

# Coalesce (first non-empty)
prompt: "Name: {{coalesce .nickname .firstName .username "Anonymous"}}"
```

### Type Conversion

```yaml
# To string
{{.number | toString}}

# To int
{{.text | toInt}}

# To float
{{.text | toFloat}}

# To bool
{{.text | toBool}}
```

### List Functions

```yaml
# Join array elements
tags: "{{.tags | join ", "}}"

# First/Last element
first: "{{first .items}}"
last: "{{last .items}}"

# Length
count: "{{len .items}}"

# Check if empty
{{if empty .items}}No items{{end}}
```

## Practical Examples

### Optional Parameters

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: flexible-agent
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
    - name: max_tokens
      valueFrom:
        queryParameterRef:
          name: max_tokens
  prompt: |
    You are a helpful assistant.
    {{- if .context}}

    Context: {{.context}}
    {{- end}}
    {{- if .format}}

    Output format: {{.format}}
    {{- end}}
    {{- if .max_tokens}}

    Keep response under {{.max_tokens}} tokens.
    {{- end}}
```

### Multi-Level Conditionals

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: adaptive-agent
spec:
  parameters:
    - name: expertise
      valueFrom:
        queryParameterRef:
          name: expertise
    - name: verbosity
      valueFrom:
        queryParameterRef:
          name: verbosity
  prompt: |
    {{- if and (eq .expertise "expert") (eq .verbosity "high") }}
    Provide comprehensive technical analysis with implementation details,
    edge cases, and performance considerations.
    {{- else if and (eq .expertise "expert") (eq .verbosity "low") }}
    Be concise. Assume deep technical knowledge.
    {{- else if and (eq .expertise "beginner") (eq .verbosity "high") }}
    Explain step by step with examples and analogies.
    No jargon. Be patient and thorough.
    {{- else if and (eq .expertise "beginner") (eq .verbosity "low") }}
    Give simple, clear answers. Avoid technical terms.
    {{- else }}
    Provide balanced explanations suitable for general audience.
    {{- end }}
```

### Dynamic Tool URL

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: api-call
spec:
  type: fetcher
  inputSchema:
    type: object
    properties:
      resource:
        type: string
      id:
        type: integer
      filters:
        type: object
    required: [resource]
  fetcher:
    url: |
      https://api.example.com/{{.resource}}{{if .id}}/{{.id}}{{end}}{{if .filters}}?{{range $k, $v := .filters}}{{$k}}={{$v | urlEncode}}&{{end}}{{end}}
    method: GET
```

### Complex JSON Body

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: create-entity
spec:
  type: fetcher
  inputSchema:
    type: object
    properties:
      name:
        type: string
      type:
        type: string
      attributes:
        type: object
      tags:
        type: array
        items:
          type: string
    required: [name, type]
  fetcher:
    url: "https://api.example.com/entities"
    method: POST
    headers:
      - name: Content-Type
        value:
          value: "application/json"
    body: |
      {
        "name": {{.name | quote}},
        "type": {{.type | quote}},
        {{- if .attributes}}
        "attributes": {{.attributes | json}},
        {{- end}}
        {{- if .tags}}
        "tags": {{.tags | json}},
        {{- end}}
        "created_at": "{{now | date "2006-01-02T15:04:05Z07:00"}}"
      }
```

### Partial Tool with Query Reference

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: parameterized-tools
spec:
  parameters:
    - name: region
      valueFrom:
        queryParameterRef:
          name: region
    - name: format
      valueFrom:
        queryParameterRef:
          name: format
  prompt: |
    You are a location assistant for {{.region | default "global"}} region.
  tools:
    - name: local-search
      description: "Search with region pre-configured"
      partial:
        name: global-search
        parameters:
          - name: region
            value: "{{ .Query.region | default \"us\" }}"
          - name: output_format
            value: "{{ .Query.format | default \"json\" }}"
```

## Common Patterns

| Pattern | Syntax |
|---------|--------|
| Optional section | `{{- if .var}}...{{end}}` |
| Default value | `{{.var \| default "value"}}` |
| String equality | `{{if eq .var "value"}}` |
| Multiple conditions | `{{if and .a .b}}` or `{{if or .a .b}}` |
| Nested check | `{{if and (eq .x "a") (gt .y 5)}}` |
| URL encode | `{{.var \| urlEncode}}` |
| JSON string | `{{.var \| quote}}` |
| To JSON | `{{.var \| json}}` |
| Trim whitespace | `{{- ... -}}` |

## Gotchas

1. **Whitespace**: Use `{{-` and `-}}` to control whitespace
2. **Nil checks**: `{{if .var}}` is false for nil, empty string, 0, false
3. **Nested access**: `{{.a.b}}` fails if `.a` is nil - check first
4. **Quote JSON strings**: Use `{{.var | quote}}` not `"{{.var}}"`
5. **URL params**: Always use `{{.var | urlEncode}}`
