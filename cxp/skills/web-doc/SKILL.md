---
name: web-doc
description: Expert for fetching and caching web documentation for coding agents. ALWAYS use when user says "use web", "get the docs", "get docs", "fetch docs", "lookup docs", "search online", "research [topic]", "check this url/link", or "what does [url] say". Fetches complete technical content (no summarization) and caches results in docs/web/ folder for future reference.
---

# Web Doc Skill

Expert assistant for fetching technical documentation and caching it locally using Claude Code's built-in WebFetch and WebSearch tools. Fetches complete documentation and saves it to the project's `docs/web/` folder for future reference.

**CRITICAL: Always check `docs/web/` cache before fetching from web.** Use cached documentation when available and recent (< 30 days) to save time and avoid unnecessary web requests.

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

1. **Check cache first** - Look for existing cached documentation:
   ```bash
   # Check if docs/web directory and cached file exist
   ls docs/web/[topic].md
   ```

   **If cached file exists:**
   - Read the cached file using Read tool
   - Check the fetch date in metadata
   - If recent (< 30 days), use cached version
   - If old or user requests fresh fetch, proceed to step 2

   **If no cache exists, proceed to step 2**

2. **Fetch content** using WebFetch with comprehensive prompt
3. **Ensure docs/web directory exists** if needed:
   ```bash
   mkdir -p docs/web
   ```
4. **Save to file** using Write tool with metadata:
   ```
   Write(
     file_path: "/absolute/path/to/project/docs/web/[topic].md",
     content: "# [Topic] Documentation\n\n**Source:** [URL]\n**Fetched:** [Date]\n\n[Content]"
   )
   ```

**Important:** Always use absolute paths with the Write tool. Always check cache before fetching.

### For Topic Research

1. **Check cache first** - Look for existing cached documentation:
   ```bash
   # List docs/web directory to see what's cached
   ls docs/web/
   ```

   **If relevant cached file exists:**
   - Read the cached file
   - Check if it covers the topic adequately
   - Check fetch date - if recent (< 30 days), use cached version
   - If incomplete or old, proceed to fetch

2. **Search** using WebSearch to find authoritative sources
3. **Identify best sources** from search results (official docs, GitHub, etc.)
4. **Fetch full content** using WebFetch for each relevant source
5. **Cache locally** in `docs/web/` with proper metadata

### File Naming Convention

Use clear, descriptive filenames:
- `fastapi-best-practices.md` - Framework documentation
- `python-3.14-features.md` - Language version features
- `pydantic-v2-migration.md` - Specific topic guides
- `anthropic-skills.md` - Product documentation

## Examples

### Example 1: Fetch Specific Documentation

**User request:** "Fetch the FastAPI documentation from https://fastapi.tiangolo.com/"

**Steps:**
1. Check cache first:
   ```bash
   ls docs/web/fastapi-documentation.md
   ```

   **If exists:** Read cached file, check fetch date
   - If recent (< 30 days): Use cached version ✅
   - If old or missing: Proceed to step 2

2. Use WebFetch:
   ```
   WebFetch(
     url: "https://fastapi.tiangolo.com/",
     prompt: "Extract complete FastAPI documentation including:
     - Installation instructions
     - Quick start guide
     - Route and endpoint patterns
     - Code examples and best practices
     - Dependency injection
     - Async patterns
     - Request/response models"
   )
   ```

3. Ensure directory exists:
   ```bash
   mkdir -p docs/web
   ```

4. Save content with metadata:
   ```
   Write(
     file_path: "/absolute/path/to/project/docs/web/fastapi-documentation.md",
     content: "# FastAPI Documentation\n\n**Source:** https://fastapi.tiangolo.com/\n**Fetched:** 2025-11-12\n\n[Retrieved content]"
   )
   ```

### Example 2: Research Topic

**User request:** "Research Python 3.14 new features"

