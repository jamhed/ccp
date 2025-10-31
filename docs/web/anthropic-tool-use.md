---
source: https://docs.anthropic.com/en/docs/build-with-claude/tool-use
redirect: https://docs.claude.com/en/docs/build-with-claude/tool-use
fetched: 2025-10-31
status: complete
---

# Tool Use with Claude - Documentation Summary

## Overview

Claude can interact with tools and functions to extend its capabilities. The platform supports two distinct tool categories: client tools (executed on your systems) and server tools (executed on Anthropic's servers).

## How Tool Use Works

### Client Tools
The workflow involves four steps:
1. Provide Claude with tool definitions including names, descriptions, and input schemas
2. Claude assesses whether tools can help and constructs formatted requests
3. Execute the tool on your system and return results via `tool_result` blocks
4. Claude analyzes results to formulate its response

### Server Tools
Server tools like web search and web fetch follow a simpler pattern where Claude executes them directly, and results are automatically incorporated into responses without requiring manual implementation.

## Key Capabilities

**Parallel Tool Use**: Claude can call multiple tools simultaneously within a single response, with all corresponding results provided in one user message.

**Sequential Tools**: For dependent operations, Claude calls tools sequentially, using earlier outputs as inputs for subsequent calls.

**Chain of Thought**: By default, Claude Opus thinks before answering tool queries. For Sonnet and Haiku models, adding explicit reasoning prompts improves parameter assessment before tool invocation.

**JSON Mode**: Tools can enforce structured output by defining single tools with specific schemas and setting `tool_choice` to force their use.

## Pricing Structure

Tool use pricing includes:
- Input and output tokens
- Tokens from the `tools` parameter (names, descriptions, schemas)
- `tool_use` and `tool_result` content blocks
- Additional usage-based charges for server-side tools

A special system prompt enables tool use, with token counts varying by model. For example, Claude Sonnet 4.5 adds 346 tokens with `auto` or `none` tool choice, and 313 tokens with `any` or `tool` choice.

## Best Practices

- Provide clear, detailed tool descriptions
- Include comprehensive input schema definitions
- For ambiguous queries, prompt models to clarify missing parameters
- Test tool implementations with various scenarios
- Monitor token usage for optimization
