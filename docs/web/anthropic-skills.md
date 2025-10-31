# Claude Code Skills Documentation

**Source:** https://docs.claude.com/en/docs/claude-code/skills
**Fetched:** 2025-10-31

## SKILL.md Structure

Skills require a YAML frontmatter header followed by Markdown content:

```yaml
---
name: your-skill-name
description: Brief description of what this Skill does and when to use it
---

# Your Skill Name

## Instructions
Provide clear, step-by-step guidance for Claude.
```

**Field Requirements:**
- `name`: Lowercase letters, numbers, hyphens only (max 64 characters)
- `description`: Explains both functionality and usage context (max 1024 characters)

## Description Best Practices

The description is critical for skill discovery. It should communicate:
- **What the skill does**: Specific capabilities and features
- **When to use it**: Trigger terms users would mention

**Effective example**: "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."

**Ineffective example**: "Helps with documents"

## Skill File Organization

Skills can include supporting files alongside `SKILL.md`:

```
my-skill/
├── SKILL.md (required)
├── reference.md (optional documentation)
├── scripts/
│   └── helper.py (optional utility)
└── templates/
    └── template.txt (optional template)
```

Reference these files from SKILL.md using relative paths.

## Tool Access Restriction

Use the `allowed-tools` frontmatter field to limit Claude's permissions:

```yaml
---
name: safe-file-reader
description: Read files without making changes.
allowed-tools: Read, Grep, Glob
---
```

This enables read-only or limited-scope skills without requiring explicit permission requests for each tool use.

## Storage Locations

- **Personal Skills**: `~/.claude/skills/skill-name/`
- **Project Skills**: `.claude/skills/skill-name/` (git-tracked, team-accessible)
- **Plugin Skills**: Bundled with installed plugins

## Invocation Model

Skills are **model-invoked**—Claude autonomously decides when to activate them based on user context and the skill description. This differs from slash commands, which require explicit user invocation.

## Debugging Checklist

If Claude doesn't use a skill:

1. **Verify specificity**: Does the description include concrete trigger terms?
2. **Check file path**: Confirm `SKILL.md` exists in the correct directory
3. **Validate YAML**: Ensure proper frontmatter syntax (no tabs, correct indentation)
4. **Review skill focus**: Is it addressing a single, well-defined capability?

## Common Patterns

**Simple skill** (single file): Include instructions and examples in `SKILL.md`

**Skill with permissions**: Use `allowed-tools` to restrict capabilities to safe operations

**Multi-file skill**: Organize supporting documentation and scripts separately; load progressively as needed

## Team Sharing

Commit project skills to git. Team members automatically gain access upon pulling changes—no installation step required.