**Steps:**
1. Check cache first:
   ```bash
   ls docs/web/ | grep -i "python.*3.14"
   ```

   **If cached file exists:**
   - Read `docs/web/python-3.14-features.md`
   - Check fetch date in metadata
   - If recent (< 30 days): Use cached version ✅
   - If old: Proceed to fetch

2. Search for information:
   ```
   WebSearch(
     query: "Python 3.14 new features official documentation what's new"
   )
   ```

3. Identify authoritative source (e.g., docs.python.org/3.14/whatsnew)

4. Fetch complete documentation:
   ```
   WebFetch(
     url: "https://docs.python.org/3.14/whatsnew/3.14.html",
     prompt: "Extract complete Python 3.14 documentation including:
     - All new language features
     - JIT compiler improvements
     - Type system enhancements
     - Code examples
     - Performance improvements
     - Deprecations and removals"
   )
   ```

5. Cache locally with metadata:
   ```
   Write(
     file_path: "/absolute/path/to/project/docs/web/python-3.14-features.md",
     content: "# Python 3.14 Features\n\n**Source:** https://docs.python.org/3.14/whatsnew/3.14.html\n**Fetched:** 2025-11-12\n\n[Retrieved content]"
   )
   ```

### Example 3: Multiple Sources

**User request:** "Get documentation on Pydantic v2 validation patterns"

**Steps:**
1. Check cache first:
   ```bash
   ls docs/web/pydantic-v2-validation.md
   ```

2. Search to find best sources:
   ```
   WebSearch(
     query: "Pydantic v2 validation patterns official documentation"
   )
   ```

3. Fetch from primary source:
   ```
   WebFetch(
     url: "https://docs.pydantic.dev/latest/concepts/validators/",
     prompt: "Extract complete Pydantic validation documentation including:
     - Field validators
     - Model validators
     - Custom validation
     - Code examples"
   )
   ```

4. Optionally fetch from additional sources (migration guides, examples)

5. Cache all relevant content in `docs/web/pydantic-v2-validation.md`

## Best Practices

### Cache First Approach (CRITICAL)
- **Always check cache before fetching** from web
- Check if `docs/web/[topic].md` exists before WebFetch
- Read cached file and check fetch date in metadata
- Use cached version if recent (< 30 days old)
- Only fetch if cache missing, old, or user requests fresh data
- This saves time and avoids unnecessary web requests

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
- Reuse cached docs whenever possible (< 30 days old)

### File Organization
```
docs/web/
├── anthropic-skills.md
├── fastapi-documentation.md
├── python-3.14-features.md
├── pydantic-v2-validation.md
└── pytest-async-patterns.md
```

## Common Patterns

### Pattern 1: Quick URL Fetch
```
# User: "Check what's at https://example.com/api/docs"
1. ls docs/web/ (check for cached version)
2. If cached and recent: Read cached file ✅
3. If not cached: WebFetch(url: "https://example.com/api/docs", prompt: "Extract API documentation")
4. (Optionally cache if useful for future reference)
```

### Pattern 2: Research and Cache
```
# User: "Research pytest async patterns and save the docs"
1. ls docs/web/ | grep -i "pytest.*async" (check cache)
2. If cached and recent: Read cached file ✅
3. If not: WebSearch(query: "pytest async patterns official documentation pytest-asyncio")
4. WebFetch(url: [best result], prompt: "Extract complete pytest-asyncio documentation")
5. mkdir -p docs/web
6. Write(file_path: "docs/web/pytest-async-patterns.md", content: [formatted])
```

### Pattern 3: Multi-Source Documentation
```
# User: "Get comprehensive SQLAlchemy 2.0 documentation"
1. ls docs/web/sqlalchemy-2.0-guide.md (check cache)
2. If cached and recent: Read cached file ✅
3. If not: WebSearch(query: "SQLAlchemy 2.0 documentation tutorial")
4. WebFetch from official SQLAlchemy docs
5. WebFetch from migration guide
6. Consolidate and save to docs/web/sqlalchemy-2.0-guide.md
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
