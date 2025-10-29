# JP (JMESPath) Functions Reference

Complete reference of JP functions available in Chainsaw for assertions and validations.

## Table of Contents
1. [Built-in JMESPath Functions](#built-in-jmespath-functions)
2. [Kyverno-JSON Functions](#kyverno-json-functions)
3. [Kyverno Functions](#kyverno-functions)
4. [Chainsaw Functions](#chainsaw-functions)
5. [Common Assertion Patterns](#common-assertion-patterns)

## Built-in JMESPath Functions

### Array Functions

#### `length(array|string|object)`
Returns the number of elements in an array, characters in a string, or key-value pairs in an object.

```yaml
# GOOD: Validate response count
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      status:
        (length(responses)): 1

# GOOD: Validate string length
(length(responses[0].content) > `10`): true

# GOOD: Check empty array
(length(conditions)): 0
```

#### `contains(array, value)`
Checks if an array contains a specific value.

```yaml
# GOOD: Validate agent responded
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      status:
        (contains(responses[*].target.name, 'agent-name')): true

# GOOD: Validate agent did NOT respond
(contains(responses[*].target.name, 'excluded-agent')): false

# GOOD: Check for value in array
(contains(tags, 'production')): true
```

#### `join(separator, array)`
Joins array elements into a string with the given separator.

```yaml
# GOOD: Concatenate all response content and check length
- assert:
    resource:
      status:
        (length(join('', responses[*].content)) > `50`): true

# GOOD: Join with separator
(join(',', names)): 'agent-1,agent-2,agent-3'

# GOOD: Check joined string contains text
(contains(join(' ', responses[*].content), 'expected-text')): true
```

#### `sort(array)`
Sorts array elements in ascending order.

```yaml
# GOOD: Validate sorted order
(sort(priorities)): [1, 2, 3, 4, 5]

# GOOD: Sort and compare
(sort(names) == sort(['alice', 'bob', 'charlie'])): true
```

#### `map(&expression, array)`
Applies an expression to each element of an array.

```yaml
# Extract specific field from array of objects
(map(&name, responses[*].target)): ['agent-1', 'agent-2']

# Transform array values
(map(&to_upper(@), names)): ['ALICE', 'BOB']
```

### String Functions

#### `upper(string)` / `lower(string)`
Converts string to uppercase or lowercase.

```yaml
# GOOD: Case-insensitive comparison
(lower(responses[0].content) == 'expected'): true

# GOOD: Validate uppercase
(upper(name)): 'AGENT-NAME'
```

#### `split(separator, string)`
Splits string into array by separator.

```yaml
# GOOD: Split and validate parts
(length(split(',', tags))): 3

# GOOD: Split and check first element
(split('/', path)[0]): 'expected'
```

#### `trim(string)`
Removes leading and trailing whitespace.

```yaml
# GOOD: Trim before comparison
(trim(responses[0].content)): 'expected content'
```

### Type Functions

#### `type(value)`
Returns the type of a value as a string.

```yaml
# GOOD: Validate field type
- assert:
    resource:
      status:
        (type(json_parse(responses[0].content).score) == 'number'): true
        (type(json_parse(responses[0].content).tags) == 'array'): true
        (type(json_parse(responses[0].content).summary) == 'string'): true
```

### Comparison Functions

#### Operators: `==`, `!=`, `<`, `<=`, `>`, `>=`

```yaml
# GOOD: Numeric comparison
(length(responses) > `0`): true
(priority >= `5`): true

# GOOD: String comparison
(status.phase == 'done'): true
(name != 'excluded'): true

# GOOD: Null check
(responses[0].content != null): true
```

## Kyverno-JSON Functions

### `json_parse(string)`
Parses a JSON string into an object.

```yaml
# GOOD: Parse and validate JSON response
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      status:
        (json_parse(responses[0].content).summary != null): true
        (json_parse(responses[0].content).score != null): true
        (type(json_parse(responses[0].content).score) == 'number'): true

# GOOD: Parse and extract nested field
(json_parse(config).database.host): 'localhost'
```

### `concat(array1, array2, ...)`
Concatenates multiple arrays.

```yaml
# GOOD: Combine arrays
(concat(agents, teams)): [...all items...]

# GOOD: Flatten nested arrays
(length(concat(responses[0].items, responses[1].items))): 10
```

### `wildcard(pattern, string)`
Matches string against wildcard pattern.

```yaml
# GOOD: Match pattern
(wildcard('agent-*', name)): true
(wildcard('test-*-prod', env)): true
```

## Kyverno Functions

### String Functions

#### `compare(string1, string2)`
Compares two strings lexicographically, returns -1, 0, or 1.

```yaml
# GOOD: Alphabetical comparison
(compare(name1, name2) < `0`): true
```

#### `regex_match(pattern, string)`
Tests if string matches regex pattern.

```yaml
# GOOD: Validate format
(regex_match('^agent-[0-9]+$', name)): true
(regex_match('\\d{3}-\\d{3}-\\d{4}', phone)): true
```

### Math Functions

#### `add(number1, number2)`, `divide(number1, number2)`, `round(number)`, `to_number(value)`

```yaml
# GOOD: Arithmetic operations
(add(count1, count2) > `10`): true
(divide(total, count) >= `5.0`): true
(round(average)): 7

# GOOD: Convert string to number
(to_number(stringValue) > `100`): true

# GOOD: Validate arithmetic with conversion
(tokenUsage.promptTokens + tokenUsage.completionTokens == to_number(tokenUsage.totalTokens)): true
```

### Encoding Functions

#### `base64_encode(string)`, `base64_decode(string)`

```yaml
# GOOD: Encode secret value (in script outputs)
outputs:
  - name: encoded
    value: (base64_encode($stdout))

# GOOD: Decode and validate
(base64_decode(secret)): 'expected-value'
```

### Time Functions

#### `time_now()`, `time_parse(layout, value)`

```yaml
# GOOD: Current timestamp
(time_now()): '2025-01-15T...'

# GOOD: Parse and validate time
(time_parse('2006-01-02', date)): <parsed time>
```

## Chainsaw Functions

### Environment Functions

#### `env(variable_name)`
Accesses environment variables.

```yaml
# GOOD: Use environment variable
outputs:
  - name: api_key
    value: (env('API_KEY'))
```

### Kubernetes Functions (Experimental)

These functions are prefixed with `x_` and subject to change.

#### `x_k8s_get(apiVersion, kind, namespace, name)`
Retrieves a specific Kubernetes resource.

```yaml
# Get specific resource
(x_k8s_get('v1', 'Pod', 'default', 'my-pod'))
```

#### `x_k8s_list(apiVersion, kind, namespace, labels)`
Lists Kubernetes resources matching criteria.

```yaml
# List resources with labels
(x_k8s_list('v1', 'Pod', 'default', {'app': 'nginx'}))
```

#### `x_k8s_exists(apiVersion, kind, namespace, name)`
Checks if a resource exists.

```yaml
# GOOD: Validate resource existence
(x_k8s_exists('ark.mckinsey.com/v1alpha1', 'Agent', 'default', 'test-agent')): true
```

#### `x_k8s_server_version()`
Returns Kubernetes server version.

```yaml
# Check cluster version
(x_k8s_server_version().major): '1'
```

## Common Assertion Patterns

### Validate Response Count

```yaml
# Exact count
(length(responses)): 1

# Minimum count
(length(responses) > `0`): true
(length(responses) >= `2`): true
```

### Validate Agent Responded

```yaml
# Agent present
(contains(responses[*].target.name, 'agent-name')): true

# Agent absent
(contains(responses[*].target.name, 'excluded-agent')): false

# Multiple agents
(contains(responses[*].target.name, 'agent-1')): true
(contains(responses[*].target.name, 'agent-2')): true
```

### Validate Response Content

```yaml
# Content not empty
(length(join('', responses[*].content)) > `10`): true

# Content contains text
(contains(join(' ', responses[*].content), 'expected text')): true

# Specific response content
(contains(responses[0].content, 'weather')): true
```

### Validate Structured JSON Output

```yaml
# Parse and validate structure
(json_parse(responses[0].content).summary != null): true
(json_parse(responses[0].content).score != null): true

# Validate types
(type(json_parse(responses[0].content).summary) == 'string'): true
(type(json_parse(responses[0].content).score) == 'number'): true
(type(json_parse(responses[0].content).tags) == 'array'): true

# Validate array length
(length(json_parse(responses[0].content).tags) > `0`): true

# Validate nested fields
(json_parse(responses[0].content).metadata.version): '1.0'
```

### Validate Status Phase

```yaml
# Query completion
status:
  phase: done

# Model ready
status:
  phase: ready

# Error state
status:
  phase: error
```

### Validate Conditions

```yaml
# Check condition exists
(length(conditions) > `0`): true

# Validate specific condition
(contains(conditions[*].type, 'Ready')): true
(contains(conditions[*].status, 'True')): true
```

### Complex Validations

```yaml
# Combine multiple assertions
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      status:
        phase: done
        (length(responses)): 2
        (contains(responses[*].target.name, 'agent-1')): true
        (contains(responses[*].target.name, 'agent-2')): true
        (length(join('', responses[*].content)) > `50`): true
        (json_parse(responses[0].content).field != null): true
```

## Tips and Best Practices

### Use Backticks for Numbers
When comparing against numeric literals, use backticks:
```yaml
# GOOD
(length(responses) > `0`): true
(priority >= `5`): true

# BAD - treats as string
(length(responses) > 0): true
```

### Null Checks
Check for null explicitly:
```yaml
# GOOD: Explicit null check
(field != null): true
(field == null): true

# GOOD: Existence check
(json_parse(response).field != null): true
```

### Array Projections
Use `[*]` for projecting arrays:
```yaml
# GOOD: Project all target names
(contains(responses[*].target.name, 'agent')): true

# GOOD: Project and join
(join(',', responses[*].target.name)): 'agent-1,agent-2'
```

### Parentheses for Expressions
Wrap JP expressions in parentheses in YAML:
```yaml
# GOOD: Expression in parentheses
(length(responses)): 1

# BAD: Plain key (treated as string match)
length(responses): 1
```

### Type Validation
Always validate types for structured output:
```yaml
# GOOD: Type validation
(type(json_parse(response).count) == 'number'): true
(type(json_parse(response).name) == 'string'): true
(type(json_parse(response).items) == 'array'): true
```
