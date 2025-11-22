---
name: python-standards
description: Python development standards reference hub - delegates to specialist skills (python-dev, pytest-tester, issue-management)
---

# Python Standards Reference Hub (2025)

Lightweight reference hub that delegates to specialist skills for Python development standards.

## Specialist Skills

**For Python development standards**, see **Skill(cxp:python-dev)**:
- Modern Python features (3.14+: t-strings, deferred annotations, free-threading)
- Type safety and type hints
- Fail-fast principles and error handling
- UV package management (10-100x faster than pip)
- Async/await patterns
- Code quality standards
- Security best practices
- Performance optimization

**For testing standards**, see **Skill(cxp:pytest-tester)**:
- pytest patterns and best practices
- pytest-asyncio 1.3.0+ (Python 3.10-3.14)
- AsyncMock for async testing
- Test execution commands with uv
- Test organization and markers
- Coverage analysis
- Manual testing best practices

**For issue management**, see **Skill(cxp:issue-management)**:
- Issue documentation structures
- Status markers and severity levels
- Workflow phases
- File naming for issue docs
- Commit message format

## Python File Naming Conventions

**Python Modules and Packages**:
- ✅ Use `snake_case` for module names: `user_service.py`, `data_processor.py`
- ✅ Use `snake_case` for package names: `utils/`, `models/`
- ❌ Avoid PascalCase for modules: `UserService.py` (incorrect)

**Test Files**:
- ✅ Prefix with `test_`: `test_auth.py`, `test_user_service.py`
- ✅ Use `snake_case`: `test_api_endpoints.py`

**Constants Files**:
- ✅ Lowercase: `constants.py`, `config.py`
- ❌ Not uppercase: `CONSTANTS.py` (incorrect)

## When to Reference This Skill

Use this skill as a reference hub to find the right specialist skill:

**For Python code development** → Use **Skill(cxp:python-dev)**
**For testing** → Use **Skill(cxp:pytest-tester)**
**For issue management** → Use **Skill(cxp:issue-management)**

## Quick Reference

| Need | Specialist Skill |
|------|------------------|
| Modern Python features, fail-fast, async patterns | `cxp:python-dev` |
| pytest, async testing, test execution | `cxp:pytest-tester` |
| Issue docs, status markers, workflow | `cxp:issue-management` |
| Python file naming | This skill |

## Usage in Agents

Instead of referencing python-standards, agents should reference the specialist skills directly:

```markdown
For Python development standards, see **Skill(cxp:python-dev)**.
For testing standards, see **Skill(cxp:pytest-tester)**.
For issue management, see **Skill(cxp:issue-management)**.
```

**Note**: This skill exists as a transitional reference hub. Agents should migrate to using specialist skills directly.
