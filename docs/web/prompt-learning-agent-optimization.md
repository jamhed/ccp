# Prompt Learning & Agent Optimization

**Sources:**
- https://arize.com/blog/prompt-learning-using-english-feedback-to-optimize-llm-systems/
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/
- https://www.promptingguide.ai/research/llm-agents

**Fetched:** 2025-11-30

---

## Prompt Learning Methodology

### Core Concept

**Prompt Learning (PL)** represents a reinforcement learning approach where English-language feedback—rather than numeric scores—iteratively refines LLM system prompts. Unlike traditional RL that adjusts model weights, PL modifies instructions directly within prompt context.

### Key Distinction from Traditional RL

The fundamental difference: "The 'error', an Eval explanation OR annotation term is in English" rather than calculated as gradient terms. This enables optimization with substantially fewer examples—potentially 1-10 labeled instances versus thousands required by conventional methods.

### Optimization Loop Structure

The process operates in phases:

1. **Evaluation & Explanation**: LLM-as-judge generates numeric scores plus detailed English critiques
2. **Metaprompt Processing**: A meta-prompt controller interprets the critique and decides instruction mutations (add, merge, rewrite, expire)
3. **Instruction Integration**: English-language rules embed directly into the system prompt's instruction section
4. **Iteration**: Multiple loops accumulate rules until performance targets are achieved

Single-pass optimization worked effectively in tested scenarios; complex tasks requiring 100+ rules benefited from 5-loop iterations.

### Feedback Mechanisms

Three feedback sources were validated:
- **Human annotations**: Direct expert guidance on failures
- **Evaluation-driven feedback**: LLM judge explanations from failure cases
- **Production traces**: Real-world user interaction failures

### Performance Results

**Rules-Based Learning**:
- 10 rules: 0% → 100% accuracy (5-loop)
- 50 rules: 0% → 82% accuracy
- 100 rules: 0% → 67% accuracy

**Big Bench Hard**:
- 10% improvement on this saturated benchmark
- Single 1-loop iteration with 50 random samples
- No handcrafted task-specific prompts required

### Implementation Advantages

- **10-100x faster** than existing optimization ecosystems
- Works with **single examples** due to information-rich explanations
- Maintains **full audit trail** of every instruction edit in plain English
- Enables **continuous deployment** alongside production applications

---

## Context Engineering for AI Agents

### Core Definition

Context engineering represents "the set of strategies for curating and maintaining the optimal set of tokens (information) during LLM inference." It evolved from prompt engineering as AI systems grew more complex.

### Key Principles

**Finite Resource Management**: LLMs face "context rot"—as context length increases, recall accuracy decreases. Models must treat context like humans manage working memory: selectively and strategically.

**The Right Altitude**: System prompts should balance specificity with flexibility. Avoid hardcoded brittle logic at one extreme and vague guidance at the other. Strike a "Goldilocks zone."

### Component-Level Strategies

#### System Prompts
- Use organizational sections (background, instructions, tool guidance, output description)
- Employ XML tagging or Markdown headers for clarity
- Start minimal and add instructions based on observed failures
- Preserve architectural decisions while discarding redundancy

#### Tools
- Ensure minimal overlap in functionality
- Make input parameters descriptive and unambiguous
- Avoid bloated tool sets that create decision ambiguity
- Design for token efficiency in returned information

#### Examples
- Curate diverse, canonical examples rather than exhaustive edge cases
- "Examples are the 'pictures' worth a thousand words" for LLMs
- Use few-shot prompting as established best practice

### Runtime Context Retrieval

**Just-in-Time Loading**: Rather than pre-loading all data, agents maintain lightweight identifiers (file paths, URLs, queries) and retrieve information on demand using tools.

**Progressive Disclosure**: Agents incrementally discover relevant context through exploration. File structure metadata, naming conventions, and timestamps guide navigation.

**Hybrid Approach**: Balance speed with autonomy—preload critical data while enabling agents to explore further.

### Long-Horizon Techniques

#### Compaction
Summarize conversation history when approaching context limits, preserving architectural decisions and critical details while discarding redundant outputs.

#### Structured Note-Taking
Agents maintain persistent memory files external to context windows (to-do lists, NOTES.md files).

