# Testing

Run, diagnose, migrate, and improve .NET tests across MSTest, xUnit, NUnit, and TUnit on VSTest and Microsoft.Testing.Platform (MTP).

## Quick Reference: Platform Detection

| Signal | Platform | SDK | Command pattern |
|--------|----------|-----|-----------------|
| `global.json` has `"test": { "runner": "Microsoft.Testing.Platform" }` | MTP | 10+ | `dotnet test --project <path> <args>` |
| `<TestingPlatformDotnetTestSupport>true` | MTP | 8/9 | `dotnet test <path> -- <args>` |
| Neither signal | VSTest | Any | `dotnet test <path> [--filter <expr>]` |

**Always check** (in order): `global.json` → `.csproj` → `Directory.Build.props` → `Directory.Packages.props`

## Critical Cross-Platform Rules

| Rule | Why |
|------|-----|
| **Do NOT use `--logger trx`** for MTP | MTP uses `--report-trx` |
| **Do NOT use `--report-trx`** for VSTest | VSTest uses `--logger trx` |
| **Do NOT use `--` separator** on SDK 10+ MTP | SDK 10+ passes args directly |
| **Do NOT omit `--`** on SDK 8/9 MTP | SDK 8/9 requires the separator |
| **Do NOT use `--filter "ClassName=..."`** with xUnit v3 on MTP | xUnit v3 uses `--filter-class` |
| **Do NOT use bare path** on SDK 10+ | Use `--project <path>` or `--solution <path>` |

## Running Tests

### VSTest
```bash
dotnet test [path] [--filter <EXPR>] [--logger trx] [--framework <TFM>]
```

### MTP on SDK 8/9
```bash
dotnet test [path] -- [--filter <EXPR>] [--report-trx] [--framework <TFM>]
```

### MTP on SDK 10+
```bash
dotnet test --project <path> [--report-trx] [--framework <TFM>]
```

## Filter Syntax

### VSTest `--filter`
```
FullyQualifiedName~MyTests        # Name contains
ClassName=MyTests                  # Exact class
TestCategory=Unit                  # Trait/category
FullyQualifiedName~MyTests&TestCategory=Nightly  # Combine
Name!~Integration                  # Exclude
```

### MSTest on MTP
```
--filter "FullyQualifiedName~MyTests"
--filter "TestCategory=Nightly"
```

### xUnit v3 on MTP
```
--filter-class MyTests              # Filter by class
--filter-method MyMethod            # Filter by method
--filter-trait Category=Unit       # Filter by trait
--filter-class MyTests --filter-trait Category=Unit  # Combine
```

## Test Migration

| From | To | Skill |
|------|----|-------|
| MSTest v1/v2 | MSTest v3 | Update NuGet packages, replace attributes |
| MSTest v3 | MSTest v4 | Minor attribute updates |
| VSTest | MTP | Set `<TestingPlatformDotnetTestSupport>true` and update runner config |
| xUnit | xUnit v3 | Update packages, replace attribute namespaces |
| Static dependencies | Testable wrappers | Create interfaces, inject via DI |

## Assertion Quality

### Good assertions
```csharp
Assert.That(result, Is.EqualTo(expected));              // Clear expected value
Assert.That(list, Has.Count.EqualTo(3));                 // Exact collection check
Assert.That(code, Throws.TypeOf<ArgumentException>());   // Exception type
```

### Bad assertions (avoid)
```csharp
Assert.IsNotNull(result);     // Too weak — doesn't verify content
Assert.IsTrue(list.Count > 0); // Doesn't say what count should be
Assert.That(code, Throws.Exception); // Too broad — catch specific types
```

## Coverage Analysis
```bash
# VSTest
dotnet test --collect "Code Coverage"

# MTP (requires Microsoft.Testing.Extensions.CodeCoverage)
dotnet test --coverage
```

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Tests not discovered | Check test adapter package is installed |
| Tests hang | Use `--blame-hang-timeout 5min` (VSTest) or `--blame-hang-timeout 5min` (MTP) |
| Mixed platform assumptions | Always detect platform before running commands |
| Flaky tests | Use `--filter` to isolate; check for shared state, time-dependence, ordering |
| Missing TRX output | VSTest: `--logger trx`; MTP: `--report-trx` with TrxReport extension |

## Validation
- [ ] Test platform detected (VSTest vs MTP)
- [ ] Correct command syntax used for SDK version
- [ ] All tests pass (or failures are understood)
- [ ] Framework-specific filter syntax used correctly
