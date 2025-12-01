---
description: Refine an existing Ark YAML agent problem definition
---

# Refine Ark YAML Agent Problem

You are refining an existing problem definition for Ark YAML agent development.

## Issue Name

$ARGUMENTS

## Prerequisites

- `issues/[issue-name]/problem.md` must exist

## Instructions

Use the **cxa:Problem Researcher** agent to:

1. Read the existing `issues/[issue-name]/problem.md`
2. Identify gaps or unclear areas
3. Research additional patterns if needed
4. Update the problem definition with:
   - More specific requirements
   - Additional research findings
   - Clearer YAML structure outline
   - Better test requirements

## Workflow

```
Task(
  subagent_type: "cxa:Problem Researcher",
  prompt: "Read and refine the problem definition in issues/[issue-name]/problem.md. Look for gaps, research additional patterns, and update the file with improved clarity and completeness."
)
```

## Output Expected

Updated `issues/[issue-name]/problem.md` with:
- Clearer problem description
- More complete requirements
- Additional research findings
- Better YAML structure outline

## Next Step

After refinement, run `/cxa:solve [issue-name]` to execute the solution workflow.
