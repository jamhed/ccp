# cx Plugin - Core Cross-Language Utilities

Core plugin providing shared utilities and skills used across all Claude Code Plugin Collection (CCP) plugins.

## Overview

The `cx` plugin contains cross-language functionality that is common to all CCP plugins (cxg, cxp, cxt). Instead of duplicating these skills across each language-specific plugin, they are centralized here for easier maintenance and consistency.

## Shared Skills

### issue-manager

Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions.

**Use when**:
- User mentions "list issues", "show issues", or "what issues are open"
- User asks to "list solved", "show archived", or "what issues are solved"
- User asks to "archive" or "close" an issue
- User wants to "refine" or "improve" a problem definition
- Working with files in the `issues/` directory

**Capabilities**:
- List all open (non-archived) issues with `problem.md` files
- List all solved (archived) issues
- Archive solved issues by moving from `issues/` to `archive/`
- Refine problem definitions using the Problem Researcher agent

**Scripts**:
```bash
# List open issues
cx/skills/issue-manager/scripts/list-open

# List solved issues
cx/skills/issue-manager/scripts/list-solved

# Archive an issue
cx/skills/issue-manager/scripts/archive <issue-name>
```

**Directory Structure**:
```
issues/
├── bug-example-issue/
│   └── problem.md
└── feature-example/
    └── problem.md

archive/
└── bug-solved-issue/
    ├── problem.md
    ├── validation.md
    ├── review.md
    ├── implementation.md
    ├── testing.md
    └── solution.md
```

### web-doc

Fetches and caches technical documentation locally in `docs/web/` for offline reference.

**Use when**:
- User asks to "get docs", "fetch docs", "lookup docs"
- User mentions "search online", "research [topic]"
- User provides a URL and says "check this url/link"
- User asks "what does [url] say"
- Need to fetch library documentation or GitHub content

**Capabilities**:
- Fetches complete technical content from URLs
- Caches results in `docs/web/` folder
- No summarization - fetches full content
- Self-cleaning 15-minute cache for faster repeated access
- Handles redirects and informs user

**Example Usage**:
```
Use the cx:web-doc skill to fetch the TypeScript 5.0 release notes from typescriptlang.org
```

## Installation

The `cx` plugin is installed as a dependency when you install any of the language-specific plugins:

```bash
# Installing any plugin automatically makes cx skills available
/plugin install cxg@ccp  # Go/Kubernetes
/plugin install cxp@ccp  # Python
/plugin install cxt@ccp  # TypeScript/Node.js
```

## Usage in Other Plugins

All CCP plugins reference cx skills using the `cx:` prefix:

**Go Plugin (cxg)**:
```
Skill(cx:issue-manager)
Skill(cx:web-doc)
```

**Python Plugin (cxp)**:
```
Skill(cx:issue-manager)
Skill(cx:web-doc)
```

**TypeScript Plugin (cxt)**:
```
Skill(cx:issue-manager)
Skill(cx:web-doc)
```

## Why cx Plugin?

**Benefits of centralized shared skills**:
- **Consistency**: All plugins use the same issue management workflow
- **Maintainability**: Update once, applies to all plugins
- **No duplication**: Reduces code duplication across plugins
- **Single source of truth**: Issue management behavior is consistent

## Plugin Architecture

```
ccp/
├── cx/                    # Core shared utilities
│   └── skills/
│       ├── issue-manager/ # Issue management
│       └── web-doc/       # Documentation fetching
├── cxg/                   # Go/Kubernetes
│   └── skills/
│       ├── go-dev/
│       ├── chainsaw-tester/
│       └── github-cicd/
├── cxp/                   # Python
│   └── skills/
│       ├── python-dev/
│       ├── pytest-tester/
│       └── fastapi-dev/
└── cxt/                   # TypeScript/Node.js
    └── skills/
        ├── typescript-dev/
        └── jest-tester/
```

## Issue Management Workflow

The issue management system is shared across all plugins and follows this lifecycle:

### 1. Create Issue
```bash
# Using any plugin
/cxg:problem [description]  # Go
/cxp:problem [description]  # Python
/cxt:problem [description]  # TypeScript
```

### 2. List Issues
```
Use the cx:issue-manager skill to list all open issues
```

### 3. Solve Issue
```bash
/cxg:solve [issue-name]  # Go
/cxp:solve [issue-name]  # Python
/cxt:solve [issue-name]  # TypeScript
```

### 4. Archive Solved Issue
```bash
cx/skills/issue-manager/scripts/archive [issue-name]
```

## Environment Variables

The issue-manager skill supports these environment variables:

- `ISSUES_DIR`: Directory containing open issues (default: `issues`)
- `ARCHIVE_DIR`: Directory for archived issues (default: `archive`)

**Example**:
```bash
ISSUES_DIR=bugs ARCHIVE_DIR=resolved cx/skills/issue-manager/scripts/list-open
```

## Contributing

This plugin is part of the Claude Code Plugin Collection (ccp). Contributions welcome at https://github.com/jamhed/ccp

## See Also

- [cxg Plugin](../cxg/README.md) - Go & Kubernetes development
- [cxp Plugin](../cxp/README.md) - Python development
- [cxt Plugin](../cxt/README.md) - TypeScript & Node.js development
- [Main CCP Documentation](../README.md) - Complete collection overview
