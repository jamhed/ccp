# Modern Go Idioms (2025)

Go 1.23+ features and modern best practices.

## Table of Contents
1. [Error Handling](#error-handling)
2. [Generics](#generics)
3. [Range Over Functions (Go 1.23)](#range-over-functions-go-123)
4. [Slices and Maps Packages](#slices-and-maps-packages)
5. [Context Usage](#context-usage)
6. [String Building](#string-building)
7. [Type Parameters in Methods](#type-parameters-in-methods)
8. [Structured Logging (slog)](#structured-logging-slog)
9. [Performance Patterns](#performance-patterns)
10. [Memory Optimization (Go 1.23)](#memory-optimization-go-123)
11. [Modern Time Handling](#modern-time-handling)
12. [Development Tooling](#development-tooling)

## Error Handling

### errors.Join (Go 1.20+)

```go
// GOOD: Use errors.Join for multiple errors
func (r *Reconciler) validateAll(obj *v1alpha1.MyResource) error {
    var errs []error

    if obj.Spec.Name == "" {
        errs = append(errs, fmt.Errorf("name is required"))
    }

    if obj.Spec.Replicas != nil && *obj.Spec.Replicas < 0 {
        errs = append(errs, fmt.Errorf("replicas must be non-negative"))
    }

    return errors.Join(errs...)
}

// BAD: Returning only first error
func (r *Reconciler) validateAll(obj *v1alpha1.MyResource) error {
    if obj.Spec.Name == "" {
        return fmt.Errorf("name is required")
    }
    if obj.Spec.Replicas != nil && *obj.Spec.Replicas < 0 {
        return fmt.Errorf("replicas must be non-negative")
    }
    return nil
}
```

### errors.Is and errors.As

```go
// GOOD: Use errors.Is for sentinel errors
if errors.Is(err, io.EOF) {
    // handle EOF
}

if errors.Is(err, context.DeadlineExceeded) {
    return ctrl.Result{Requeue: true}, nil
}

// GOOD: Use errors.As for type assertions
var apiErr *apierrors.StatusError
if errors.As(err, &apiErr) {
    if apiErr.Status().Code == 409 {
        // handle conflict
    }
}

// BAD: Direct comparison
if err == io.EOF {  // Won't work with wrapped errors
}

// BAD: Type assertion without errors.As
if statusErr, ok := err.(*apierrors.StatusError); ok {
    // Won't work with wrapped errors
}
```

## Generics

### Generic Utility Functions

```go
// GOOD: Type-safe generic utilities
func Ptr[T any](v T) *T {
    return &v
}

func Deref[T any](ptr *T, defaultValue T) T {
    if ptr == nil {
        return defaultValue
    }
    return *ptr
}

// Usage
replicas := Deref(obj.Spec.Replicas, int32(1))

// GOOD: Generic map function
func Map[T, U any](slice []T, fn func(T) U) []U {
    result := make([]U, len(slice))
    for i, v := range slice {
        result[i] = fn(v)
    }
    return result
}

// Convert pod names to deployment names
deploymentNames := Map(pods, func(p corev1.Pod) string {
    return p.Name + "-deploy"
})
```

### Generic Constraints

```go
// GOOD: Use constraints for type safety
func Max[T constraints.Ordered](a, b T) T {
    if a > b {
        return a
    }
    return b
}

// GOOD: Custom constraints
type Kubernetes interface {
    client.Object
    GetSpec() any
}

func UpdateResource[T Kubernetes](ctx context.Context, c client.Client, obj T) error {
    return c.Update(ctx, obj)
}
```

## Range Over Functions (Go 1.23)

### Iterator Pattern

```go
// GOOD: Custom iterators for resource listing
func (r *Reconciler) ListPods(ctx context.Context, namespace string) iter.Seq2[*corev1.Pod, error] {
    return func(yield func(*corev1.Pod, error) bool) {
        podList := &corev1.PodList{}
        if err := r.List(ctx, podList, client.InNamespace(namespace)); err != nil {
            yield(nil, err)
            return
        }

        for i := range podList.Items {
            if !yield(&podList.Items[i], nil) {
                return
            }
        }
    }
}

// Usage
for pod, err := range r.ListPods(ctx, "default") {
    if err != nil {
        return err
    }
    fmt.Println(pod.Name)
}

// GOOD: Early termination
for pod, err := range r.ListPods(ctx, "default") {
    if err != nil {
        return err
    }
    if pod.Status.Phase == corev1.PodRunning {
        return pod // Early return stops iteration
    }
}
```

### Functional Iteration

```go
// GOOD: Filter iterator
func Filter[T any](seq iter.Seq[T], predicate func(T) bool) iter.Seq[T] {
    return func(yield func(T) bool) {
        for v := range seq {
            if predicate(v) {
                if !yield(v) {
                    return
                }
            }
        }
    }
}

// Usage
readyPods := Filter(AllPods(ctx), func(p *corev1.Pod) bool {
    return p.Status.Phase == corev1.PodRunning
})
```

## Slices and Maps Packages

### slices Package (Go 1.21+)

```go
import "slices"

// GOOD: Use slices package for common operations
func (r *Reconciler) hasCondition(obj *v1alpha1.MyResource, condType string) bool {
    return slices.ContainsFunc(obj.Status.Conditions, func(c v1alpha1.Condition) bool {
        return c.Type == condType
    })
}

// GOOD: Sorting
slices.SortFunc(conditions, func(a, b v1alpha1.Condition) int {
    return strings.Compare(a.Type, b.Type)
})

// GOOD: Removing duplicates
names = slices.Compact(slices.Sorted(names))

// GOOD: Clone slices
originalLabels := obj.Labels
labelsCopy := slices.Clone(maps.Keys(originalLabels))

// BAD: Manual implementation
func contains(slice []string, s string) bool {
    for _, v := range slice {
        if v == s {
            return true
        }
    }
    return false
}
```

### maps Package (Go 1.21+)

```go
import "maps"

// GOOD: Clone maps
originalLabels := obj.GetLabels()
newLabels := maps.Clone(originalLabels)
newLabels["new-key"] = "value"

// GOOD: Merge maps
maps.Copy(deployment.Labels, obj.Spec.AdditionalLabels)

// GOOD: Get all keys
keys := maps.Keys(obj.GetAnnotations())

// BAD: Manual map cloning
newLabels := make(map[string]string)
for k, v := range obj.GetLabels() {
    newLabels[k] = v
}
```

## Context Usage

### Context Values (Type-Safe)

```go
// GOOD: Type-safe context keys
type contextKey string

const (
    requestIDKey contextKey = "request-id"
    tenantIDKey  contextKey = "tenant-id"
)

func WithRequestID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, requestIDKey, id)
}

func GetRequestID(ctx context.Context) (string, bool) {
    id, ok := ctx.Value(requestIDKey).(string)
    return id, ok
}

// BAD: String keys (can collide)
ctx = context.WithValue(ctx, "request-id", id)
```

### Context Cancellation

```go
// GOOD: Always use context with timeout for external calls
func (r *Reconciler) callExternalAPI(ctx context.Context) error {
    ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
    defer cancel()

    // Make API call
    return r.apiClient.Do(ctx)
}

// GOOD: Check context cancellation in loops
func (r *Reconciler) processLargeList(ctx context.Context, items []Item) error {
    for _, item := range items {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
        }

        if err := r.processItem(ctx, item); err != nil {
            return err
        }
    }
    return nil
}
```

## String Building

### strings.Builder

```go
// GOOD: Use strings.Builder for efficient string concatenation
func (r *Reconciler) buildMessage(conditions []v1alpha1.Condition) string {
    var sb strings.Builder
    sb.Grow(len(conditions) * 50) // Pre-allocate

    for i, cond := range conditions {
        if i > 0 {
            sb.WriteString(", ")
        }
        sb.WriteString(cond.Type)
        sb.WriteString("=")
        sb.WriteString(string(cond.Status))
    }

    return sb.String()
}

// BAD: String concatenation in loop
func buildMessage(conditions []v1alpha1.Condition) string {
    msg := ""
    for _, cond := range conditions {
        msg += cond.Type + "=" + string(cond.Status) + ", "
    }
    return msg
}
```

## Type Parameters in Methods

### Generic Reconciler Methods

```go
// GOOD: Generic methods for common operations
type Reconciler struct {
    client.Client
    Scheme *runtime.Scheme
}

func (r *Reconciler) GetOrCreate[T client.Object](
    ctx context.Context,
    key client.ObjectKey,
    obj T,
    mutate func(T) error,
) (T, error) {
    err := r.Get(ctx, key, obj)
    if err == nil {
        return obj, nil
    }

    if !apierrors.IsNotFound(err) {
        var zero T
        return zero, err
    }

    if err := mutate(obj); err != nil {
        var zero T
        return zero, err
    }

    if err := r.Create(ctx, obj); err != nil {
        var zero T
        return zero, err
    }

    return obj, nil
}

// Usage
deployment, err := r.GetOrCreate(ctx, key, &appsv1.Deployment{}, func(d *appsv1.Deployment) error {
    d.Spec.Replicas = Ptr(int32(3))
    return nil
})
```

## Structured Logging (slog)

### Modern Logging with slog

```go
import "log/slog"

// GOOD: Use slog for structured logging
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    logger := slog.With(
        "namespace", req.Namespace,
        "name", req.Name,
    )

    logger.Info("starting reconciliation")

    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        logger.Error("failed to get resource", "error", err)
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    logger.Info("reconciled successfully",
        "generation", obj.Generation,
        "resourceVersion", obj.ResourceVersion,
    )

    return ctrl.Result{}, nil
}

// GOOD: Contextual logging
logger := slog.With("component", "webhook")
logger.InfoContext(ctx, "validating resource",
    "kind", obj.GetObjectKind(),
    "operation", operation,
)

// BAD: Unstructured logging
log.Printf("reconciling %s/%s", req.Namespace, req.Name)
```

### Log Levels

```go
// GOOD: Appropriate log levels
slog.Debug("detailed trace information", "data", rawData)
slog.Info("normal operation", "action", "created")
slog.Warn("unexpected but handled", "retries", count)
slog.Error("operation failed", "error", err)

// Use With for repeated context
logger := slog.With("resource", obj.Name)
logger.Info("validating")
logger.Info("creating")
```

## Performance Patterns

### Avoiding Allocations

```go
// GOOD: Pre-allocate slices when size is known
conditions := make([]v1alpha1.Condition, 0, 5)

// GOOD: Reuse buffers
var buf bytes.Buffer
buf.Reset()
buf.WriteString("data")

// GOOD: String conversion without allocation
labels := obj.GetLabels()
for k, v := range labels {
    // Use k, v directly; don't convert to []byte unless necessary
}

// BAD: Growing slices in loop
var items []Item
for _, raw := range rawItems {
    items = append(items, parseItem(raw)) // Reallocates
}
```

### Efficient Comparisons with cmp Package

```go
import "cmp"

// GOOD: Use cmp.Or for default values (Go 1.22+)
replicas := cmp.Or(obj.Spec.Replicas, Ptr(int32(1)))

// GOOD: Chain cmp.Or for multiple fallbacks
imageTag := cmp.Or(obj.Spec.ImageTag, obj.Spec.Version, "latest")

// GOOD: Use with pointers to avoid nil checks
timeout := cmp.Or(obj.Spec.Timeout, 30*time.Second)

// GOOD: Use cmp.Compare for ordering
func compareConditions(a, b v1alpha1.Condition) int {
    return cmp.Compare(a.LastTransitionTime.Time, b.LastTransitionTime.Time)
}

// GOOD: Multi-field comparison with cmp.Or
func compareResources(a, b *v1alpha1.MyResource) int {
    return cmp.Or(
        cmp.Compare(a.Spec.Priority, b.Spec.Priority),
        strings.Compare(a.Name, b.Name),
    )
}

// GOOD: Use in sorting
slices.SortFunc(resources, func(a, b *v1alpha1.MyResource) int {
    // Sort by priority, then by name
    return cmp.Or(
        cmp.Compare(a.Spec.Priority, b.Spec.Priority),
        strings.Compare(a.Name, b.Name),
    )
})

// BAD: Manual default value checks
var timeout time.Duration
if obj.Spec.Timeout != nil {
    timeout = *obj.Spec.Timeout
} else {
    timeout = 30 * time.Second
}
```

### Profile-Guided Optimization (PGO)

Go 1.23 significantly improved PGO performance (overhead reduced from 100%+ to single-digit percentages).

```go
// Production deployment workflow:

// 1. Build operator with profiling enabled
go build -o operator-profiling ./cmd/operator

// 2. Deploy to production/staging and collect profile
// The profile will be written to /tmp/cpu.pprof or configure with GODEBUG
kubectl exec <operator-pod> -- curl http://localhost:8080/debug/pprof/profile?seconds=30 > default.pgo

// 3. Rebuild with PGO enabled
go build -pgo=default.pgo -o operator-optimized ./cmd/operator

// 4. Deploy optimized binary
// Expected: 1-5% performance improvement with minimal build overhead
```

**When to use PGO:**
- ✅ Production Kubernetes operators with known workload patterns
- ✅ High-throughput reconciliation loops
- ✅ CPU-intensive validation or transformation logic
- ❌ Prototype or development builds (adds build time)
- ❌ Highly variable workloads (profile won't be representative)

```go
// GOOD: Makefile integration
.PHONY: build-pgo
build-pgo: default.pgo
	go build -pgo=default.pgo -o bin/operator ./cmd/operator

.PHONY: profile
profile:
	kubectl exec -n $(NAMESPACE) $(POD) -- \
		curl -s http://localhost:8080/debug/pprof/profile?seconds=60 > default.pgo
```

## Memory Optimization (Go 1.23)

### unique Package

The `unique` package provides value canonicalization (interning) to reduce memory footprint for frequently repeated comparable values.

```go
import "unique"

// GOOD: Canonicalize container images across many pods
type ImageCache struct {
    mu     sync.RWMutex
    images map[unique.Handle[string]]*ImageMetadata
}

func (c *ImageCache) GetOrStore(image string) *ImageMetadata {
    c.mu.RLock()
    handle := unique.Make(image)
    if meta, ok := c.images[handle]; ok {
        c.mu.RUnlock()
        return meta
    }
    c.mu.RUnlock()

    c.mu.Lock()
    defer c.mu.Unlock()

    // Double-check after acquiring write lock
    if meta, ok := c.images[handle]; ok {
        return meta
    }

    meta := &ImageMetadata{Image: image}
    c.images[handle] = meta
    return meta
}

// GOOD: Deduplicate namespace strings across resources
type ResourceTracker struct {
    namespaces map[unique.Handle[string]][]client.Object
}

func (t *ResourceTracker) Track(obj client.Object) {
    ns := unique.Make(obj.GetNamespace())
    t.namespaces[ns] = append(t.namespaces[ns], obj)
}

// GOOD: Canonical label keys/values
type LabelSet struct {
    labels map[unique.Handle[string]]unique.Handle[string]
}

func (ls *LabelSet) Add(key, value string) {
    ls.labels[unique.Make(key)] = unique.Make(value)
}
```

**When to use unique package:**
- ✅ Long-running operators with many similar string values
- ✅ Caching container images, namespaces, label keys across thousands of resources
- ✅ Deduplicating configuration values
- ⚠️ Only for comparable types (strings, ints, custom comparable structs)
- ❌ Short-lived processes (interning overhead not worth it)
- ❌ Unique values that rarely repeat

```go
// GOOD: Interning custom comparable types
type ResourceIdentifier struct {
    Namespace string
    Name      string
    Kind      string
}

type OperatorCache struct {
    resources map[unique.Handle[ResourceIdentifier]]*CachedResource
}

func (c *OperatorCache) Get(ns, name, kind string) *CachedResource {
    id := unique.Make(ResourceIdentifier{
        Namespace: ns,
        Name:      name,
        Kind:      kind,
    })
    return c.resources[id]
}

// BAD: Manual string interning (use unique package instead)
type badCache struct {
    strings map[string]string
}

func (c *badCache) intern(s string) string {
    if existing, ok := c.strings[s]; ok {
        return existing
    }
    c.strings[s] = s
    return s
}
```

## Modern Time Handling

### Time Operations

```go
// GOOD: Use time.Now() consistently
now := time.Now()
obj.Status.LastUpdate = metav1.NewTime(now)
logger.Info("updated", "timestamp", now)

// GOOD: Duration parsing
timeout, err := time.ParseDuration(obj.Spec.Timeout)
if err != nil {
    return fmt.Errorf("invalid timeout: %w", err)
}

// GOOD: Time comparisons
if time.Since(obj.Status.LastUpdate.Time) > 5*time.Minute {
    // Re-sync needed
}
```

### Timer and Ticker Improvements (Go 1.23)

Go 1.23 changed Timer/Ticker behavior significantly:
1. **Automatic GC**: Timers are GC-eligible immediately when unreferenced, even without calling Stop()
2. **Unbuffered channels**: Timer channels now have capacity 0 (previously capacity 1)

```go
// GOOD: Modern timer usage (Go 1.23+)
func (r *Reconciler) reconcileWithTimeout(ctx context.Context, obj client.Object) error {
    timer := time.NewTimer(30 * time.Second)
    defer timer.Stop() // Still good practice, but not required for GC

    select {
    case <-timer.C:
        return fmt.Errorf("reconciliation timed out")
    case <-ctx.Done():
        return ctx.Err()
    case result := <-r.reconcile(ctx, obj):
        return result
    }
}

// GOOD: Ticker with automatic cleanup
func (r *Reconciler) startPeriodicSync(ctx context.Context) {
    ticker := time.NewTicker(1 * time.Minute)
    defer ticker.Stop()

    for {
        select {
        case <-ticker.C:
            r.sync(ctx)
        case <-ctx.Done():
            return
        }
    }
}

// GOOD: Reset timer safely (Go 1.23)
func (r *Reconciler) retryWithBackoff(ctx context.Context, fn func() error) error {
    timer := time.NewTimer(1 * time.Second)
    defer timer.Stop()

    for attempt := 0; attempt < 5; attempt++ {
        if err := fn(); err == nil {
            return nil
        }

        if !timer.Stop() {
            <-timer.C // Drain channel if timer fired
        }
        timer.Reset(time.Duration(1<<attempt) * time.Second)

        select {
        case <-timer.C:
            // Continue to next attempt
        case <-ctx.Done():
            return ctx.Err()
        }
    }

    return fmt.Errorf("max retries exceeded")
}

// BAD: Pre-1.23 pattern assuming buffered channel
func oldTimerPattern() {
    timer := time.NewTimer(1 * time.Second)
    timer.Stop()
    // BAD: Assuming channel is buffered
    select {
    case <-timer.C: // This may block in Go 1.23+
    default:
    }
}

// GOOD: Controller-runtime requeue with timer semantics
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Use RequeueAfter instead of manual timers
    if !r.isReady(obj) {
        return ctrl.Result{RequeueAfter: 30 * time.Second}, nil
    }

    return ctrl.Result{}, nil
}
```

**Key Changes in Go 1.23:**
- ✅ Timers are GC-eligible immediately when dereferenced
- ✅ No stale values in timer channel after Reset/Stop
- ✅ More predictable behavior for concurrent timer operations
- ⚠️ Channel is unbuffered (capacity 0, not 1)
- ⚠️ Code assuming buffered behavior may need updates

```go
// GOOD: Time-based rate limiting
type RateLimiter struct {
    interval time.Duration
    timer    *time.Timer
    mu       sync.Mutex
}

func (rl *RateLimiter) Allow() bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    if rl.timer == nil {
        rl.timer = time.NewTimer(rl.interval)
        return true
    }

    select {
    case <-rl.timer.C:
        rl.timer.Reset(rl.interval)
        return true
    default:
        return false
    }
}
```

## Development Tooling

### Modern go Commands (Go 1.23+)

```bash
# GOOD: Check which environment settings differ from defaults
go env -changed

# Example output:
# GOARCH="arm64"
# GOOS="darwin"
# GOPATH="/Users/you/go"

# GOOD: Preview go mod tidy changes without modifying files
go mod tidy -diff

# Shows what would change without actually modifying go.mod/go.sum
# Useful in CI to verify dependencies are tidy

# GOOD: Verify code targets correct Go version
go vet -version=go1.23 ./...

# Reports usage of symbols too new for target version
# Catches issues before deployment to environments with older Go versions
```

### go vet Enhancements

```bash
# GOOD: Comprehensive vetting in CI/CD
go vet -version=go1.21 ./...

# Catches:
# - Use of Go 1.22+ features when targeting 1.21
# - Common mistakes (printf formatting, struct tags, etc.)
# - Unreachable code
# - Invalid build constraints

# Example error:
# pkg/reconciler/reconciler.go:42:2: slices.Contains requires go1.21 or later (-version=go1.20 was specified)
```

### Makefile Integration

```makefile
# GOOD: Modern Go tooling in Makefile
.PHONY: verify
verify: verify-tidy verify-vet

.PHONY: verify-tidy
verify-tidy:
	@echo "Verifying go mod tidy..."
	@go mod tidy -diff || (echo "go.mod or go.sum needs updates. Run 'go mod tidy'"; exit 1)

.PHONY: verify-vet
verify-vet:
	@echo "Running go vet..."
	@go vet -version=go1.23 ./...

.PHONY: env-check
env-check:
	@echo "Non-default Go environment settings:"
	@go env -changed

.PHONY: build-release
build-release:
	@echo "Building optimized release binary..."
	@if [ -f default.pgo ]; then \
		go build -pgo=default.pgo -ldflags="-s -w" -o bin/operator ./cmd/operator; \
	else \
		go build -ldflags="-s -w" -o bin/operator ./cmd/operator; \
	fi
```

### CI/CD Integration

```yaml
# GOOD: GitHub Actions workflow with modern Go tooling
name: CI
on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'

      - name: Verify go mod tidy
        run: |
          go mod tidy -diff
          if [ $? -ne 0 ]; then
            echo "::error::go.mod or go.sum needs updates. Run 'go mod tidy'"
            exit 1
          fi

      - name: Run go vet
        run: go vet -version=go1.23 ./...

      - name: Check environment
        run: go env -changed

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'

      - name: Run tests
        run: go test -v -race -coverprofile=coverage.out ./...

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage.out
```

### golangci-lint Integration

```yaml
# .golangci.yml - Modern linter configuration for Go 1.23+
run:
  go: '1.23'
  timeout: 5m

linters:
  enable:
    - errcheck      # Check for unchecked errors
    - gosimple      # Simplify code
    - govet         # Vet examines Go source code
    - ineffassign   # Detect ineffectual assignments
    - staticcheck   # Advanced Go linter
    - unused        # Find unused code
    - gofmt         # Format code
    - goimports     # Manage imports
    - misspell      # Fix spelling
    - revive        # Replacement for golint
    - stylecheck    # Enforce style guide
    - gosec         # Security issues
    - unconvert     # Unnecessary type conversions
    - gocritic      # Opinionated checks
    - predeclared   # Find shadowed predeclared identifiers

linters-settings:
  govet:
    enable-all: true
    settings:
      printf:
        funcs:
          - (github.com/go-logr/logr.Logger).Infof
          - (github.com/go-logr/logr.Logger).Errorf

  staticcheck:
    checks: ["all"]

  revive:
    rules:
      - name: var-naming
        disabled: false
      - name: exported
        disabled: false
```

### Development Workflow

```bash
# GOOD: Pre-commit verification script
#!/bin/bash
# scripts/verify.sh

set -e

echo "==> Running go mod tidy verification..."
go mod tidy -diff

echo "==> Running go vet..."
go vet -version=go1.23 ./...

echo "==> Running golangci-lint..."
golangci-lint run

echo "==> Running tests..."
go test -race -short ./...

echo "✅ All checks passed!"
```

### Build Tags and Version Constraints

```go
//go:build go1.23

package modern

import "unique"

// This file only compiles with Go 1.23+
// Uses unique package introduced in Go 1.23

func Canonicalize(s string) unique.Handle[string] {
    return unique.Make(s)
}
```

```bash
# GOOD: Verify build tags
go list -f '{{.GoFiles}}' ./pkg/modern

# GOOD: Test with specific Go version
go test -tags=go1.23 ./...
```

**Best Practices:**
- ✅ Use `go mod tidy -diff` in CI to catch dependency issues early
- ✅ Set `-version` flag in `go vet` to match deployment Go version
- ✅ Enable `go env -changed` in debugging to identify environment issues
- ✅ Use build tags for version-specific code
- ✅ Integrate PGO for production builds
- ❌ Don't skip `go mod tidy` verification in CI
- ❌ Don't ignore `go vet` warnings
