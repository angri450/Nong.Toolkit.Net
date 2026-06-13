# .NET Version Upgrades

Migrate .NET projects between framework versions, enable nullable references, AOT compatibility, and thread-abort migration.

## Version Migration Workflow

### Step 1: Check current state

```bash
dotnet --version                       # Current SDK
grep -r "TargetFramework" **/*.csproj  # Current TFMs
dotnet list package --outdated         # Outdated packages
```

### Step 2: Update target framework

```xml
<!-- Before -->
<TargetFramework>net9.0</TargetFramework>

<!-- After -->
<TargetFramework>net10.0</TargetFramework>
```

For multi-targeting:
```xml
<TargetFrameworks>net10.0;net9.0</TargetFrameworks>
```

### Step 3: Update packages

```bash
# Check for newer versions
dotnet list package --outdated

# Update specific package
dotnet add package <PACKAGE> --version <VERSION>

# Update all (review each manually)
dotnet outdated --upgrade
```

### Step 4: Build and fix

```bash
dotnet build
# Fix any warnings or errors from API changes
```

### Step 5: Test

```bash
dotnet test
```

## Common Migration Paths

| From | To | Key changes |
|------|----|-------------|
| .NET 8 | .NET 9 | SDK projects, newer C# |
| .NET 9 | .NET 10 | File-based apps, MTP default |
| .NET 10 | .NET 11 | System.Text.Json enhancements, new APIs |

## Nullable References Migration

### Enable nullable

```xml
<PropertyGroup>
  <Nullable>enable</Nullable>
</PropertyGroup>
```

### Incremental approach

1. Enable at project level
2. Start with `#nullable disable` in files with many warnings
3. Fix warnings file-by-file, removing `#nullable disable`
4. Treat warnings as errors when possible

### Common patterns to fix

```csharp
// Before
public string GetName() { return _name; }

// After
public string? GetName() { return _name; }  // or ensure non-null

// Null-forgiving operator (use sparingly)
var length = name!.Length;
```

## AOT Compatibility

Check for patterns incompatible with Native AOT:

```bash
# Find dynamic code
grep -rn "MakeGenericType\|MakeGenericMethod\|Emit\|Assembly.Load" .
```

Common AOT blockers:
- Reflection.Emit
- Assembly.Load/LoadFrom
- MakeGenericType/MakeGenericMethod with runtime types
- Dynamic type creation
- `Type.GetType("...")` with non-literal strings

```xml
<!-- Enable AOT compatibility analysis -->
<PropertyGroup>
  <IsAotCompatible>true</IsAotCompatible>
</PropertyGroup>
```

## Thread.Abort Migration

`Thread.Abort` is obsolete in modern .NET. Replace with:

```csharp
// Before
thread.Abort();

// After — cooperative cancellation
var cts = new CancellationTokenSource();
var token = cts.Token;

// In the thread method, periodically check:
token.ThrowIfCancellationRequested();

// To stop:
cts.Cancel();
```

## Validation
- [ ] `dotnet build` succeeds with no errors
- [ ] `dotnet test` passes
- [ ] No obsolete API warnings
- [ ] Nullable warnings resolved or suppressed intentionally
- [ ] AOT analysis shows no blockers (if targeting AOT)
