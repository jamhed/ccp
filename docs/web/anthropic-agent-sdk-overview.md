---
source: https://docs.anthropic.com/en/api/agent-sdk/overview
redirect: https://docs.claude.com/en/api/agent-sdk/overview
fetched: 2025-10-31
status: complete
---

# Claude Agent SDK Documentation

## Overview
The Claude Agent SDK enables developers to build custom AI agents leveraging Anthropic's Claude model. As noted in the documentation, "The Claude Code SDK has been renamed to the **Claude Agent SDK**."

## Installation & Setup

**TypeScript Installation:**
```
npm install @anthropic-ai/claude-agent-sdk
```

The SDK offers both TypeScript and Python implementations for different use cases.

## Core Capabilities

The SDK provides several integrated features:

- **Context Management**: Automatic compaction ensures agents remain within token limits
- **Tool Ecosystem**: File operations, code execution, web search, and Model Context Protocol (MCP) extensibility
- **Permission Controls**: Fine-grained tool access management via `allowedTools`, `disallowedTools`, and `permissionMode`
- **Production Features**: Built-in error handling, session management, and monitoring
- **Performance**: Automatic prompt caching and optimization

## Authentication Options

Users can authenticate through:
- Direct Claude API key (via `ANTHROPIC_API_KEY` environment variable)
- Amazon Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`)
- Google Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`)

## Agent Types

The documentation highlights example agents developers can create:

**Technical**: SRE agents for production diagnostics, security review bots, code review systems

**Business**: Legal document analysis, financial forecasting, customer support, content creation assistants

## Advanced Features

The SDK includes filesystem-based configuration supporting:
- Subagents stored in `./.claude/agents/`
- Agent Skills via `SKILL.md` files
- Custom hooks and slash commands
- Project memory through `CLAUDE.md` files

## Resources

- Bug reporting: GitHub repositories for TypeScript and Python SDKs
- Full changelogs available in respective GitHub repositories
- Migration guide provided for Claude Code SDK users
