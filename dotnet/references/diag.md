# Performance Diagnostics

Scan .NET code for performance anti-patterns, debug crashes, analyze dumps, and run benchmarks.

## Code Performance Scanning

### Scan workflow

1. **Detect signals** in the code that indicate which pattern categories to check
2. **Run grep recipes** for each relevant category
3. **Classify findings** by severity
4. **Report compactly** — one block per finding

### Signal → Category mapping

| Signal | Category to check |
|--------|-------------------|
| `async`, `await`, `Task`, `ValueTask` | Async patterns |
| `Span<`, `Memory<`, `stackalloc`, `.Substring(`, `.Replace(`, `+=` in loops | Memory & strings |
| `Regex`, `[GeneratedRegex]`, `RegexOptions.Compiled` | Regex |
| `Dictionary<`, `List<`, `.ToList()`, `.Where(`, `.Select(` | Collections & LINQ |
| `JsonSerializer`, `HttpClient`, `Stream`, `FileStream` | I/O & serialization |

### Core scan recipes

```bash
# Strings & memory
grep -n '\.Substring(' FILE
grep -En '\.(StartsWith|EndsWith|Contains)\s*\(' FILE
grep -n '\.ToLower()\|\.ToUpper()' FILE
grep -n '\.Replace(' FILE
grep -n 'params ' FILE

# Collections & LINQ
grep -n '\.Select\|\.Where\|\.OrderBy\|\.GroupBy' FILE
grep -n 'new Dictionary<\|new List<' FILE
grep -n 'static readonly Dictionary<' FILE

# Regex
grep -n 'new Regex(' FILE
grep -n 'RegexOptions.Compiled' FILE
grep -n 'GeneratedRegex' FILE

# Structural
grep -n 'public class \|internal class ' FILE
grep -n 'sealed class' FILE
```

### Severity classification

| Severity | Criteria | Action |
|----------|----------|--------|
| 🔴 Critical | Deadlocks, crashes, >10x regression | Must fix |
| 🟡 Moderate | 2-10x improvement, hot-path best practice | Should fix on hot paths |
| ℹ️ Info | Pattern applies but may not be hot-path | Consider if profiling shows impact |

### Report format (compact)
```
#### ID. Title (N instances)
**Impact:** one-line statement
**Files:** file.cs:L1, file.cs:L2
**Fix:** one-line change description
```

Always include scale context: "N of M classes are sealed" — ratio matters.

### Key principles
- **Verify the inverse**: count both sides (sealed vs unsealed, compiled vs new Regex)
- **Compound allocation check**: cross-method chaining, branched `.Replace()` chains
- **Scale escalation**: 50+ instances → escalate severity
- **Hot path only**: don't flag LINQ/allocations outside hot paths
- **No unsafe code**: `Span<T>`, `stackalloc`, and `ArrayPool` cover most needs

## Crash Diagnostics

### Collecting dumps
```bash
# Linux: triggered by SIGABRT
dotnet-dump collect -p <PID>

# Windows: from Task Manager, or
procdump -ma <PID>

# Via environment variable
DOTNET_DbgEnableMiniDump=1 DOTNET_DbgMiniDumpType=4 dotnet run
```

### Analyzing dumps
```bash
dotnet-dump analyze dump.dmp
> clrstack           # Managed stack trace
> dumpstack          # Full native+managed stack
> pe -lines          # Exception info
> dumpheap -stat     # Heap summary by type
> gcroot <addr>      # What's keeping this alive
```

## Symbolication

### Apple crash reports
```bash
# Install symbolication tools
dotnet tool install -g dotnet-symbol

# Download symbols
dotnet-symbol --host-only --symbols <dll-or-dump>

# Symbolicate a crash report
# Use the symbols next to the dSYM to resolve addresses
```

### Android tombstone
```bash
# tombstone files are at /data/tombstones/
# Use ndk-stack or addr2line with debug symbols
```

## Microbenchmarking

```csharp
// Install: dotnet add package BenchmarkDotNet
[SimpleJob(RuntimeMoniker.Net90)]
[MemoryDiagnoser]
public class MyBenchmarks
{
    [Benchmark]
    public void Current() { /* ... */ }

    [Benchmark]
    public void Optimized() { /* ... */ }
}
```

```bash
dotnet run -c Release --filter "*MyBenchmarks*"
```

## Trace Collection

```bash
# Collect a trace
dotnet-trace collect -p <PID> --duration 00:00:30

# Analyze
dotnet-trace analyze trace.nettrace
```

## Validation
- [ ] All relevant scan recipes run and counted
- [ ] Findings classified by severity with exact counts
- [ ] Scale context provided (N of M)
- [ ] Disclaimer: AI-generated, verify with benchmarks
