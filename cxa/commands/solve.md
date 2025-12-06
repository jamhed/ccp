---
description: Execute full workflow to solve an Ark YAML agent issue (propose, review, implement)
---

# Solve Ark YAML Agent Issue

You are executing the full solution workflow for an Ark YAML agent issue.

**Skill Context**: Use `Skill(cx:issue-manager)` for any issue management operations (listing, archiving, etc.)

## Issue Name

$ARGUMENTS

## Prerequisites

- `issues/[issue-name]/problem.md` must exist (created by `/cxa:problem`)

## Workflow Phases

### Phase 1: Solution Proposal

```
Task(
  subagent_type: "cxa:Solution Proposer",
  prompt: "Read issues/[issue-name]/problem.md and propose 2-4 YAML agent solutions. Create issues/[issue-name]/proposals.md with complete YAML definitions for each approach."
)
```

### Phase 2: Solution Review

```
Task(
  subagent_type: "cxa:Solution Reviewer",
  prompt: "Read issues/[issue-name]/proposals.md and evaluate all solutions. Select the best approach and create issues/[issue-name]/review.md with selection rationale and implementation guidance."
)
```

### Phase 3: Implementation

```
Task(
  subagent_type: "cxa:Solution Implementer",
  prompt: "Read issues/[issue-name]/review.md and implement the selected YAML agent solution. Create the agent/tool/query files and document in issues/[issue-name]/solution.md."
)
```

## Output Expected

After all phases complete:

1. `issues/[issue-name]/proposals.md` - 2-4 YAML solution proposals
2. `issues/[issue-name]/review.md` - Selected solution with rationale
3. `issues/[issue-name]/solution.md` - Implementation documentation
4. YAML files in appropriate locations:
   - `[namespace]/agents/[agent-name].yaml`
   - `[namespace]/tools/[tool-name].yaml` (if needed)
   - `[namespace]/queries/[query-name].yaml`

## Execution

Run all three phases sequentially. Each phase depends on the previous phase's output.
