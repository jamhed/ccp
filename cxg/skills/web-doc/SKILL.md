---
name: web-doc
description: Expert for fetching and caching web documentation for coding agents. ALWAYS use when user says "use web", "get the docs", "get docs", "fetch docs", "lookup docs", "search online", "research [topic]", "check this url/link", or "what does [url] say". Fetches complete technical content (no summarization) and caches results in docs/web/ folder for future reference.
---

# Web Doc Skill

Expert assistant for fetching technical documentation and caching it locally using Claude Code's built-in WebFetch and WebSearch tools. Fetches complete documentation and saves it to the project's `docs/web/` folder for future reference.

## Core Capabilities

### 1. Fetch Documentation from Known URLs

Use **WebFetch** when you have a specific URL to fetch documentation from:

```
WebFetch(
  url: "https://example.com/docs",
  prompt: "Extract complete documentation including:
  - All technical content
  - Code examples and snippets
  - API references
  - Configuration options
  - Installation instructions"
)
```

**When to use:**
- User provides a specific URL
- Fetching official documentation pages
- Extracting technical content from known sources
- Getting API documentation from specific endpoints

**After fetching:**
- Save the content to `docs/web/[topic].md` using Write tool
- Include source URL and fetch date in the cached file
- Preserve all code examples and technical details

### 2. Search and Research Topics

Use **WebSearch** when you need to find documentation or research a topic:

```
WebSearch(
  query: "Go 1.23 new features documentation"
)
```

**When to use:**
- User asks to "research" or "lookup" a topic
- Need to find official documentation URLs
- Searching for best practices or guides
- Finding current information about technologies

**After searching:**
- Review search results to identify authoritative sources
- Use WebFetch to retrieve full content from the best sources
- Cache the complete documentation in `docs/web/`

## When to Use This Skill

**Automatically use when:**
- User says "use web", "use the web", "search online"
- User asks to "get docs", "fetch docs", "lookup docs"
- User says "research [topic]" or "find [topic] documentation"
- User asks "check this url/link" or "what does [url] say"
- User requests documentation for a library, framework, or tool

**Explicitly use for:**
- Fetching technical documentation and caching it locally
- Researching new technologies or frameworks
- Getting complete API documentation from URLs
- Extracting technical content from web pages
- Building a local documentation cache for the project
- Preserving all code examples and technical details

## Workflow

### For Known URLs

1. **Fetch content** using WebFetch with comprehensive prompt
2. **Ensure docs/web directory exists** if needed:
   ```bash
   mkdir -p docs/web
   ```
3. **Save to file** using Write tool with metadata:
   ```
   Write(
     file_path: "/absolute/path/to/project/docs/web/[topic].md",
     content: "# [Topic] Documentation\n\n**Source:** [URL]\n**Fetched:** [Date]\n\n[Content]"
   )
   ```

**Important:** Always use absolute paths with the Write tool.

### For Topic Research

1. **Search** using WebSearch to find authoritative sources
2. **Identify best sources** from search results (official docs, GitHub, etc.)
3. **Fetch full content** using WebFetch for each relevant source
4. **Cache locally** in `docs/web/` with proper metadata

### File Naming Convention

Use clear, descriptive filenames:
- `chainsaw-kubernetes-testing.md` - Framework documentation
- `go-1.23-features.md` - Language version features
- `kubernetes-admission-webhooks.md` - Specific topic guides
- `anthropic-skills.md` - Product documentation

## Examples

### Example 1: Fetch Specific Documentation

**User request:** "Fetch the Chainsaw documentation from https://kyverno.github.io/chainsaw/"

**Steps:**
1. Use WebFetch:
   ```
   WebFetch(
     url: "https://kyverno.github.io/chainsaw/",
     prompt: "Extract complete Chainsaw documentation including:
     - Installation instructions
     - Configuration options
     - Test structure and syntax
     - Code examples and test patterns
     - API reference
     - Best practices"
   )
   ```

2. Ensure directory exists:
   ```bash
   mkdir -p docs/web
   ```

3. Save content with metadata:
   ```
   Write(
     file_path: "/absolute/path/to/project/docs/web/chainsaw-kubernetes-testing.md",
     content: "# Chainsaw Kubernetes Testing Documentation\n\n**Source:** https://kyverno.github.io/chainsaw/\n**Fetched:** 2025-10-31\n\n[Retrieved content]"
   )
   ```

### Example 2: Research Topic

**User request:** "Research Go 1.23 new features"

**Steps:**
1. Search for information:
   ```
   WebSearch(
     query: "Go 1.23 new features official documentation"
   )
   ```

2. Identify authoritative source (e.g., go.dev/doc/go1.23)

