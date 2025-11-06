# UV - Modern Python Package Manager

UV is an extremely fast Python package installer and resolver written in Rust. It's designed as a drop-in replacement for pip and pip-tools.

## Why UV?

- **10-100x faster** than pip
- **Deterministic** dependency resolution
- **Compatible** with pip and requirements.txt
- **Built-in** virtual environment management
- **Cross-platform** support (Linux, macOS, Windows)
- **Disk space efficient** with global cache

## Installation

```bash
# macOS and Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# With pip
pip install uv

# With pipx
pipx install uv

# With Homebrew
brew install uv
```

## Basic Usage

### Creating a New Project

```bash
# Create new project with UV
uv init my-project
cd my-project

# Creates:
# - pyproject.toml
# - .python-version
# - README.md
# - .gitignore
```

### Virtual Environment Management

```bash
# Create virtual environment
uv venv

# Activate virtual environment
# Linux/macOS:
source .venv/bin/activate
# Windows:
.venv\Scripts\activate

# Create with specific Python version
uv venv --python 3.14
uv venv --python 3.13

# UV auto-downloads Python versions if needed
uv venv --python 3.14  # Downloads Python 3.14 if not installed
```

### Installing Dependencies

```bash
# Install from pyproject.toml
uv sync

# Add a package
uv add fastapi
uv add "pydantic>=2.0"

# Add development dependencies
uv add --dev pytest
uv add --dev ruff pyright

# Install all dependencies (prod + dev)
uv sync --all-extras

# Install only production dependencies
uv sync --no-dev

# Update dependencies
uv lock --upgrade
uv sync
```

### Running Commands

```bash
# Run Python with UV
uv run python script.py

# Run module
uv run -m pytest

# Run installed tool
uv run ruff check .
uv run pyright

# Run without installing
uv run --with httpx -- python -c "import httpx; print(httpx.__version__)"
```

### Package Management

```bash
# Install package
uv pip install fastapi

# Install from requirements.txt
uv pip install -r requirements.txt

# Install in editable mode
uv pip install -e .

# Uninstall package
uv pip uninstall fastapi

# List installed packages
uv pip list

# Show package info
uv pip show fastapi

# Freeze dependencies
uv pip freeze > requirements.txt
```

### Lock File Management

```bash
# Generate lock file
uv lock

# Update lock file
uv lock --upgrade

# Update specific package
uv lock --upgrade-package fastapi

# Sync from lock file
uv sync
```

## Project Configuration

### pyproject.toml with UV

```toml
[project]
name = "my-project"
version = "0.1.0"
requires-python = ">=3.14"
dependencies = [
    "fastapi>=0.104.0",
    "pydantic>=2.5.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "ruff>=0.1.0",
    "pyright>=1.1.0",
]

[tool.uv]
dev-dependencies = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "ruff>=0.1.0",
    "pyright>=1.1.0",
]

[tool.uv.pip]
index-url = "https://pypi.org/simple"
```

### .python-version

```
3.14
```

UV will automatically use this Python version when creating virtual environments.

## Common Workflows

### Starting a New FastAPI Project

```bash
# Create project
uv init my-api
cd my-api

# Add dependencies
uv add fastapi uvicorn[standard]
uv add sqlalchemy asyncpg
uv add pydantic-settings

# Add dev dependencies
uv add --dev pytest pytest-asyncio httpx
uv add --dev ruff pyright

# Create virtual environment and sync
uv venv
uv sync

# Run development server
uv run uvicorn app.main:app --reload
```

### Daily Development

```bash
# Add new dependency
uv add httpx

# Update dependencies
uv lock --upgrade
uv sync

# Run tests
uv run pytest

# Run linter
uv run ruff check .

# Run type checker
uv run pyright

# Format code
uv run ruff format .
```

### CI/CD Pipeline

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install UV
        run: curl -LsSf https://astral.sh/uv/install.sh | sh

      - name: Set up Python
        run: uv venv --python 3.14

      - name: Install dependencies
        run: uv sync

      - name: Run tests
        run: uv run pytest

      - name: Run linter
        run: uv run ruff check .

      - name: Run type checker
        run: uv run pyright
