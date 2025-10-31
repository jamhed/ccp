---
source: https://docs.claude.com/en/docs/claude-code
fetched: 2025-10-31
status: complete
topic: Claude Agent SDK Migration
---

# Migration to Claude Agent SDK

## Overview
The Claude Code SDK has been rebranded as the **Claude Agent SDK** to better reflect its expanded capabilities beyond coding tasks.

## Key Changes

**Package Names:**
- TypeScript/JavaScript: `@anthropic-ai/claude-code` → `@anthropic-ai/claude-agent-sdk`
- Python: `claude-code-sdk` → `claude-agent-sdk`

**Documentation:** Moved from Claude Code docs to dedicated API Guide section

## Migration Steps

### TypeScript/JavaScript
1. Uninstall old package: `npm uninstall @anthropic-ai/claude-code`
2. Install new: `npm install @anthropic-ai/claude-agent-sdk`
3. Update imports from `@anthropic-ai/claude-code` to `@anthropic-ai/claude-agent-sdk`

### Python
1. Uninstall: `pip uninstall claude-code-sdk`
2. Install: `pip install claude-agent-sdk`
3. Update imports: `claude_code_sdk` → `claude_agent_sdk`
4. Rename type: `ClaudeCodeOptions` → `ClaudeAgentOptions`

## Breaking Changes

**System Prompt:** No longer defaults to Claude Code's system prompt. Explicitly specify using `systemPrompt` option if needed.

**Settings Sources:** The SDK no longer automatically loads filesystem settings (CLAUDE.md, settings.json, etc.). To restore this behavior, add `settingSources: ['user', 'project', 'local']` to options.

This change ensures predictable behavior in CI/CD, deployed applications, and multi-tenant systems.

## Rationale
The rename reflects the SDK's evolution into a framework for building diverse AI agents across multiple domains, not just coding tasks.
