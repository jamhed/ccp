---
source: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering
redirect: https://docs.claude.com/en/docs/build-with-claude/prompt-engineering
fetched: 2025-10-31
status: complete
---

# Prompting Best Practices for Claude 4.x

## Overview

This guide provides specific prompt engineering techniques for Claude 4.x models, particularly Sonnet 4.5 and Haiku 4.5, which have been trained for more precise instruction following than previous generations.

## Core Principles

### Be Explicit with Instructions

Claude 4.x responds well to clear, specific guidance. Rather than general requests, specify desired outputs explicitly. For example, instead of "Create an analytics dashboard," use "Create an analytics dashboard. Include as many relevant features and interactions as possible. Go beyond the basics to create a fully-featured implementation."

### Add Context for Performance

Providing reasoning behind instructions helps Claude understand your goals better. Explain *why* a behavior matters. For instance, instead of "NEVER use ellipses," explain "Your response will be read aloud by a text-to-speech engine, so never use ellipses since the engine won't know how to pronounce them."

### Pay Attention to Examples

Claude 4.x models closely examine examples and details as part of their instruction-following capabilities. Ensure examples align with desired behaviors and minimize unintended patterns.

## Long-Horizon Reasoning & State Tracking

### Context Awareness

Claude 4.5 tracks its remaining context window throughout conversations, enabling more effective task management. For systems using context compaction or external file saving, communicate this to Claude so it doesn't artificially halt work due to token concerns.

### Multi-Context Window Workflows

When tasks span multiple sessions:

- **First context window**: Establish frameworks, write tests, create setup scripts
- **Structured state tracking**: Use JSON for test results, unstructured text for progress notes
- **Version control**: Git provides checkpoints and activity logs that Claude can leverage
- **Verification tools**: Include testing capabilities for autonomous validation

### State Management

Use appropriate formats:
- Structured data (JSON) for schema-based information
- Unstructured text for progress narratives
- Git logs for historical checkpoints
- Emphasis on incremental progress tracking

## Communication Style

Claude 4.5 demonstrates:
- **More direct communication**: Fact-based progress reports rather than celebratory language
- **Conversational tone**: More natural and less formulaic
- **Efficiency-focused**: May skip verbose summaries unless explicitly requested

## Practical Guidance

### Balance Verbosity

If you want visibility into Claude's reasoning after tool use, request summaries explicitly: "After completing a task involving tool use, provide a quick summary of work completed."

### Tool Usage Patterns

Claude 4.5 benefits from explicit action directives. Rather than "Can you suggest changes?" use "Change this function to improve performance" or "Make these edits to the authentication flow."

For proactive behavior, include guidance like: "By default, implement changes rather than only suggesting them. Infer the most useful likely action and proceed, using tools to discover missing details instead of guessing."

### Response Format Control

**Effective techniques:**
- Tell Claude what to do instead of what not to do
- Use XML format indicators for sections
- Match your prompt style to desired output style
- Provide explicit guidance for markdown minimization

Example for prose output: "Write in clear, flowing prose using complete paragraphs. Reserve markdown primarily for inline code, code blocks, and simple headings. Avoid bullet points unless truly discrete items warrant a list format."

### Research & Information Gathering

Define success criteria and encourage source verification. For complex research, use structured approaches: develop competing hypotheses, track confidence levels, maintain research notes files, and employ systematic breakdown of tasks.

### Subagent Orchestration

Claude 4.5 naturally recognizes when tasks benefit from delegated subagents without explicit instruction. Ensure subagent tools have clear descriptions, and let Claude orchestrate appropriately.

### Model Self-Knowledge

If your application needs specific model identification, provide it explicitly. For API strings, use: "When an LLM is needed, default to Claude Sonnet 4.5 unless the user requests otherwise. The model string is claude-sonnet-4-5-20250929."

### Thinking Capabilities

Guide Claude to reflect after tool use: "Carefully reflect on tool results and determine optimal next steps before proceeding. Use thinking to plan and iterate based on new information, then take the best next action."

### Document & Visual Creation

Claude 4.5 excels at presentations and animations. Request explicitly: "Create a professional presentation on [topic]. Include thoughtful design elements, visual hierarchy, and engaging animations where appropriate."

### Parallel Tool Execution

Claude 4.5 aggressively fires parallel operations. Maximize this with: "If you intend to call multiple tools with no dependencies between them, make all independent calls in parallel. Prioritize simultaneous execution whenever possible."

Alternatively, reduce aggression: "Execute operations sequentially with brief pauses between steps to ensure stability."

### Code Generation Best Practices

**Reduce unnecessary file creation:** "If you create temporary files for iteration, clean them up at the end of the task."

**Enhance UI/frontend output:** Explicitly encourage creativity: "Give it your all. Create an impressive demonstration showcasing web development capabilities." Specify aesthetic direction with color palettes, typography, and design principles.

**Avoid test-focused solutions:** "Write high-quality, general-purpose solutions. Don't hard-code values or create workarounds for specific test cases. Implement actual logic that solves problems generally."

**Minimize hallucinations:** "Never speculate about code you haven't opened. If the user references a specific file, you MUST read it before answering. Investigate and read relevant files BEFORE answering questions about the codebase."

## Migration Considerations

When moving to Claude 4.5:

- Be specific about desired output details
- Add modifiers encouraging quality: "Go beyond basics to create fully-featured implementation"
- Explicitly request animations and interactive elements when wanted

---

**Key Takeaway:** Claude 4.x models prioritize precision in instruction following, so explicit, context-rich prompts with clear success criteria yield optimal results across diverse tasks.
