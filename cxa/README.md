# CXA - Ark YAML Agent Development Plugin

A Claude Code plugin for developing YAML-based Ark agents with a structured problem-solving workflow.

## Overview

CXA (Claude X Ark) provides agents specialized for developing Ark platform YAML definitions:
- **Agents** - AI agent configurations with prompts and tools
- **Tools** - MCP tools, agent-as-tool, builtin tools
- **Queries** - Test queries to validate agent behavior

## Agents

| Agent | Description |
|-------|-------------|
| **Problem Researcher** | Researches Ark patterns and defines problems for YAML agent development |
| **Solution Proposer** | Proposes 2-4 YAML agent solutions based on research |
| **Solution Reviewer** | Evaluates proposals and selects optimal approach |
| **Solution Implementer** | Creates YAML files and tests agent behavior |

## Commands

```bash
/cxa:problem [description]    # Research and define YAML agent problem
/cxa:refine [issue-name]      # Enhance problem definition
/cxa:solve [issue-name]       # Execute full workflow (propose, review, implement)
```

## Workflow

1. **Problem Research** → `/cxa:problem "Create a greeting agent"`
   - Uses `Skill(cxa:ark-agent-dev)` for pattern reference
   - Searches project for existing YAML agents/tools
   - Creates `issues/[issue-name]/problem.md`

2. **Solution Workflow** → `/cxa:solve [issue-name]`
   - **Propose**: Creates 2-4 YAML solutions in `proposals.md`
   - **Review**: Selects best approach in `review.md`
   - **Implement**: Creates YAML files and `solution.md`

## Ark YAML Reference

### Agent Definition
```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Agent
metadata:
  name: agent-name
spec:
  description: "Agent description"
  prompt: |
    Your prompt with {{.parameter}} templating
  parameters:
    - name: param
      valueFrom:
        queryParameterRef:
          name: param
  tools:
    - name: tool-name
```

### Tool Definition
```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: tool-name
spec:
  type: agent  # or mcp, builtin
  description: "Tool description"
  inputSchema:
    type: object
    properties:
      input:
        type: string
    required: [input]
  agent:
    name: worker-agent
```

### Query Definition
```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Query
metadata:
  name: test-query
spec:
  input: "Test input"
  parameters:
    - name: param
      value: "value"
  targets:
    - type: agent
      name: agent-name
  timeout: 30s
```

## Skills

### ark-agent-dev

Comprehensive skill for developing YAML-based Ark agents. Use `Skill(cxa:ark-agent-dev)` for:

- **All Ark resource types**: Agent, Tool, Query, Team, Model, MCPServer
- **Go template syntax**: Variables, conditionals, loops, functions
- **Tool patterns**: Agent-as-tool, MCP, fetcher, built-in, partial tools
- **Team patterns**: Graph (sequential), round-robin, selector (coordinator)
- **Parameter patterns**: Query params, ConfigMap, static values, mixed

**Reference files**:
- `references/agent-patterns.md` - Agent configuration examples
- `references/tool-patterns.md` - All tool types with examples
- `references/team-patterns.md` - Multi-agent coordination
- `references/template-syntax.md` - Complete Go template reference

## Pattern Sources

The plugin uses these sources for Ark YAML patterns:

**Skill Reference** (`cxa:ark-agent-dev`):
- Agent patterns - simple, parameterized, conditional, tool-using
- Tool patterns - agent-as-tool, MCP, fetcher, partial tools
- Team patterns - graph, round-robin, selector
- Template syntax - Go templates, conditionals, functions
- Parameter patterns - query, configmap, static

**Project Search**:
- Searches current project for existing `kind: Agent`, `kind: Tool`, etc.
- Identifies conventions already in use

## Output Structure

```
issues/[issue-name]/
├── problem.md      # Problem definition
├── proposals.md    # 2-4 YAML solutions
├── review.md       # Selected solution
└── solution.md     # Implementation docs

[namespace]/
├── agents/
│   └── agent-name.yaml
├── tools/
│   └── tool-name.yaml
└── queries/
    └── query-name.yaml
```
