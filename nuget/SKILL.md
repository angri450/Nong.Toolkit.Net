---
name: nuget
description: >
  NuGet package management via dotnet CLI. Trigger on install package, update package,
  push nupkg, pack project, manage NuGet sources, or clear NuGet cache.
---

# NuGet

NuGet package management via `dotnet` CLI. A standalone `nuget.exe` is bundled for legacy `packages.config` projects.

## Quick Reference

| Task | Command |
|------|---------|
| Add package to project | `dotnet add <project> package <id>` |
| Add with version | `dotnet add <project> package <id> --version <v>` |
| Remove package | `dotnet remove <project> package <id>` |
| List packages | `dotnet list <project> package` |
| List outdated | `dotnet list <project> package --outdated` |
| Pack a project | `dotnet pack <project> -c Release` |
| Push to NuGet.org | `dotnet nuget push <nupkg> --api-key <key> --source https://api.nuget.org/v3/index.json` |
| Install global tool | `dotnet tool install --global <id>` |
| Update global tool | `dotnet tool update --global <id>` |
| List sources | `dotnet nuget list source` |
| Add source | `dotnet nuget add source <url> -n <name>` |
| Clear cache | `dotnet nuget locals all --clear` |
| Search NuGet | https://www.nuget.org/packages?q=&lt;query&gt; |

## Package Versioning

Use `Version="*"` in `.csproj` for consumption. Never pin. Receiver resolves latest. For publishing, use semantic versioning. Add `--version` flag only when specifically requested.

## Packaging a Project

See [`references/package-project.md`](references/package-project.md) for the full csproj template and conventions. Based on the `Angri450.Nong.Docx` reference implementation.

## Publishing Workflow

See [`references/publishing.md`](references/publishing.md) for the full step-by-step.

1. Update version in `.csproj`
2. `dotnet pack <project> -c Release`
3. `dotnet nuget push <nupkg> --api-key <key> --source https://api.nuget.org/v3/index.json`
