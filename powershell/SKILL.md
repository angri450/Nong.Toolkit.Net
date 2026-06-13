---
name: powershell
description: >
  PowerShell 7+ scripting reference. Trigger on .ps1, .psm1, .psd1 files, debugging
  PowerShell errors, shell automation, CI/CD pipelines, or credential security.
  testing. Only PS 7+ — no 5.1 legacy.
---

# PowerShell Scripting Skill

## Quick Reference

| Need | Pattern |
|------|---------|
| Script header | `#Requires -Version 7.0` + `Set-StrictMode -Version Latest` + `$ErrorActionPreference = 'Stop'` |
| Pipeline data output | `Write-Output` (never `Write-Host` for data the caller may consume) |
| User-facing status | `Write-Host` or `Write-Information` |
| State-changing function | `[CmdletBinding(SupportsShouldProcess)]` + `$PSCmdlet.ShouldProcess()` |
| Native command errors | `$ErrorActionPreference = 'Stop'` → throws automatically |
| Secrets / credentials | `SecretManagement` + `SecretStore` or env vars — never hardcode; avoid `SecureString` |
| Path construction | `Join-Path` — never string concatenation |
| Wildcard-safe paths | `-LiteralPath` instead of `-Path` |
| Platform detection | `$IsWindows` / `$IsLinux` / `$IsMacOS` |
| Parallel processing | `ForEach-Object -Parallel` |
| Null-conditional | `??` and `?.` operators |
| Module import | `Import-Module -MinimumVersion X.Y -ErrorAction Stop` |
| Verb-noun naming | Use approved verbs from `Get-Verb`; run PSScriptAnalyzer `UseApprovedVerbs` |
| Comment-based help | Required for public functions/scripts: `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE` |

## Scope

**PowerShell 7+ only.** No 5.1 support.

## Environment & Execution

- **Windows**: `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File ./script.ps1`
- **WSL**: `pwsh.exe ...` (same flags), use `wslpath -w` for path conversion
- **Linux / macOS**: `pwsh` (same flags)

`-ExecutionPolicy Bypass` is acceptable in dev/CI. In production, prefer `RemoteSigned` or signing.
ExecutionPolicy is **Windows-only** — on Linux/macOS it is effectively `Unrestricted`.

## Script Header

```powershell
#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
```

Plus comment-based help for every public script/function:

```powershell
<#
.SYNOPSIS
    Short description.
.DESCRIPTION
    More detailed description.
.PARAMETER Param1
    Explanation of Param1.
.EXAMPLE
    .\script.ps1 -Param1 value
.NOTES
    Author  : Your Name
    Version : 1.0.0
#>
```

## Cmdlet / Function Conventions

```powershell
function Invoke-Deployment {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TargetPath,
        [Parameter()]
        [ValidateSet('dev','staging','prod')]
        [string]$Environment = 'dev',
        [switch]$Force
    )
    process {
        if ($PSCmdlet.ShouldProcess($TargetPath, "Deploy to $Environment")) {
            # actual work
        }
    }
}
```

- Verb-Noun naming using [approved verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands).
- Always add `[CmdletBinding()]` when the function needs `-Verbose`/`-WhatIf` or pipeline input.
- Use `[Parameter(Mandatory)]` over manual `if (-not $Param)` checks.
- Add `[ValidateSet]`, `[ValidateNotNullOrEmpty]`, `[ValidateRange]` where applicable.

## Dry-Run (WhatIf)

```powershell
function Remove-OldFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Path)
    Get-ChildItem $Path | ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.FullName, 'Remove')) {
            Remove-Item $_.FullName -Force
        }
    }
}
```

Always add `SupportsShouldProcess` on functions that modify state.

## Security Checklist

- [ ] No hardcoded credentials, tokens, or connection strings.
- [ ] All user input validated via `[ValidateSet]`, `[ValidateRange]`, or explicit guards.
- [ ] No `Invoke-Expression` with untrusted input.
- [ ] `SupportsShouldProcess` on any function that modifies state.
- [ ] Secrets from environment variables, `SecretManagement` vaults, or credential stores — not literals.
- [ ] `SecureString` avoided for new development.
- [ ] Scripts pass PSScriptAnalyzer default rules with no warnings.

## Behavioral Conventions

- Always save `.ps1` files as **UTF-8 with BOM**. Always specify `-Encoding UTF8` for file I/O.
- Run `[CmdletBinding()]` functions with `-WhatIf` first to preview changes.
- Prefer `-LiteralPath` over `-Path` when paths may contain wildcard characters.
- Keep scripts idempotent — re-running should be safe.
- Include comment-based help for all public functions and scripts.
- Use `Get-Verb` and PSScriptAnalyzer `UseApprovedVerbs` to validate verb naming.
- Include Pester tests when publishing modules.

## Reference Index

| Topic | File | Read when |
|-------|------|-----------|
| File encoding (UTF-8, BOM, 中文乱码) | [`references/file-encoding.md`](references/file-encoding.md) | Chinese/non-ASCII characters appear garbled; setting up encoding defaults |
| Error handling (try/catch, retry, logging) | [`references/error-handling.md`](references/error-handling.md) | Need retry logic, logging patterns, or error propagation rules |
| Modules & testing (psd1, Pester, PSScriptAnalyzer) | [`references/modules.md`](references/modules.md) | Building a module, setting up tests, or running PSScriptAnalyzer |
| Output & pipeline patterns | [`references/output-pipeline.md`](references/output-pipeline.md) | Choosing Write-Output vs Write-Host, building pipelines, parallel processing |
| Credential & secret handling | [`references/credentials.md`](references/credentials.md) | Handling tokens, API keys, or credentials securely |
| Path handling & Join-Path | [`references/path-handling.md`](references/path-handling.md) | Building cross-platform paths, dealing with wildcard characters |
