# MSBuild / Build

Build failure diagnosis, binlog analysis, performance optimization, and code quality.

## Build Failure Diagnosis

### Step 1: Generate a binlog (if not already)
```bash
dotnet build /bl:build.binlog
```

### Step 2: Replay binlog to searchable text
```bash
dotnet msbuild build.binlog -noconlog \
  -fl  -flp:v=diag;logfile=full.log;performancesummary \
  -fl1 -flp1:errorsonly;logfile=errors.log \
  -fl2 -flp2:warningsonly;logfile=warnings.log
```
> PowerShell: quote semicolons: `-flp:"v=diag;logfile=full.log;performancesummary"`

### Step 3: Search for errors
```bash
cat errors.log                                      # All errors
grep -n "CS0246" full.log                          # Type-not-found errors
grep "done building project\|Building with" full.log  # Build order
```

### Step 4: Detect cascading failures
Projects that never reached `CoreCompile` failed because a dependency failed:
```bash
grep 'Target "CoreCompile"' full.log | grep -oP 'project "[^"]*"'
grep "project.*FAILED" full.log
```

### Common error patterns
| Error | Cause | Fix |
|-------|-------|-----|
| CS0246 / type not found | Missing PackageReference | Add package in `.csproj` |
| MSB4019 / imported project not found | SDK install or global.json issue | Check SDK version |
| NU1605 / package downgrade | Version conflict | Update package versions |
| MSB3277 / version conflicts | Binding redirect issue | Align versions |
| ResolveProjectReferences failure | Cascading failure | Fix the failing dependency first |

### Preprocess (inline all imports)
```bash
dotnet msbuild -pp:preprocessed.xml MyProject.csproj
```

## Build Performance

### Perf investigation from binlog
```bash
tail -100 full.log                                    # Target/task timing summary
grep "Target Performance Summary\|Task Performance Summary" -A 50 full.log
```

### Key performance patterns

| Tool | Purpose |
|------|---------|
| `dotnet build -bl` | Generate binlog for analysis |
| `dotnet msbuild -noconlog -flp:v=diag;logfile=diag.log;performancesummary` | Detailed timing |
| `dotnet build -m` | Multi-process build (default on most machines) |

### Common perf issues
- **Over-including generated files**: Use `EnableDefaultCompileItems` + `Remove` for generated code
- **Missing incremental build support**: Ensure `Inputs`/`Outputs` on all `Target`s
- **Bin/Obj clash**: Check `BaseOutputPath` and `BaseIntermediateOutputPath` consistency
- **Parallelism disabled**: Check `/m:1` or `BuildInParallel=false`

### Build server
```bash
# Start the server (auto-starts with first dotnet command on .NET 9+)
dotnet build-server shutdown   # Force shutdown
```

## Project Organization

### Directory.Build.props pattern
```xml
<Project>
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
```

### Project reference resolution
```bash
# List all project references
grep -n "ProjectReference" **/*.csproj
# Check for missing or circular references
dotnet list package --include-transitive
```

## MSBuild Modernization

- Replace `$(MSBuildProjectDirectory)` with `$(MSBuildThisFileDirectory)` in imported files
- Use SDK-style projects everywhere
- Replace `packages.config` with `<PackageReference>`
- Use `Directory.Build.props` for shared properties
- Enable `ManagePackageVersionsCentrally` for CPM

## Validation
- [ ] Binlog replayed and searched
- [ ] Root cause identified (not just first visible error)
- [ ] Cascading failures distinguished from direct failures
- [ ] Build completes without errors after fix
