---
source: https://docs.anthropic.com/en/api/agent-sdk/typescript
redirect: https://docs.claude.com/en/api/agent-sdk/typescript
fetched: 2025-10-31
status: complete
---

# TypeScript Agent SDK Reference - Complete Documentation

## Overview

The TypeScript Agent SDK provides a comprehensive interface for interacting with Claude Code programmatically. This documentation covers installation, core functions, types, message formats, hooks, and tool definitions.

## Installation

```
npm install @anthropic-ai/claude-agent-sdk
```

## Core Functions

### query()

The primary function for Claude Code interactions creates an asynchronous generator streaming messages.

**Signature:**
```typescript
function query({
  prompt,
  options
}: {
  prompt: string | AsyncIterable<SDKUserMessage>;
  options?: Options;
}): Query
```

**Parameters:**
- `prompt`: Input as string or async iterable for streaming
- `options`: Optional configuration object

**Returns:** Query object extending AsyncGenerator with `interrupt()` and `setPermissionMode()` methods.

### tool()

Creates type-safe MCP tool definitions using Zod schemas.

```typescript
function tool<Schema extends ZodRawShape>(
  name: string,
  description: string,
  inputSchema: Schema,
  handler: (args, extra) => Promise<CallToolResult>
): SdkMcpToolDefinition<Schema>
```

### createSdkMcpServer()

Instantiates an in-process MCP server.

```typescript
function createSdkMcpServer(options: {
  name: string;
  version?: string;
  tools?: Array<SdkMcpToolDefinition<any>>;
}): McpSdkServerConfigWithInstance
```

## Configuration Options

The `Options` type controls query behavior with properties including:

- `model`: Claude model selection
- `cwd`: Working directory (defaults to `process.cwd()`)
- `allowedTools` / `disallowedTools`: Tool access control
- `permissionMode`: 'default' | 'acceptEdits' | 'bypassPermissions' | 'plan'
- `maxTurns`: Conversation turn limit
- `systemPrompt`: Custom or preset instructions
- `settingSources`: Load filesystem settings ('user' | 'project' | 'local')
- `mcpServers`: MCP server configurations
- `agents`: Programmatic subagent definitions
- `hooks`: Event callbacks

**Key Note:** When `settingSources` is omitted, the SDK loads no filesystem settings, ensuring isolation for SDK applications.

## Message Types

All messages extend a base structure with `type`, `uuid`, and `session_id` fields.

### SDKAssistantMessage
Contains Claude's response with `APIAssistantMessage` and parent tool reference.

### SDKUserMessage
User input with optional UUID and parent tool reference.

### SDKResultMessage
Final result with success/error subtypes, including duration, token usage, cost, and permission denials.

### SDKSystemMessage
System initialization with tools, MCP servers, model, and permission mode details.

### SDKPartialAssistantMessage
Streaming events (only with `includePartialMessages: true`).

### SDKCompactBoundaryMessage
Conversation compaction metadata with trigger and token information.

## Built-in Tools

### File Operations
- **Read**: Read text, images, PDFs, Jupyter notebooks
- **Write**: Write files to filesystem
- **Edit**: Perform exact string replacements
- **Glob**: Fast file pattern matching
- **Grep**: Regex-powered search with ripgrep

### Execution
- **Bash**: Execute commands with optional timeout and background execution
- **BashOutput**: Retrieve background shell output
- **KillBash**: Terminate background processes
- **NotebookEdit**: Modify Jupyter notebook cells

### Web & Search
- **WebFetch**: Fetch and process URL content
- **WebSearch**: Web search with domain filtering

### Task Management
- **Task**: Delegate work to specialized subagents
- **TodoWrite**: Manage structured task lists
- **ExitPlanMode**: Exit planning mode for user approval

### MCP Resources
- **ListMcpResources**: Enumerate available MCP resources
- **ReadMcpResource**: Access specific resource contents

## Hook System

Hooks enable custom logic at key events. Available events:
- `PreToolUse` / `PostToolUse`
- `UserPromptSubmit`
- `SessionStart` / `SessionEnd`
- `Notification`
- `Stop` / `SubagentStop`
- `PreCompact`

**Hook Signature:**
```typescript
type HookCallback = (
  input: HookInput,
  toolUseID: string | undefined,
  options: { signal: AbortSignal }
) => Promise<HookJSONOutput>;
```

Hooks return control flow directives, permission decisions, and contextual metadata.

## Permission Management

### PermissionMode Types
- `'default'`: Standard permission prompts
- `'acceptEdits'`: Auto-approve file modifications
- `'bypassPermissions'`: Skip all permission checks
- `'plan'`: Planning-only mode without execution

### CanUseTool
Custom permission function controlling tool access per invocation.

### PermissionUpdate
Modify rules, add/remove directories, or change modes with destination targeting (userSettings, projectSettings, localSettings, or session).

## MCP Server Configuration

Three connection types supported:

1. **Stdio**: Local subprocess via `command` and `args`
2. **SSE**: Server-Sent Events via HTTP URL
3. **HTTP**: Direct HTTP endpoint
4. **SDK**: In-process instance via `createSdkMcpServer()`

## Agent Definitions

Define subagents programmatically:

```typescript
type AgentDefinition = {
  description: string;      // When to use this agent
  tools?: string[];         // Allowed tools (inherits all if omitted)
  prompt: string;           // System instructions
  model?: 'sonnet' | 'opus' | 'haiku' | 'inherit';
}
```

## Settings Sources

Control which filesystem configurations load:
- `'user'`: `~/.claude/settings.json`
- `'project'`: `.claude/settings.json`
- `'local'`: `.claude/settings.local.json`

Precedence (highest to lowest): local > project > user. Programmatic options always override filesystem settings.

## Error Handling

The SDK exports `AbortError` for abort operations and supports standard AbortController cancellation patterns.

## Usage Statistics

Query results include `NonNullableUsage` with guaranteed (non-nullable) fields:
- `input_tokens`
- `output_tokens`
- `cache_creation_input_tokens`
- `cache_read_input_tokens`

## Plugins

Load custom plugins from local paths:

```typescript
plugins: [
  { type: 'local', path: './my-plugin' },
  { type: 'local', path: '/absolute/path/to/plugin' }
]
```

## Key Design Patterns

**Streaming Support:** Both single prompts and async iterable streams for continuous input.

**Type Safety:** Zod schemas ensure compile-time and runtime validation.

**Isolation by Default:** No filesystem settings loaded unless explicitly specified via `settingSources`.

**Extensibility:** Hooks, custom permissions, subagents, and MCP servers enable flexible integration.
