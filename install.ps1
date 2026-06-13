param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'GroundPA-Toolkit'),
    [string]$ArchiveUrl = 'https://gitee.com/angri450/GroundPA-Toolkit/repository/archive/main.zip',
    [string]$ArchivePath = '',
    [ValidateSet('user', 'project', 'local')]
    [string]$Scope = 'user',
    [switch]$SkipClaudeInstall
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

function Write-Step {
    param([string]$Message)
    Write-Host "[GroundPA] $Message"
}

function Invoke-Checked {
    param(
        [string]$File,
        [string[]]$Arguments
    )

    & $File @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $File $($Arguments -join ' ')"
    }
}

function Test-GroundPaRoot {
    param([string]$Path)

    return (Test-Path -LiteralPath (Join-Path $Path '.claude-plugin\plugin.json')) -and
        (Test-Path -LiteralPath (Join-Path $Path '.claude-plugin\marketplace.json'))
}

$installFullPath = [System.IO.Path]::GetFullPath($InstallDir)
$installRoot = [System.IO.Path]::GetPathRoot($installFullPath)

if ([string]::IsNullOrWhiteSpace($installFullPath) -or $installFullPath.Length -lt 8) {
    throw "InstallDir is not safe: $InstallDir"
}

if ($installFullPath.TrimEnd('\') -eq $installRoot.TrimEnd('\')) {
    throw "InstallDir must not be a drive root: $installFullPath"
}

if ($env:USERPROFILE -and $installFullPath.TrimEnd('\') -eq ([System.IO.Path]::GetFullPath($env:USERPROFILE)).TrimEnd('\')) {
    throw "InstallDir must not be the user profile root: $installFullPath"
}

if ($env:LOCALAPPDATA -and $installFullPath.TrimEnd('\') -eq ([System.IO.Path]::GetFullPath($env:LOCALAPPDATA)).TrimEnd('\')) {
    throw "InstallDir must not be LOCALAPPDATA itself: $installFullPath"
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("groundpa-install-" + [System.Guid]::NewGuid().ToString('N'))
$zipPath = Join-Path $tempRoot 'GroundPA-Toolkit.zip'
$extractDir = Join-Path $tempRoot 'extract'

try {
    New-Item -ItemType Directory -Force -Path $tempRoot, $extractDir | Out-Null

    if ($ArchivePath) {
        $archiveFullPath = [System.IO.Path]::GetFullPath($ArchivePath)
        Write-Step "Using local archive: $archiveFullPath"
        Copy-Item -LiteralPath $archiveFullPath -Destination $zipPath -Force
    }
    else {
        Write-Step "Downloading from Gitee archive without Git clone"
        Invoke-WebRequest -Uri $ArchiveUrl -OutFile $zipPath -UseBasicParsing
    }

    Write-Step "Extracting archive"
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force

    $pluginManifest = Get-ChildItem -Path $extractDir -Recurse -Force -Filter 'plugin.json' |
        Where-Object { $_.FullName -match '\\\.claude-plugin\\plugin\.json$' } |
        Select-Object -First 1

    if (-not $pluginManifest) {
        throw "Downloaded archive does not contain .claude-plugin/plugin.json"
    }

    $sourceRoot = Split-Path -Parent (Split-Path -Parent $pluginManifest.FullName)
    if (-not (Test-GroundPaRoot -Path $sourceRoot)) {
        throw "Downloaded archive does not contain a valid GroundPA plugin root"
    }

    if (Test-Path -LiteralPath $installFullPath) {
        if (-not (Test-GroundPaRoot -Path $installFullPath)) {
            throw "Refusing to replace non-GroundPA directory: $installFullPath"
        }

        Write-Step "Replacing existing local copy: $installFullPath"
        Remove-Item -LiteralPath $installFullPath -Recurse -Force
    }

    Write-Step "Installing local copy: $installFullPath"
    New-Item -ItemType Directory -Force -Path $installFullPath | Out-Null
    Get-ChildItem -LiteralPath $sourceRoot -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $installFullPath -Recurse -Force
    }

    if ($SkipClaudeInstall) {
        Write-Step "Skipped Claude plugin registration by request"
        Write-Step "Local plugin root: $installFullPath"
        return
    }

    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        throw "Claude Code CLI was not found. Install Claude Code first, then rerun this script."
    }

    Write-Step "Validating plugin manifest"
    Invoke-Checked -File 'claude' -Arguments @('plugin', 'validate', $installFullPath)

    Write-Step "Refreshing marketplace registration"
    & claude plugin marketplace remove angri450 2>$null | Out-Null

    Invoke-Checked -File 'claude' -Arguments @('plugin', 'marketplace', 'add', '--scope', $Scope, $installFullPath)

    Write-Step "Installing plugin"
    & claude plugin install --scope $Scope "groundpa-toolkit@angri450"
    if ($LASTEXITCODE -ne 0) {
        Write-Step "Install did not complete cleanly; trying plugin update"
        Invoke-Checked -File 'claude' -Arguments @('plugin', 'update', '--scope', $Scope, 'groundpa-toolkit@angri450')
    }

    Write-Step "Done. Restart Claude Code or run /reload-plugins inside Claude Code."
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
