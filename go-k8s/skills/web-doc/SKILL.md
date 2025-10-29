---
name: web-doc
description: Expert for fetching and caching web documentation for coding agents. ALWAYS use when user says "use web", "get the docs", "get docs", "fetch docs", "lookup docs", "search online", "research [topic]", "check this url/link", or "what does [url] say". Fetches complete technical content (no summarization) and caches results in docs/web/ folder for future reference.
---

# Web Doc Skill

Expert assistant for fetching technical documentation and caching it locally. This skill delegates to the specialized web-tool agent to fetch complete documentation and save it to the project's `docs/web/` folder.

## When to Use

**Trigger phrases:**
- "use web" / "use the web"
- "research [topic]"
- "get/find [topic] docs/documentation"
- "fetch data/docs from [url]"
- "lookup [topic] online"
- "check this url/link"
- "what does [url] say"

**Use cases:**
- Fetching technical documentation and caching it locally
- Researching new technologies or frameworks
- Getting complete API documentation from URLs
- Extracting technical content from web pages
- Building a local documentation cache for the project
- Preserving all code examples and technical details

## How to Use

Invoke the web-tool agent using the Task tool:

```
Task(
  subagent_type: "web-tool",
  description: "Fetch [brief topic]",
  prompt: "Fetch [topic/URL] and cache it in docs/web/.
  Keep all technical content, code examples, and API details."
)
```

## Examples

**Fetch API documentation:**
```
Task(
  subagent_type: "web-tool",
  description: "Fetch Chainsaw docs",
  prompt: "Fetch Chainsaw Kubernetes testing documentation from https://kyverno.github.io/chainsaw/.
  Keep all:
  - Installation instructions
  - Configuration options
  - Code examples and test patterns
  - API reference
  Cache the complete documentation in docs/web/chainsaw.md"
)
```

**Research and cache topic:**
```
Task(
  subagent_type: "web-tool",
  description: "Research Go 1.23 features",
  prompt: "Research Go 1.23 new features. Find and cache complete documentation with:
  - All new language features
  - Code examples
  - Migration guides
  - API changes
  Save to docs/web/go-1.23-features.md"
)
```

## Best Practices

- Provide specific topics or URLs
- Request complete technical content (not summaries)
- Prefer official documentation sources
- Agent caches results in `docs/web/` for future reference
- Cached files include source URL and fetch date
- All code examples and technical details are preserved