3. Fetch complete documentation:
   ```
   WebFetch(
     url: "https://go.dev/doc/go1.23",
     prompt: "Extract complete Go 1.23 documentation including:
     - All new language features
     - Code examples
     - Migration guides
     - API changes
     - Performance improvements"
   )
   ```

4. Cache locally with metadata:
   ```
   Write(
     file_path: "/absolute/path/to/project/docs/web/go-1.23-features.md",
     content: "# Go 1.23 Features\n\n**Source:** https://go.dev/doc/go1.23\n**Fetched:** 2025-10-31\n\n[Retrieved content]"
   )
   ```

### Example 3: Multiple Sources

**User request:** "Get documentation on Kubernetes admission webhooks"

**Steps:**
1. Search to find best sources:
   ```
   WebSearch(
     query: "Kubernetes admission webhooks official documentation"
   )
   ```

2. Fetch from primary source:
   ```
   WebFetch(
     url: "https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/",
     prompt: "Extract complete admission webhook documentation..."
   )
   ```

3. Optionally fetch from additional sources (tutorials, examples)

4. Cache all relevant content in `docs/web/kubernetes-admission-webhooks.md`

## Best Practices

### Content Quality
- Request **complete technical content** (no summarization)
- Explicitly ask for code examples, API details, and configuration options
- Preserve exact syntax and formatting from documentation

### Source Selection
- Prefer official documentation sources (project websites, GitHub repos)
- Check fetch date to ensure information is current
- Include source URL in cached files for reference

### Caching Strategy
- Always save fetched content to `docs/web/` directory
- Use descriptive filenames (topic-based, not URL-based)
- Include metadata header (source URL, fetch date)
- Organize by topic or technology for easy discovery

### File Organization
```
docs/web/
├── anthropic-skills.md
├── chainsaw-kubernetes-testing.md
├── go-1.23-features.md
├── kubernetes-admission-webhooks.md
└── webfetch-documentation.md
```

## Common Patterns

### Pattern 1: Quick URL Fetch
```
# User: "Check what's at https://example.com/api/docs"
1. WebFetch(url: "https://example.com/api/docs", prompt: "Extract API documentation")
2. (Optionally cache if useful for future reference)
```

### Pattern 2: Research and Cache
```
# User: "Research React 19 hooks and save the docs"
1. WebSearch(query: "React 19 hooks official documentation")
2. WebFetch(url: [best result], prompt: "Extract complete hooks documentation")
3. mkdir -p docs/web
4. Write(file_path: "docs/web/react-19-hooks.md", content: [formatted])
```

### Pattern 3: Multi-Source Documentation
```
# User: "Get comprehensive Kubernetes operator documentation"
1. WebSearch(query: "Kubernetes operator pattern documentation")
2. WebFetch from official K8s docs
3. WebFetch from operator-framework docs
4. Consolidate and save to docs/web/kubernetes-operators.md
```

## Tools Reference

### WebFetch
- **Purpose:** Fetch content from a specific URL
- **Parameters:**
  - `url`: The URL to fetch (required)
  - `prompt`: Instructions for content extraction (required)
- **Best for:** Known URLs, specific documentation pages

### WebSearch
- **Purpose:** Search the web for information
- **Parameters:**
  - `query`: Search query string (required)
  - `allowed_domains`: Optional whitelist of domains
  - `blocked_domains`: Optional blacklist of domains
- **Best for:** Finding documentation, researching topics

### Write
- **Purpose:** Save content to a file
- **Parameters:**
  - `file_path`: Absolute path to file (required)
  - `content`: Content to write (required)
- **Use for:** Caching fetched documentation locally

## Troubleshooting

### URL Redirects
If WebFetch reports a redirect to a different host:
1. Note the redirect URL provided
2. Make a new WebFetch request with the redirect URL
3. Continue with caching workflow

### Search Returns No Results
If WebSearch doesn't find relevant documentation:
1. Try alternative search terms
2. Include specific version numbers or technologies
3. Search for "official documentation" or "API reference"
4. Try domain-specific searches (e.g., allowed_domains: ["github.com"])

### Content Too Large
If fetched content is very large:
1. WebFetch will summarize results automatically
2. Consider fetching specific sections separately
3. Focus prompt on most relevant content areas

## Version History

### v2.0 - 2025-10-31

**Major refactoring to use standard Claude Code tools:**
- Replaced non-existent "web-tool" agent with WebFetch and WebSearch
- Added detailed workflows for URL fetching and topic research
- Included comprehensive examples with step-by-step instructions
- Enhanced best practices for caching and file organization
- Added tools reference section
- Improved skill structure following Anthropic guidelines