```

## UV Commands Reference

### Project Management

| Command | Description |
|---------|-------------|
| `uv init` | Create new project |
| `uv add <package>` | Add dependency |
| `uv remove <package>` | Remove dependency |
| `uv sync` | Install dependencies from lock file |
| `uv lock` | Generate/update lock file |
| `uv run <cmd>` | Run command in project environment |

### Virtual Environments

| Command | Description |
|---------|-------------|
| `uv venv` | Create virtual environment |
| `uv venv --python 3.14` | Create with specific Python |
| `uv python list` | List available Python versions |
| `uv python install 3.14` | Install Python version |

### Package Installation

| Command | Description |
|---------|-------------|
| `uv pip install <package>` | Install package |
| `uv pip install -r requirements.txt` | Install from requirements |
| `uv pip install -e .` | Install in editable mode |
| `uv pip uninstall <package>` | Uninstall package |
| `uv pip list` | List installed packages |
| `uv pip freeze` | Output installed packages |

## Migrating from pip/poetry

### From pip + requirements.txt

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create pyproject.toml from requirements.txt
# Manually create pyproject.toml or use existing one

# Install dependencies
uv pip install -r requirements.txt

# Generate lock file
uv pip freeze > requirements.txt

# Or use UV's sync
uv sync
```

### From Poetry

```bash
# Install UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Poetry's pyproject.toml is compatible with UV
# Just sync dependencies
uv sync

# Or install from poetry.lock
uv pip install -r <(poetry export -f requirements.txt)
```

## Best Practices

### 1. Always Use Lock Files

```bash
# Generate lock file
uv lock

# Commit uv.lock to version control
git add uv.lock
git commit -m "Add uv.lock"

# In CI/CD, use sync (not add)
uv sync
```

### 2. Pin Python Version

```bash
# Create .python-version
echo "3.14" > .python-version

# UV will use this version automatically
uv venv  # Uses Python 3.14
```

### 3. Separate Dev Dependencies

```toml
[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "ruff>=0.1.0",
]

# Or use tool.uv.dev-dependencies
[tool.uv]
dev-dependencies = [
    "pytest>=7.4.0",
    "ruff>=0.1.0",
]
```

### 4. Use UV Run for Scripts

```bash
# Instead of:
source .venv/bin/activate
python script.py

# Use:
uv run python script.py
```

### 5. Global Tool Installation

```bash
# Install tools globally
uv tool install ruff
uv tool install pyright

# Use globally installed tools
ruff check .
pyright
```

## Performance Comparison

| Operation | pip | poetry | uv |
|-----------|-----|--------|-----|
| Install from cache | 5.2s | 3.8s | **0.1s** |
| Cold install | 45s | 35s | **4.5s** |
| Lock file generation | N/A | 18s | **0.8s** |

## Common Issues and Solutions

### Issue: UV not found after installation

```bash
# Add UV to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Or restart terminal
```

### Issue: Python version not found

```bash
# Install Python with UV
uv python install 3.14

# List available versions
uv python list
```

### Issue: Dependency conflict

```bash
# Clear cache and retry
uv cache clean
uv lock --upgrade
uv sync
```

### Issue: Slow downloads

```bash
# Use different index
uv pip install --index-url https://mirrors.aliyun.com/pypi/simple/ <package>

# Or configure in pyproject.toml
[tool.uv.pip]
index-url = "https://mirrors.aliyun.com/pypi/simple/"
```

## UV vs pip vs Poetry

| Feature | pip | poetry | uv |
|---------|-----|--------|-----|
| Speed | Slow | Medium | **Very Fast** |
| Lock files | No | Yes | **Yes** |
| Dependency resolver | Basic | Good | **Excellent** |
| Virtual envs | Manual | Built-in | **Built-in** |
| Python installation | No | No | **Yes** |
| Workspace support | No | Limited | **Yes** |

## Resources

- **Official Docs**: https://docs.astral.sh/uv/
- **GitHub**: https://github.com/astral-sh/uv
- **Discord**: https://discord.gg/astral-sh
- **Ruff** (same team): https://docs.astral.sh/ruff/

## Quick Reference Card

```bash
# Project setup
uv init my-project           # Create new project
uv venv                      # Create virtual environment
uv sync                      # Install dependencies

# Dependencies
uv add <package>             # Add dependency
uv add --dev <package>       # Add dev dependency
uv remove <package>          # Remove dependency
uv lock --upgrade            # Update lock file

# Running code
uv run python script.py      # Run Python script
uv run -m pytest             # Run module
uv run ruff check .          # Run tool

# Package management
uv pip install <package>     # Install package
uv pip list                  # List packages
uv pip freeze                # Freeze dependencies

# Python versions
uv python list               # List available versions
uv python install 3.14       # Install Python version
```

This guide covers the essential UV commands and workflows for modern Python development.
