# Lessons Learned — Development & Publishing Gold

All lessons extracted from real failures across the GroundPA Toolkit and Angri450.Nong builds.

## Versioning & Publishing

### 1. Claude reads `plugin.json`, NOT git tags
Claude Code reads `.claude-plugin/plugin.json` → `"version"` field. `skills.sh.json`, git tags, GitHub/Gitee Releases — none of these affect the displayed version. Version sync requires ALL of:

| File | Field | Who reads |
|------|-------|-----------|
| `.claude-plugin/plugin.json` | `"version"` + `"skills"` array | Claude |
| `skills.sh.json` | `"version"` + groups | Marketplace |
| `git tag -a vX.Y.Z` | tag name | Humans + CI |
| GitHub/Gitee Release | release notes | Humans |

### 2. `cp -r dir/*` skips hidden files
`*` in shell does NOT match `.`-prefixed files/directories. `.claude-plugin/` is hidden → `cp -r /tmp/groundpa/* ~/.claude/skills/` silently skips it → `plugin.json` never gets copied → version stuck at 1.0.0 forever. Fix: `cp -r /tmp/groundpa/. ~/.claude/skills/`

### 3. NuGet API key encryption is SDK-version-sensitive
.NET 11 preview SDK cannot decrypt keys stored by .NET 9 SDK in `NuGet.Config`. Workaround: clear the config and pass `--api-key` directly via CLI.

### 4. `robocopy` exit code 1 = success
Windows `robocopy` returns 1 when files were copied successfully (not an error). Do not treat as failure.

### 5. Gitee default branch is `main`, not `master`
When creating a new Gitee repo, the default branch is `main`. Push explicitly: `git push gitee master:main`.

## Source Inlining & Dependencies

### 6. Most library dependencies are 95% unused
ClosedXML (585 files): used ~13 types. DocumentFormat.OpenXml (456 files): 0 direct types used. ScottPlot (575 files): used ~6 types. Inline only the subset you actually call.

### 7. Source inlining eliminates NuGet dependency chains
Excel: 8 NuGet → 1 (System.IO.Packaging only). Chart: 18 NuGet → 7 (SkiaSharp/HarfBuzz native assets). Diagram: was JS ecosystem → pure .NET.

### 8. Native binaries cannot be inlined
SkiaSharp.NativeAssets.* and HarfBuzzSharp.NativeAssets.* contain pre-compiled C++ .dll/.so files. These MUST remain as NuGet packages. Only the C# P/Invoke binding layer (115 files) can be inlined.

### 9. ILRepack is broken on net11.0
Use manual DLL bundling via `BuildOutputInPackage` MSBuild target instead.

## Skill Design

### 21. User-level MCP config is `~/.claude.json`, not `~/.claude/mcp.json`
`mcp.json` (without leading dot) is project-level config only. `enabledMcpjsonServers` only affects project-level `.mcp.json`. The correct way to add a user-level MCP server is `claude mcp add --transport http <name> <url>`, which writes to `~/.claude.json` and triggers a connection check.

### 10. Description optimization: 20-25 words, front-loaded
Claude Code UI truncates at ~25 words. Front-load with highest-value trigger keywords. Remove "MUST use this skill when" boilerplate. AI handles semantic matching across languages — no need for Chinese keywords in the body.

### 11. SKILL.md is a kernel, not a tutorial
Progressive disclosure: SKILL.md = dispatch table + pointers. Details in `references/`. Never inline a tutorial into SKILL.md.

### 12. New skill registration checklist
- `.claude-plugin/plugin.json` → `"skills"` array + `"keywords"` + update description count
- `skills.sh.json` → appropriate group
- `README.zh-CN.md` → skills table
- Git tag + GitHub/Gitee Release

## Git & Multi-Platform

### 13. GitHub API inaccessible behind GFW
`gh auth` and `gh repo create` fail in mainland China. Use Gitee API via curl with `--oauth2-bearer` token for releases.

### 14. Never commit API keys
Pass via CLI arguments (`--api-key`, `--oauth2-bearer`) or environment variables. Clean up git remote URLs after token-based pushes: `git remote set-url gitee https://gitee.com/angri450/repo.git`

### 15. Force-push tags for release corrections
After fixing committed code, update the tag: `git tag -f -a vX.Y.Z -m "msg" && git push origin vX.Y.Z -f`

## NuGet & .NET

### 16. `dotnet pack` doesn't include ProjectReference DLLs
By default, `dotnet pack` only packages the top-level project's DLL. Use `<TargetsForTfmSpecificBuildOutput>` + `<BuildOutputInPackage>` to manually bundle dependency DLLs into the nupkg.

### 17. `Version="*"` in csproj resolves to latest stable
Per skill-manager convention, never pin package versions in skill `.csproj` files. Let the end user's SDK resolve.

### 18. Framework shims needed when moving from netstandard2.0 to net11.0
When inlining libraries targeting netstandard2.0, add polyfills for `IsExternalInit`, `MaybeNullWhenAttribute`, `HashCode` if the library uses C# 9+ features.

### 19. Strong naming removal
When inlining signed libraries, remove `InternalsVisibleTo` public keys and `AssemblyKeyFile` references. Use `[InternalsVisibleTo("AssemblyName")]` without the PK.

## Testing

### 20. SkiaSharp rendering tests fail without fonts
Use `SkiaCheck.IsAvailable()` to detect native library availability. Rendering tests return early instead of failing when fonts/unmanaged libs are missing. Core logic tests always pass.
