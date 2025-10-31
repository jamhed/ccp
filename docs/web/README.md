---
title: Anthropic Documentation Archive
fetched: 2025-10-31
purpose: Reference documentation for building Claude-based agents and tools
---

# Anthropic Documentation Archive

This directory contains fetched documentation from Anthropic's official Claude documentation site (docs.claude.com, formerly docs.anthropic.com). The documentation provides comprehensive guidance for building AI agents, tools, and applications using Claude.

## Available Documentation

### Core Concepts

1. **[Prompt Engineering](./anthropic-prompt-engineering.md)** - Best practices for Claude 4.x
   - Explicit instructions and context
   - Long-horizon reasoning and state tracking
   - Tool usage patterns
   - Code generation best practices
   - Migration considerations for Claude 4.5

2. **[Tool Use](./anthropic-tool-use.md)** - Extending Claude's capabilities
   - Client vs server tools
   - Parallel and sequential tool execution
   - JSON mode for structured output
   - Pricing structure and optimization

### Agent Development

3. **[Agent Skills](./anthropic-agent-skills.md)** - Modular capabilities for agents
   - Progressive disclosure architecture (3-level loading)
   - Skill structure and requirements
   - Platform availability and limitations
   - Security considerations

4. **[Agent SDK Overview](./anthropic-agent-sdk-overview.md)** - Building custom agents
   - Installation and setup
   - Core capabilities (context management, tool ecosystem, permissions)
   - Authentication options
   - Advanced features (subagents, skills, hooks)

5. **[TypeScript Agent SDK](./anthropic-agent-sdk-typescript.md)** - Complete API reference
   - Core functions (query, tool, createSdkMcpServer)
   - Configuration options
   - Message types and streaming
   - Built-in tools reference
   - Hook system and permission management
   - MCP server configuration

6. **[Agent SDK Migration](./anthropic-agent-sdk-migration.md)** - Migrating from Claude Code SDK
   - Package name changes
   - Breaking changes
   - Migration steps for TypeScript and Python

### Status Notes

7. **[Agents 404 Note](./anthropic-agents-404-note.md)** - Documentation page not found
   - Alternative resources available
   - Recommendations for finding agent content

## Key Insights for Issue Management Tools

Based on the documentation fetched, here are the most relevant insights for building issue management tools:

### 1. Structured State Tracking
From prompt engineering docs:
- Use JSON for schema-based information (perfect for issue metadata, status tracking)
- Unstructured text for progress narratives (issue descriptions, comments)
- Git logs for historical checkpoints (issue history, audit trails)
- Emphasis on incremental progress tracking

### 2. Multi-Context Window Workflows
For long-running issue management:
- **First context window**: Establish issue frameworks, triage processes, create templates
- **Structured state tracking**: Store issue data in JSON format
- **Version control**: Git for issue state checkpoints
- **Verification tools**: Automated validation of issue resolution

### 3. Agent Skills Architecture
For modular issue management capabilities:
- **Level 1 (Metadata)**: ~100 tokens - skill discovery for issue operations
- **Level 2 (Instructions)**: <5k tokens - procedural knowledge for triage, assignment, resolution
- **Level 3 (Resources)**: On-demand loading of templates, schemas, scripts

### 4. Built-in Tools for Issue Management
Highly relevant tools from the SDK:
- **TodoWrite**: Manage structured task lists (perfect for issue tracking)
- **Read/Write/Edit**: File operations for issue persistence
- **Grep/Glob**: Search across issues and metadata
- **Bash**: Execute automation scripts
- **WebFetch/WebSearch**: Research issues and gather context

### 5. Permission Management
For controlled issue operations:
- `'default'`: Standard permission prompts for sensitive operations
- `'acceptEdits'`: Auto-approve issue updates
- `'bypassPermissions'`: For automated workflows
- `'plan'`: Planning mode for issue resolution strategies

### 6. Hook System for Issue Lifecycle
Custom logic at key events:
- `PreToolUse` / `PostToolUse`: Validate issue operations
- `SessionStart` / `SessionEnd`: Track issue resolution sessions
- `Notification`: Alert on issue state changes
- `PreCompact`: Preserve important issue context

### 7. Subagents for Specialized Tasks
Define subagents for different issue types:
```typescript
{
  description: "Handle bug reports and technical issues",
  tools: ["Read", "Write", "Grep", "Bash"],
  prompt: "You are a technical bug triage specialist...",
  model: "sonnet"
}
```

### 8. MCP Integration
Model Context Protocol for external systems:
- Connect to issue tracking systems (Jira, GitHub)
- Integrate with CI/CD for automated issue creation
- Access databases for issue persistence

### 9. Parallel Tool Execution
For efficient issue processing:
- Read multiple issue files simultaneously
- Search across issues in parallel
- Batch update multiple issues

### 10. Prompt Engineering for Issue Management

**Be explicit:**
```
"Triage this issue. Determine severity (critical/high/medium/low),
assign to appropriate team, add relevant labels, and create a
resolution plan with specific action items."
```

**Add context:**
```
"This project uses semantic versioning and follows a weekly release
cycle. Critical bugs block releases, so prioritize them highest."
```

**Avoid hallucinations:**
```
"Never speculate about issue details you haven't read. If the user
references an issue, you MUST read it first. Investigate and read
the complete issue history BEFORE making recommendations."
```

## Usage Recommendations

### For Building Issue Management Agents

1. **Use Agent Skills** for modular issue operations:
   - `issue-triage` skill for classification and prioritization
   - `issue-assignment` skill for routing to appropriate teams
   - `issue-resolution` skill for fix validation and closure

2. **Leverage Built-in Tools**:
   - `TodoWrite` for tracking issue resolution progress
   - `Grep` for searching across issue history
   - File operations for persistent issue storage
   - `WebSearch` for researching similar issues

3. **Implement Hooks** for issue lifecycle management:
   - Track all issue state transitions
   - Log resolution attempts and outcomes
   - Validate issue data before persistence
   - Send notifications on status changes

4. **Use Structured State**:
   ```json
   {
     "issue_id": "ISS-123",
     "status": "in_progress",
     "severity": "high",
     "assignee": "team-backend",
     "created": "2025-10-31T10:00:00Z",
     "resolution_plan": [...],
     "history": [...]
   }
   ```

5. **Configure Permissions** appropriately:
   - Use `'default'` mode for manual review during development
   - Use `'acceptEdits'` for trusted automated workflows
   - Use `'plan'` mode for generating resolution strategies

6. **Design for Long-Horizon Work**:
   - Break complex issues into subtasks
   - Track progress across multiple sessions
   - Use Git for issue state versioning
   - Implement autonomous validation

## Documentation Limitations

Note that several guide pages returned 404 errors during fetching:
- Custom tools guide
- Subagents guide
- Hooks guide
- Python SDK reference

These topics are mentioned in the overview documentation but detailed guides were not accessible. For complete information, refer to the live documentation at https://docs.claude.com/

## Fetching Details

- **Fetch Date**: 2025-10-31
- **Original URLs**: docs.anthropic.com (redirected to docs.claude.com)
- **Status**: Complete for available pages
- **Missing**: Detailed guides for custom tools, subagents, hooks, Python SDK

## Related Resources

- Official documentation: https://docs.claude.com/
- Agent SDK GitHub (TypeScript): Referenced in migration docs
- Agent SDK GitHub (Python): Referenced in migration docs
- Claude Code CLI: Built-in documentation and help commands
