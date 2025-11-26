# pnpm Package Manager Guide (2025)

Comprehensive guide to using pnpm for TypeScript projects in 2025, including workspaces and monorepo management.

## Why pnpm in 2025

pnpm is the recommended package manager for TypeScript projects in 2025:

- **2-3x faster** than npm for installations
- **60-80% less disk space** via content-addressable storage
- **Strict dependency resolution** prevents phantom dependencies
- **Built-in workspace support** for monorepos (no Lerna needed)
- **Native TypeScript support** with project references

## Quick Start

### Installation

```bash
# Install pnpm globally
npm install -g pnpm

# Or via corepack (recommended for Node.js 16.10+)
corepack enable
corepack prepare pnpm@latest --activate

# Verify installation
pnpm --version
```

### Project Setup

```bash
# Initialize new project
pnpm init

# Add dependencies
pnpm add express zod
pnpm add -D typescript vitest @types/node

# Install all dependencies
pnpm install

# Run scripts
pnpm run build
pnpm test

# Execute packages
pnpm exec vitest run
pnpm exec tsc --noEmit
```

### package.json Configuration

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "type": "module",
  "engines": {
    "node": ">=20.0.0"
  },
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "test:types": "vitest --typecheck",
    "lint": "eslint .",
    "format": "prettier --write .",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.7.0",
    "vitest": "^2.0.0"
  }
}
```

## Essential Commands

### Dependency Management

```bash
# Add dependencies
pnpm add package-name              # Production dependency
pnpm add -D package-name           # Dev dependency
pnpm add -O package-name           # Optional dependency
pnpm add package-name@version      # Specific version
pnpm add package-name@next         # Tag version

# Remove dependencies
pnpm remove package-name
pnpm rm package-name               # Alias

# Update dependencies
pnpm update                        # Update all
pnpm update package-name           # Update specific
pnpm update --latest               # Update to latest (ignore semver)
pnpm update --interactive          # Interactive update

# Install from lockfile
pnpm install                       # Install all
pnpm install --frozen-lockfile     # CI mode (fail if lockfile outdated)
pnpm install --prod                # Production only
```

### Running Commands

```bash
# Run scripts
pnpm run script-name
pnpm script-name                   # Shorthand (if no conflict)

# Execute packages
pnpm exec package-name args
pnpm dlx package-name              # Download and execute (like npx)

# Common patterns
pnpm exec vitest run
pnpm exec tsc --noEmit
pnpm exec eslint .
pnpm exec prettier --write .
```

### Package Information

```bash
# List dependencies
pnpm list                          # All dependencies
pnpm list --depth=0                # Direct dependencies only
pnpm list --prod                   # Production only
pnpm list --dev                    # Dev only

# Why is package installed?
pnpm why package-name

# Outdated packages
pnpm outdated
```

## Workspaces (Monorepos)

### Workspace Setup

Create `pnpm-workspace.yaml` in the root:

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'tools/*'
```

### Directory Structure

```
monorepo/
├── pnpm-workspace.yaml
├── package.json
├── tsconfig.json
├── apps/
│   ├── web/
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── api/
│       ├── package.json
│       └── tsconfig.json
├── packages/
│   ├── ui/
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── utils/
│       ├── package.json
│       └── tsconfig.json
└── tools/
    └── eslint-config/
        └── package.json
```

### Root package.json

```json
{
  "name": "monorepo",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "build": "pnpm -r build",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint",
    "typecheck": "pnpm -r typecheck",
    "dev": "pnpm --parallel -r dev"
  },
  "devDependencies": {
    "typescript": "^5.7.0"
  }
}
```

### Package package.json

```json
{
  "name": "@monorepo/utils",
  "version": "1.0.0",
  "type": "module",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch"
  }
}
```

### Workspace Commands

```bash
# Run command in all packages
pnpm -r build                      # Recursive run
pnpm --parallel -r build           # Parallel execution

# Run command in specific package
pnpm --filter @monorepo/web build
pnpm --filter web build            # Shorthand

# Run command in packages matching pattern
pnpm --filter "./packages/*" build
pnpm --filter "...@monorepo/web" build  # Including dependencies

# Add dependency to specific package
pnpm --filter @monorepo/web add react
pnpm --filter @monorepo/api add express

# Add workspace dependency
pnpm --filter @monorepo/web add @monorepo/utils@workspace:*
```

### Workspace Dependencies

```json
{
  "dependencies": {
    "@monorepo/utils": "workspace:*",
    "@monorepo/ui": "workspace:^1.0.0"
  }
}
```

Workspace protocol options:
- `workspace:*` - Any version from workspace
- `workspace:~` - Patch version range
- `workspace:^` - Minor version range

