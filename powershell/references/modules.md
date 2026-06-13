# Modules & Testing

## Module Structure

```
MyModule/
  MyModule.psd1      # module manifest
  MyModule.psm1      # root module
  Public/            # exported functions
  Private/           # internal functions
  tests/             # Pester tests
```

## Module Manifest Best Practices

- Always include a `.psd1` manifest (PowerShell Gallery requires it).
- Do **not** use wildcards in `AliasesToExport`, `CmdletsToExport`, `FunctionsToExport` — explicit lists improve performance.
- Use `New-ModuleManifest` as a starting point.

## Loading Patterns

```powershell
# Explicitly import with version requirement
Import-Module MyModule -MinimumVersion 2.0 -ErrorAction Stop

# Check if module is available before importing
if (-not (Get-Module -ListAvailable -Name MyModule)) {
    Install-Module MyModule -Scope CurrentUser -Force
}
```

## Testing

- Include **Pester** tests in `tests/` and run them in CI.
- Use **PSScriptAnalyzer** to enforce style rules:
  - `UseApprovedVerbs` — validate verb-noun naming
  - `PSUseShouldProcessForStateChangingFunctions` — enforce WhatIf support
  - `PSAvoidUsingWriteHost` — warn on `Write-Host` misuse

## Dependency / Prerequisite Checks

```powershell
function Assert-Command {
    param([string[]]$Commands)
    foreach ($cmd in $Commands) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            throw "Required command not found: $cmd"
        }
    }
}
Assert-Command git, dotnet, az
```
