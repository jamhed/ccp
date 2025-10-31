---
source: https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/overview
redirect: https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview
fetched: 2025-10-31
status: complete
---

# Agent Skills Documentation

## Overview
Agent Skills are modular capabilities extending Claude's functionality. Each skill packages instructions, metadata, and optional resources (scripts, templates) that Claude uses automatically when relevant.

## Key Benefits
- **Specialization**: Tailor capabilities for domain-specific tasks
- **Reusability**: Create once, use automatically across conversations
- **Composition**: Combine multiple Skills for complex workflows

## Progressive Disclosure Architecture

Skills use a three-level loading model to optimize context usage:

**Level 1 - Metadata (Always Loaded)**
YAML frontmatter provides discovery information (~100 tokens per skill). Claude knows each skill exists and when to trigger it.

**Level 2 - Instructions (Triggered On-Demand)**
Main SKILL.md body loads when matched to user requests. Contains procedural knowledge under 5k tokens.

**Level 3 - Resources (As Needed)**
Bundled files (schemas, templates, scripts) load only when referenced. Scripts execute via bash without loading code into context.

## Skill Structure Requirements

Every skill requires a SKILL.md file with YAML frontmatter:

```yaml
---
name: your-skill-name
description: Clear description of functionality and usage triggers
---
```

**Field constraints:**
- `name`: Max 64 characters, lowercase letters/numbers/hyphens only
- `description`: Max 1024 characters, non-empty

## Platform Availability

| Platform | Pre-built Skills | Custom Skills |
|----------|------------------|---------------|
| Claude API | Yes (pptx, xlsx, docx, pdf) | Yes |
| Claude Code | No | Yes (filesystem-based) |
| Agent SDK | No | Yes |
| Claude.ai | Yes | Yes (user-only) |

## Available Pre-built Skills

- **PowerPoint (pptx)**: Presentations and slide management
- **Excel (xlsx)**: Spreadsheets and data analysis
- **Word (docx)**: Document creation and formatting
- **PDF (pdf)**: Formatted document generation

## Security Considerations

"We strongly recommend using Skills only from trusted sources." Audit all bundled files before deployment. Malicious Skills can direct Claude to invoke tools or execute code harmfully, potentially leading to data exfiltration or unauthorized access.

## Limitations

**Cross-surface Incompatibility**: Skills don't sync between platforms—separate uploads required for each surface.

**Sharing Models:**
- Claude.ai: Individual users only
- Claude API: Workspace-wide access
- Claude Code: Personal or project-based

**Runtime Constraints:**
- No network access or external API calls
- No runtime package installation
- Pre-configured dependencies only

## Implementation Pattern

When triggered, Claude uses bash to read SKILL.md from the filesystem. Referenced files load via additional bash commands. Scripts execute without their code entering context—only output is consumed, making complex operations token-efficient.
