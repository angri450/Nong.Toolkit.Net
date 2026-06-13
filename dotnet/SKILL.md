---
name: dotnet
description: >
  Unified .NET development skill covering all major domains: core C# coding,
  MSBuild/build, testing, ASP.NET Core, EF Core/data, performance diagnostics,
  AI/ML integration, MAUI mobile, NuGet packages, template engine, version
  upgrades, and .NET 11 features. Use for ANY .NET-related task — coding,
  debugging, building, testing, upgrading, diagnosing, or scaffolding.
  This skill uses progressive disclosure: it loads only the domain-specific
  reference needed for the current task, keeping token usage low.
---

# .NET All-in-One

Covers the full .NET development lifecycle. The skill body is a **routing layer** — it identifies which domain your task belongs to and directs to the appropriate reference file. Only one reference is loaded per task.

## Domain Routing

| Domain | Reference | When to Load |
|--------|-----------|-------------|
| Core C# | `references/core.md` | C# scripts (file-based apps), P/Invoke, everyday coding |
| MSBuild / Build | `references/msbuild.md` | Build failures, binlog analysis, build perf, parallelism |
| Testing | `references/testing.md` | Running tests, test migration, assertion quality, coverage |
| ASP.NET Core | `references/aspnet.md` | OpenTelemetry, minimal APIs, middleware, endpoints |
| EF Core / Data | `references/data.md` | EF Core query optimization, N+1, tracking, compiled queries |
| Diagnostics | `references/diag.md` | Performance analysis, crash dumps, symbolication |
| AI / ML | `references/ai.md` | MCP in C#, LLM integration, technology selection, ML.NET |
| MAUI | `references/maui.md` | MAUI doctor, lifecycle, navigation, data binding, DI |
| NuGet | `references/nuget.md` | Package management, CPM migration |
| Templates | `references/templates.md` | Template discovery, instantiation, authoring |
| Upgrades | `references/upgrade.md` | .NET version migration, nullable migration, AOT |
| .NET 11 | `references/net11.md` | New .NET 11 APIs (System.Text.Json) |
| Experimental | `references/experimental.md` | Mock analysis, SIMD, test maintainability |

## Workflow

### Step 1: Identify the domain

Match the user's request against the routing table. Keyword triggers:
- "build", "binlog", "MSBuild", "csproj" → `references/msbuild.md`
- "test", "xUnit", "MSTest", "NUnit", "coverage" → `references/testing.md`
- "EF", "DbContext", "query slow", "N+1" → `references/data.md`
- "perf", "memory", "allocation", "crash dump" → `references/diag.md`
- "API", "controller", "middleware", "OpenTelemetry" → `references/aspnet.md`
- "MAUI", "mobile", "iOS", "Android" → `references/maui.md`
- "upgrade", "migrate", "AOT" → `references/upgrade.md`
- "MCP", "LLM", "AI", "ML.NET" → `references/ai.md`
- "template", "dotnet new", "scaffold" → `references/templates.md`
- "NuGet", "package", "CPM" → `references/nuget.md`
- ".NET 11", "System.Text.Json" → `references/net11.md`
- No match? Start with `references/core.md`

### Step 2: Load the reference

Read the relevant reference file. It contains domain-specific workflows, code, and gotchas.

### Step 3: Execute

Follow the reference's workflow with concrete commands and code.

### Step 4: Cross-reference

If two domains are needed, load both. Beyond two, decompose the task.

## General Principles

- **Run `dotnet --version` first** — respects `global.json` SDK pinning
- **Read project files before acting** — `.csproj`, `Directory.Build.props`, `Directory.Packages.props`
- **Prefer `dotnet` CLI** — deterministic and reviewable
- **Verify after every action** — check output, not just exit codes
- **.NET SDK 10+ is assumed** unless the project says otherwise

## Validation

- [ ] SDK version checked
- [ ] Project files inspected before changes
- [ ] `dotnet` commands completed without unexpected errors
- [ ] Modified files verified
