# CX - Core Utilities Plugin

Language-agnostic utilities for issue management and documentation caching in Claude Code projects.

## Features

- **Issue Management**: List, archive, and manage project issues in the `issues/` folder
- **Web Documentation**: Fetch and cache technical documentation locally
- **Batch Processing**: Solve multiple issues automatically with language-specific workflows

## Skills

- `cx:issue-manager` - Manage project issues (list, archive, solve)
- `cx:web-doc` - Fetch and cache web documentation

## Issue Management

### List Issues

```bash
# List all open issues
scripts/list-open

# List solved issues (ready to archive)
scripts/list-solved
```

### Archive Issues

```bash
# Archive a solved issue
scripts/archive <issue-name>

# Example
scripts/archive agent-crd-embedding-in-tool
```

### Batch Solve Issues

```bash
# Solve all unsolved issues (default: cx:solve)
scripts/solve-unsolved

# Use Python-specific workflow
scripts/solve-unsolved cxp:solve

# Use TypeScript-specific workflow
scripts/solve-unsolved cxt:solve
```

## Web Documentation

### Fetch Documentation

The `cx:web-doc` skill automatically:
- Checks cached docs in `docs/web/` before fetching
- Fetches complete technical content (no summarization)
- Caches results locally for future reference

**Trigger phrases:**
- "use web", "get docs", "fetch docs", "lookup docs"
- "research [topic]", "check this url/link"
- "what does [url] say"

### Cached Documentation

Cached files in `docs/web/` include:
- Source URL and fetch date metadata
- Complete technical content
- Code examples and API references
- Valid for 30 days before re-fetch

## Directory Structure

```
issues/
├── problem-name/
│   ├── problem.md
│   ├── solution.md
│   └── ... (workflow files)

archive/
└── solved-problem/
    └── ... (preserved issue files)

docs/web/
├── anthropic-skills.md
├── fastapi-documentation.md
└── ... (cached documentation)
```

## Requirements

- Claude Code CLI
- Works with any language-specific plugin (cxp, cxt, cxg)

## Quick Start

```bash
# List open issues
scripts/list-open

# Fetch and cache documentation
# (Use cx:web-doc skill in conversation)
# "Research FastAPI documentation"

# Batch solve Python issues
scripts/solve-unsolved cxp:solve

# Archive completed work
scripts/archive issue-name
```

## Integration

The `cx` plugin provides core utilities used by:
- `cxp` - Python development plugin
- `cxt` - TypeScript development plugin
- `cxg` - Go development plugin

All language plugins reference `cx` skills for issue management and documentation caching.
