---
description: Research and define a problem for YAML-based Ark agent development
---

# Problem Research for Ark YAML Agents

You are starting the problem research phase for YAML-based Ark agent development.

## User Input

$ARGUMENTS

## Instructions

Use the **cxa:Problem Researcher** agent to:

1. Understand what the user wants (new agent, bug fix, enhancement)
2. Research patterns using:
   - `Skill(cxa:ark-agent-dev)` - Comprehensive Ark YAML patterns
   - Project search - Find existing agents/tools in current project
3. Create a comprehensive problem definition in `issues/[issue-name]/problem.md`

## Workflow

```
Task(
  subagent_type: "cxa:Problem Researcher",
  prompt: "Research and define this problem for Ark YAML agent development: [user input]. Create issues/[issue-name]/problem.md with the problem definition."
)
```

## Output Expected

- `issues/[issue-name]/problem.md` with:
  - Clear problem description
  - Requirements for the agent
  - Research findings (existing patterns)
  - YAML structure outline
  - Test requirements

## Next Step

After problem.md is created, run `/cxa:solve [issue-name]` to propose, review, and implement the solution.