### TypeScript Project References

Root `tsconfig.json`:

```json
{
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true
  },
  "references": [
    { "path": "./packages/utils" },
    { "path": "./packages/ui" },
    { "path": "./apps/web" },
    { "path": "./apps/api" }
  ]
}
```

Package `tsconfig.json`:

```json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"],
  "references": [
    { "path": "../utils" }
  ]
}
```

Build with references:

```bash
pnpm exec tsc --build
pnpm exec tsc --build --watch
```

## Configuration

### .npmrc

```ini
# Strict peer dependencies (recommended)
strict-peer-dependencies=true

# Auto-install peers (recommended for TypeScript)
auto-install-peers=true

# Hoist patterns (default, usually don't change)
# public-hoist-pattern[]=*types*
# public-hoist-pattern[]=*eslint*

# Shamefully hoist (NOT recommended, use only if needed)
# shamefully-hoist=true

# Save exact versions
save-exact=true

# Engine strict (fail on incompatible Node.js)
engine-strict=true
```

### pnpm-workspace.yaml Options

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'tools/*'
  - '!**/test/**'  # Exclude test directories
```

## CI/CD Integration

### GitHub Actions

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 9

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Type check
        run: pnpm typecheck

      - name: Lint
        run: pnpm lint

      - name: Test
        run: pnpm test:run

      - name: Build
        run: pnpm build
```

### Docker

```dockerfile
FROM node:20-alpine

# Enable corepack for pnpm
RUN corepack enable

WORKDIR /app

# Copy package files first for caching
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile --prod

# Copy source
COPY . .

# Build
RUN pnpm build

CMD ["pnpm", "start"]
```

## Best Practices

### 1. Lock File Management

```bash
# Always commit pnpm-lock.yaml
git add pnpm-lock.yaml

# Use frozen lockfile in CI
pnpm install --frozen-lockfile
```

### 2. Workspace Dependencies

```bash
# Use workspace protocol for internal packages
pnpm --filter @monorepo/web add @monorepo/utils@workspace:*

# Not bare imports
# ❌ "@monorepo/utils": "1.0.0"
# ✅ "@monorepo/utils": "workspace:*"
```

### 3. Peer Dependencies

```bash
# Auto-install peers (in .npmrc)
auto-install-peers=true

# Or install manually
pnpm add peer-package-name
```

### 4. Common devDependencies

Hoist common devDependencies to root:

```json
{
  "devDependencies": {
    "typescript": "^5.7.0",
    "vitest": "^2.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0"
  }
}
```

### 5. Scripts Organization

```json
{
  "scripts": {
    "build": "pnpm -r build",
    "build:web": "pnpm --filter @monorepo/web build",
    "dev": "pnpm --parallel -r dev",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint",
    "typecheck": "pnpm -r typecheck",
    "clean": "pnpm -r exec rm -rf dist node_modules"
  }
}
```

## Comparison with npm/yarn

| Feature | pnpm | npm | yarn |
|---------|------|-----|------|
| Speed | Fastest | Slow | Medium |
| Disk space | Minimal | Large | Large |
| Workspaces | Built-in | Built-in | Built-in |
| Strict deps | Yes | No | No |
| Phantom deps | Prevented | Allowed | Allowed |
| Lock file | pnpm-lock.yaml | package-lock.json | yarn.lock |

## Troubleshooting

### Common Issues

**"ENOENT: no such file or directory"**
```bash
# Clear store and reinstall
pnpm store prune
rm -rf node_modules
pnpm install
```

**Peer dependency warnings**
```bash
# Auto-install peers
echo "auto-install-peers=true" >> .npmrc
pnpm install
```

**Workspace package not found**
```bash
# Check workspace configuration
cat pnpm-workspace.yaml

# Verify package name matches
pnpm list --filter @monorepo/package-name
```

**TypeScript can't find workspace package**
```bash
# Ensure project references are set up
# Check tsconfig.json references array
# Build packages in dependency order
pnpm exec tsc --build
```

## Summary

**Essential Commands**:
```bash
pnpm add package           # Add dependency
pnpm add -D package        # Add dev dependency
pnpm install               # Install all
pnpm exec command          # Execute package
pnpm -r command            # Run in all packages
pnpm --filter pkg command  # Run in specific package
```

**Key Configuration**:
- `pnpm-workspace.yaml` - Workspace definition
- `.npmrc` - pnpm settings
- `packageManager` in package.json - Lock pnpm version

**Best Practices**:
- Use `workspace:*` for internal dependencies
- Commit `pnpm-lock.yaml`
- Use `--frozen-lockfile` in CI
- Hoist common devDependencies to root
- Use TypeScript project references
