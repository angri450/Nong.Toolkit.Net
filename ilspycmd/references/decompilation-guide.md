# Decompilation Guide

## Full workflow: NuGet package to source code

```bash
# 1. Download nupkg
curl -L -o pkg.nupkg "https://www.nuget.org/api/v2/package/<id>/<version>"

# 2. Extract
unzip pkg.nupkg -d pkg-extracted

# 3. Find the target DLL
find pkg-extracted -name "*.dll" | grep -v resources

# 4. Copy all dependency DLLs alongside (ilspycmd needs them to resolve types)
cp pkg-extracted/**/*.dll ./deps/

# 5. Decompile
ilspycmd ./deps/<assembly>.dll -o ./source -p

# 6. Clean up
rm -rf pkg.nupkg pkg-extracted deps
```

## When ilspycmd can't resolve dependencies

If the DLL references types from assemblies that aren't in your runtime, use MetadataLoadContext as fallback:

```csharp
// Save as inspect.csx and run with dotnet-script or dotnet run
using System.Reflection;
using System.Runtime.InteropServices;

var files = Directory.GetFiles(RuntimeEnvironment.GetRuntimeDirectory(), "*.dll")
    .Concat(Directory.GetFiles(".", "*.dll")).Distinct();
var resolver = new PathAssemblyResolver(files);
using var mlc = new MetadataLoadContext(resolver, "System.Runtime");
var asm = mlc.LoadFromAssemblyPath(Path.GetFullPath("target.dll"));
foreach (var t in asm.GetExportedTypes()) Console.WriteLine(t.FullName);
```

Requires NuGet package: `System.Reflection.MetadataLoadContext`.

## ilspycmd vs alternatives

| Tool | Type | Best for |
|------|------|----------|
| ilspycmd | CLI | Automated extraction, CI pipelines |
| ILSpy | GUI | Interactive exploration |
| dnSpy | GUI + debugger | Runtime debugging + decompilation |
| dotPeek | GUI | Visual Studio integration |
