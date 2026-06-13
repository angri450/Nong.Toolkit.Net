---
name: ilspycmd
description: >
  Decompile .NET assemblies to C# source. Trigger on inspect DLL, recover source code,
  decompile EXE, extract API surface, or understand third-party library internals.
---

# ilspycmd

.NET assembly decompiler. Converts compiled DLL/EXE back to readable C# source.

## Prerequisites

```bash
dotnet tool install --global ilspycmd
```

## Quick Reference

| Task | Command |
|------|---------|
| Decompile to directory | `ilspycmd <assembly.dll> -o <output-dir>` |
| Decompile single file | `ilspycmd <assembly.dll> -o <output-dir> -p` |
| Show types only | `ilspycmd <assembly.dll> -l` |
| Decompile with deps | Copy all dependency DLLs to same folder first |

## Common Patterns

**Extract API surface from a NuGet package:**

```bash
# 1. Download nupkg from NuGet.org
dotnet nuget push does not apply. Use:
# https://www.nuget.org/api/v2/package/<id>/<version>

# 2. Extract the nupkg (it's a zip)
unzip <package>.nupkg -d <dir>

# 3. Find the DLL in lib/netX.Y/

# 4. Decompile
ilspycmd <dir>/lib/net8.0/<assembly>.dll -o <output> -p
```

**If ilspycmd fails with runtime version error:**

The tool requires the exact .NET runtime it was built for. Install the missing runtime from https://dotnet.microsoft.com/download.

## Limitations

- Decompiled code approximates original source. Variable names, comments, and formatting are lost.
- Obfuscated assemblies produce garbled output.
- Native AOT assemblies cannot be decompiled.

See [`references/decompilation-guide.md`](references/decompilation-guide.md) for detailed workflows.