#### Sub-Agent Architectures
Distribute work across specialized agents handling focused tasks with clean context windows. Main agent coordinates while sub-agents explore deeply, returning condensed summaries (typically 1,000-2,000 tokens).

### Decision Framework

- **Compaction**: Best for extensive back-and-forth requiring conversational continuity
- **Note-Taking**: Ideal for iterative development with clear milestones
- **Multi-Agent**: Optimal for complex research where parallel exploration yields dividends

---

## Claude Skills Architecture

### Meta-Tool Design

Skills operate through a `Skill` meta-tool that manages individual specialized skills. Unlike traditional tools (Read, Bash, Write), skills don't execute code. Instead, they function as "prompt-based conversation and execution context modifiers."

### Three-Layer System

1. **Discovery Layer**: Skills loaded from user configs, project settings, plugins, and built-ins
2. **Selection Layer**: Claude uses native language understanding to match user intent against skill descriptions—purely LLM reasoning
3. **Execution Layer**: Skill injection modifies both conversation context and execution context

### SKILL.md Format

```yaml
---
name: skill-name
description: Brief summary explaining when to use
allowed-tools: "Read,Write,Bash"
license: Optional
model: Optional model override
---
[Markdown instructions follow]
```

### Key Design Patterns

**Pattern 1: Script Automation** - Offload complex logic to Python/Bash scripts

**Pattern 2: Read-Process-Write** - Simple file transformation with minimal tools

**Pattern 3: Search-Analyze-Report** - Use Grep to find patterns, analyze, generate reports

**Pattern 4: Command Chain Execution** - Sequenced commands for CI/CD workflows

### Best Practices

**Frontmatter**:
- `name`: Used as command identifier
- `description`: Primary signal for intent matching—use clear, action-oriented language
- `allowed-tools`: Only include tools actually needed

**Prompt Content**:
- Keep SKILL.md under 5,000 words
- Use imperative language ("Analyze code for…")
- Reference external files rather than embedding
- Use `{baseDir}` variable for paths

**Tool Scoping**:
```
✓ Minimal: "Read,Write"
✗ Sprawl: "Bash,Read,Write,Edit,Glob,Grep,WebSearch"
✓ Specific: "Bash(git status:*),Bash(git diff:*)"
```

---

## LLM Agent Architecture

### Core Framework Components

1. **Agent/Brain**: LLM as central coordinator, activated via prompt templates
2. **Planning Module**: Breaks requests into subtasks
   - Single-path reasoning (Chain of Thought)
   - Multi-path reasoning (Tree of Thoughts)
3. **Memory Systems**:
   - Short-term: Context via in-context learning
   - Long-term: External vector stores
4. **Tool Integration**: APIs, code interpreters, databases

### Planning With Feedback

Iterative refinement mechanisms like ReAct and Reflexion enable agents to:
- Reflect on past actions
- Correct mistakes
- Improve execution plans

### Key Challenges

- Role-playing adaptation for uncommon domains
- Long-horizon planning within finite context windows
- Prompt robustness and hallucination mitigation
- Knowledge boundary control
- Computational efficiency

---

## Agent Design Best Practices

### Model Selection (2025)

Claude Haiku 4.5 delivers 90% of Sonnet's agentic coding performance at:
- 2x speed
- 3x cost savings ($1/$5 vs $3/$15)

Ideal for frequent-use agents requiring near-frontier capabilities at minimal cost.

### Architecture Guidelines

**Start Simple**:
- Create focused, single-purpose agents initially
- Start with lightweight agents (minimal or no tools)
- Prioritize efficiency over capability for frequent-use agents

**Token Management**:
- Heavy custom agents (25k+ tokens) create bottlenecks
- Lightweight custom agents (<3k tokens) enable fluid orchestration

**Permission Control**:
- Permission sprawl is the fastest path to unsafe autonomy
- Treat tool access like production IAM
- Start from deny-all; allowlist only needed commands

### Context Management

Claude 4.5 models feature context awareness, enabling tracking of remaining context window. If using an agent harness that compacts context, add this information to the prompt.

Use memory.md to store essential context and re-align past decisions.

### Recommended Workflows

1. Ask Claude to read relevant files before writing code
2. Use subagents to verify details or investigate questions
3. Ask Claude to make a plan before implementation
4. Test-driven development works exceptionally well with agentic coding
