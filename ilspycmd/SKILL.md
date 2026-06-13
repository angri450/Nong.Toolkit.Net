---
name: ilspycmd
description: >
  Decompile .NET assemblies to C# source code. MUST use this skill when the user
  wants to inspect, decompile, or recover source code from a compiled .NET DLL or EXE;
  understand what a third-party library does internally; extract API surface from
  a NuGet package; or reverse-engineer a .NET binary. Also trigger when the user
  mentions ILSpy, ilspycmd, decompile, 反编译, 反解, DLL inspection, 查看DLL源码,
  or 提取源码 — even if they do not explicitly say "ilspycmd".
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
ilspycmd <dir>/lib/net11.0/<assembly>.dll -o <output> -p
```

**If ilspycmd fails with runtime version error:**

The tool requires the exact .NET runtime it was built for. Install the missing runtime from https://dotnet.microsoft.com/download.

## Limitations

- Decompiled code approximates original source. Variable names, comments, and formatting are lost.
- Obfuscated assemblies produce garbled output.
- Native AOT assemblies cannot be decompiled.

See [`references/decompilation-guide.md`](references/decompilation-guide.md) for detailed workflows.
