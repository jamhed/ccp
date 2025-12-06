# Defensive Coding Patterns for LLM Agents

Patterns to prevent common mistakes when generating Go code. These complement fail-early patterns with explicit safety checks.

## Table of Contents
1. [Bounds Checking](#bounds-checking)
2. [Map Access](#map-access)
3. [Resource Cleanup](#resource-cleanup)
4. [Panic Prevention](#panic-prevention)
5. [Context and Timeouts](#context-and-timeouts)
6. [Channel Safety](#channel-safety)
7. [Type Conversion Safety](#type-conversion-safety)

## Bounds Checking

### Always Check Slice Length Before Access

```go
// BAD: Assumes slice has elements
func getFirst(items []string) string {
    return items[0]  // PANIC if empty
}

// GOOD: Check length first
func getFirst(items []string) (string, error) {
    if len(items) == 0 {
        return "", fmt.Errorf("no items found")
    }
    return items[0], nil
}

// GOOD: Use cmp.Or for optional first element
func getFirstOrDefault(items []string, defaultVal string) string {
    if len(items) == 0 {
        return defaultVal
    }
    return items[0]
}
```

### Check Index Before Access

```go
// BAD: Assumes index is valid
func getAt(items []string, index int) string {
    return items[index]  // PANIC if out of bounds
}

// GOOD: Validate index
func getAt(items []string, index int) (string, error) {
    if index < 0 || index >= len(items) {
        return "", fmt.Errorf("index %d out of bounds (len=%d)", index, len(items))
    }
    return items[index], nil
}
```

### Safe Slice Operations

```go
// BAD: Assumes slice has enough elements
func getLastN(items []string, n int) []string {
    return items[len(items)-n:]  // PANIC if n > len(items)
}

// GOOD: Handle edge cases
func getLastN(items []string, n int) []string {
    if n <= 0 {
        return nil
    }
    if n >= len(items) {
        return items
    }
    return items[len(items)-n:]
}
```

## Map Access

### Check Key Existence

```go
// BAD: Assumes key exists, gets zero value silently
func getValue(m map[string]int, key string) int {
    return m[key]  // Returns 0 if key missing - silent bug
}

// GOOD: Check existence explicitly
func getValue(m map[string]int, key string) (int, error) {
    value, ok := m[key]
    if !ok {
        return 0, fmt.Errorf("key %q not found", key)
    }
    return value, nil
}

// GOOD: Return with found flag
func getValue(m map[string]int, key string) (int, bool) {
    value, ok := m[key]
    return value, ok
}
```

### Safe Map with Default

```go
// GOOD: Get with default value
func getOrDefault(m map[string]int, key string, defaultVal int) int {
    if value, ok := m[key]; ok {
        return value
    }
    return defaultVal
}

// GOOD: Using cmp.Or won't work for maps - use explicit check
// cmp.Or(m[key], defaultVal) is WRONG - zero value != missing
```

### Nil Map Safety

```go
// BAD: Write to nil map panics
func addToMap(m map[string]int, key string, value int) {
    m[key] = value  // PANIC if m is nil
}

// GOOD: Initialize if nil
func addToMap(m map[string]int, key string, value int) map[string]int {
    if m == nil {
        m = make(map[string]int)
    }
    m[key] = value
    return m
}

// GOOD: Read from nil map is safe (returns zero value)
func getValue(m map[string]int, key string) int {
    return m[key]  // Safe - returns 0 if nil or missing
}
```

## Resource Cleanup

### Always Defer Close

```go
// BAD: Resource leak if error occurs
func readFile(path string) ([]byte, error) {
    file, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    // If ReadAll fails, file is never closed
    data, err := io.ReadAll(file)
    if err != nil {
        return nil, err
    }
    file.Close()
    return data, nil
}

// GOOD: Defer close immediately after open
func readFile(path string) ([]byte, error) {
    file, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer file.Close()  // Always runs, even on error

    return io.ReadAll(file)
}
```

### Defer Order Matters

```go
// GOOD: Defers run in LIFO order
func process() error {
    db, err := openDB()
    if err != nil {
        return err
    }
    defer db.Close()  // Runs second

    tx, err := db.Begin()
    if err != nil {
        return err
    }
    defer tx.Rollback()  // Runs first (rollback is safe after commit)

    // ... operations ...

    return tx.Commit()  // Rollback is no-op after successful commit
}
```

### Handle Close Errors

```go
// BAD: Ignoring close error
defer file.Close()

// GOOD: Check close error for writes
func writeFile(path string, data []byte) (err error) {
    file, err := os.Create(path)
    if err != nil {
        return err
    }
    defer func() {
        closeErr := file.Close()
        if err == nil {
            err = closeErr  // Return close error if no prior error
        }
    }()

    _, err = file.Write(data)
    return err
}

// GOOD: Simpler pattern - close error matters for writes
func writeFile(path string, data []byte) error {
    file, err := os.Create(path)
    if err != nil {
        return err
    }

    if _, err := file.Write(data); err != nil {
        file.Close()
        return err
    }

    return file.Close()  // Check close error
}
```

### Lock Cleanup

```go
// GOOD: Always unlock with defer
func (r *Reconciler) updateCache(key, value string) {
    r.mu.Lock()
    defer r.mu.Unlock()

    r.cache[key] = value
}

// BAD: Forgetting unlock on early return
func (r *Reconciler) updateCache(key, value string) error {
    r.mu.Lock()

    if key == "" {
        return fmt.Errorf("empty key")  // DEADLOCK - forgot unlock
    }

    r.cache[key] = value
    r.mu.Unlock()
    return nil
}
```

## Panic Prevention

### Operations That Can Panic

```go
// These operations can panic - always guard them:

// 1. Slice/array index out of bounds
items[i]           // Guard: check 0 <= i < len(items)

// 2. Nil pointer dereference
*ptr               // Guard: check ptr != nil (for interface types)

// 3. Nil map write
m[key] = value     // Guard: check m != nil or initialize

// 4. Nil channel operations
close(ch)          // Guard: check ch != nil
ch <- value        // Guard: check ch != nil and not closed

// 5. Type assertion without ok
v := x.(Type)      // Guard: use v, ok := x.(Type)

// 6. Divide by zero (integers only)
a / b              // Guard: check b != 0

// 7. Negative slice capacity
make([]T, n)       // Guard: check n >= 0
```

### Safe Type Assertions

```go
// BAD: Panics if wrong type
func process(obj interface{}) {
    res := obj.(*v1alpha1.MyResource)  // PANIC if wrong type
    // ...
}

// GOOD: Check type assertion
func process(obj interface{}) error {
    res, ok := obj.(*v1alpha1.MyResource)
    if !ok {
        return fmt.Errorf("expected *MyResource, got %T", obj)
    }
    // ...
    return nil
}

// GOOD: Use type switch for multiple types
func process(obj interface{}) error {
    switch v := obj.(type) {
    case *v1alpha1.MyResource:
        return processResource(v)
    case *v1alpha1.OtherResource:
        return processOther(v)
    default:
        return fmt.Errorf("unsupported type: %T", obj)
    }
}
```

### Safe Division

```go
// BAD: Integer division by zero panics
func average(sum, count int) int {
    return sum / count  // PANIC if count == 0
}

// GOOD: Check divisor
func average(sum, count int) (int, error) {
    if count == 0 {
        return 0, fmt.Errorf("cannot divide by zero")
    }
    return sum / count, nil
}

// GOOD: Return default for empty
func average(sum, count int) int {
    if count == 0 {
        return 0
    }
    return sum / count
}
```

### Recovery for Critical Sections

```go
// GOOD: Recover in goroutines to prevent process crash
func (r *Reconciler) startWorker(ctx context.Context) {
    go func() {
        defer func() {
            if p := recover(); p != nil {
                slog.Error("worker panicked", "panic", p, "stack", string(debug.Stack()))
            }
        }()

        r.worker(ctx)
    }()
}

// NOTE: Only use recover() at goroutine boundaries
// Don't use recover() to hide bugs in regular code
```

## Context and Timeouts

### Check Context Before Long Operations

```go
// BAD: Ignoring context cancellation
func (r *Reconciler) processItems(ctx context.Context, items []Item) error {
    for _, item := range items {
        if err := r.processItem(item); err != nil {  // Ignores ctx
            return err
        }
    }
    return nil
}

// GOOD: Check context in loops
func (r *Reconciler) processItems(ctx context.Context, items []Item) error {
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

### Deadline Awareness

```go
// GOOD: Check remaining time before expensive operations
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    // Check if we have enough time
    if deadline, ok := ctx.Deadline(); ok {
        remaining := time.Until(deadline)
        if remaining < 5*time.Second {
            return fmt.Errorf("insufficient time remaining: %v", remaining)
        }
    }

    return r.expensiveOperation(ctx, obj)
}
```

### Always Pass Context

```go
// BAD: Dropping context
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := r.buildDeployment(obj)
    return r.Create(context.Background(), deployment)  // BAD: loses timeout/cancellation
}

// GOOD: Propagate context
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := r.buildDeployment(obj)
    return r.Create(ctx, deployment)  // Respects parent context
}
```

## Channel Safety

### Nil Channel Behavior

```go
// Understanding nil channel behavior:
var ch chan int

ch <- 1    // Blocks forever (doesn't panic, but deadlocks)
<-ch       // Blocks forever
close(ch)  // PANIC

// GOOD: Initialize before use
ch := make(chan int)
```

### Safe Channel Close

```go
// BAD: Closing channel multiple times panics
close(ch)
close(ch)  // PANIC

// BAD: Sending on closed channel panics
close(ch)
ch <- 1    // PANIC

// GOOD: Only close from sender, once
func producer(ch chan<- int) {
    defer close(ch)  // Close when done
    for i := 0; i < 10; i++ {
        ch <- i
    }
}

// GOOD: Use sync.Once for safe close
type SafeChannel struct {
    ch   chan int
    once sync.Once
}

func (s *SafeChannel) Close() {
    s.once.Do(func() {
        close(s.ch)
    })
}
```

### Select with Default for Non-Blocking

```go
// GOOD: Non-blocking send
select {
case ch <- value:
    // Sent successfully
default:
    // Channel full or nil, handle gracefully
    slog.Warn("channel full, dropping value")
}

// GOOD: Non-blocking receive
select {
case value := <-ch:
    process(value)
default:
    // Nothing available
}
```

## Type Conversion Safety

### Integer Overflow

```go
// BAD: Silent overflow
func intToInt32(n int) int32 {
    return int32(n)  // Silently overflows if n > MaxInt32
}

// GOOD: Check bounds
func intToInt32(n int) (int32, error) {
    if n > math.MaxInt32 || n < math.MinInt32 {
        return 0, fmt.Errorf("value %d overflows int32", n)
    }
    return int32(n), nil
}

// GOOD: Use safe conversion library
import "golang.org/x/exp/constraints"

func SafeConvert[From, To constraints.Integer](v From) (To, error) {
    result := To(v)
    if From(result) != v {
        return 0, fmt.Errorf("overflow converting %v", v)
    }
    return result, nil
}
```

### String to Number

```go
// BAD: Ignoring parse errors
func parsePort(s string) int {
    port, _ := strconv.Atoi(s)  // Returns 0 on error - silent bug
    return port
}

// GOOD: Handle parse errors
func parsePort(s string) (int, error) {
    port, err := strconv.Atoi(s)
    if err != nil {
        return 0, fmt.Errorf("invalid port %q: %w", s, err)
    }
    if port < 1 || port > 65535 {
        return 0, fmt.Errorf("port %d out of range", port)
    }
    return port, nil
}
```

## Summary Checklist

Before generating Go code, verify:

1. **Slice access**: Is length checked before indexing?
2. **Map access**: Is key existence checked when needed?
3. **Resources**: Is cleanup deferred immediately after acquisition?
4. **Nil checks**: Are interface types and optional pointers checked?
5. **Type assertions**: Is the ok pattern used?
6. **Context**: Is it propagated and checked in loops?
7. **Channels**: Are nil and close conditions handled?
8. **Division**: Is zero divisor checked for integers?
9. **Conversions**: Are overflow and parse errors handled?

### Quick Reference: Guard Patterns

```go
// Slice bounds
if i < 0 || i >= len(items) { return err }

// Map existence
v, ok := m[key]; if !ok { return err }

// Nil map write
if m == nil { m = make(map[K]V) }

// Type assertion
v, ok := x.(T); if !ok { return err }

// Division
if b == 0 { return err }

// Context in loop
select { case <-ctx.Done(): return ctx.Err(); default: }

// Resource cleanup
defer resource.Close()
```
