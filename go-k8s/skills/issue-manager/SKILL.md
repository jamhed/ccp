---
name: issue-manager
description: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions. Use when user mentions "list issues", "archive issue", "manage issues", or when working with the issues/ directory.
---

# Issue Manager

Expert assistant for managing project issues stored in the `issues/` folder. Provides utilities to list open issues, archive solved issues to the archive folder, and refine problem definitions.

## Core Capabilities

### 1. List Open Issues

List all open (non-archived) issues that have a `problem.md` file:

```bash
issue-manager/scripts/list-open
```

**When to use:**
- Need to see what issues are currently open
- Planning which issue to work on next
- Getting an overview of pending work

**How it works:**
- Scans the `issues/` directory for issue folders
- Identifies issues with a `problem.md` file
- Displays descriptive issue names (e.g., "agent-crd-embedding-in-tool", "query-message-observer")

### 2. Archive Solved Issue

Archive a solved issue by moving it from `issues/` to `archive/`:

```bash
issue-manager/scripts/archive <issue-name>
```

**Example:**
```bash
issue-manager/scripts/archive agent-crd-embedding-in-tool
```

**When to use:**
- After successfully solving and verifying an issue
- Cleaning up completed work from the active issues list
- Maintaining a clear separation between open and closed issues

**How it works:**
- Validates the issue exists in `issues/`
- Creates the `archive/` directory if it doesn't exist
- Moves the entire issue folder to `archive/`
- Preserves all issue files (problem.md, solution.md, audit trail, etc.)

**Prerequisites:**
- Issue must exist in the `issues/` directory
- Issue should be fully solved with a `solution.md` file

### 3. Refine Problem Definition

Launch the problem researcher agent to refine an issue's problem definition:

```bash
issue-manager/scripts/refine <issue-name>
```

**Example:**
```bash
issue-manager/scripts/refine query-message-observer
```

**When to use:**
- Problem definition is incomplete or unclear
- Need to investigate root cause more thoroughly
- Adding additional context or reproduction steps
- Improving problem clarity before implementing solution

**How it works:**
- Launches the `go-k8s:Problem Researcher` agent
- Agent analyzes the current problem definition
- Updates `problem.md` with enhanced details
- Maintains problem structure and formatting

**Prerequisites:**
- Issue must exist with a `problem.md` file

## When to Use This Skill

**Automatically use when:**
- User mentions "list issues", "show issues", or "what issues are open"
- User asks to "archive" or "close" an issue
- User wants to "refine" or "improve" a problem definition
- Working with files in the `issues/` directory

**Explicitly use for:**
- Getting an overview of open work items
- Managing issue lifecycle (open → solved → archived)
- Improving problem definitions before implementing solutions
- Cleaning up solved issues from the active list

## Workflow

### Typical Issue Management Flow

1. **List open issues** to see what needs work:
   ```bash
   issue-manager/scripts/list-open
   ```

2. **Refine problem** if definition is unclear:
   ```bash
   issue-manager/scripts/refine agent-crd-embedding-in-tool
   ```

3. **Work on solution** using the solve workflow

4. **Archive when solved**:
   ```bash
   issue-manager/scripts/archive agent-crd-embedding-in-tool
   ```

## Directory Structure

Issues use descriptive kebab-case names that clearly indicate the problem:

```
issues/
├── agent-crd-embedding-in-tool/
│   ├── problem.md
│   ├── solution.md
│   └── ... (other files)
└── query-message-observer/
    └── problem.md

archive/
└── partial-tool-parameter-substitution/
    ├── problem.md
    └── solution.md
```

**Naming convention:**
- Use kebab-case (lowercase with hyphens)
- Descriptive names that indicate the issue (e.g., `agent-crd-embedding-in-tool`)
- Not IDs or ticket numbers

## Environment Variables

The scripts support these environment variables:

- `ISSUES_DIR`: Directory containing open issues (default: `issues`)
- `ARCHIVE_DIR`: Directory for archived issues (default: `archive`)

**Example with custom directories:**
```bash
ISSUES_DIR=bugs ARCHIVE_DIR=resolved issue-manager/scripts/list-open
```

## Best Practices

1. **Before archiving:** Ensure the issue has a complete `solution.md` file
2. **Refine early:** Use refine to clarify problem definitions before implementation
3. **Regular cleanup:** Archive solved issues to keep the issues/ directory focused
4. **Preserve history:** Archived issues retain all files for future reference

## Common Patterns

**Check what's open before starting work:**
```bash
issue-manager/scripts/list-open
```

**Archive after solving:**
```bash
# After solution is complete and tested
issue-manager/scripts/archive partial-tool-parameter-substitution
```

