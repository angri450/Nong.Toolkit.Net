#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Cleans up files older than a specified number of days from a target directory.
    Demonstrates the PowerShell skill patterns: CmdletBinding/WhatIf, pipeline,
    logging, error handling, path safety, and prerequisite checks.
#>

<#
.SYNOPSIS
    Writes a timestamped log entry.

.DESCRIPTION
    Outputs messages to the appropriate stream based on log level.
    Supports INFO, WARN, ERROR, and DEBUG levels.

.PARAMETER Level
    Log level: INFO, WARN, ERROR, or DEBUG. Defaults to INFO.

.PARAMETER Message
    The message text to log.

.EXAMPLE
    Write-Log -Level 'INFO' -Message 'Processing started.'
#>
function Write-Log {
    param(
        [ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level = 'INFO',
        [string]$Message
    )
    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$ts] [$Level] $Message"
    switch ($Level) {
        'ERROR' { Write-Error $entry }
        'WARN'  { Write-Warning $entry }
        'DEBUG' { Write-Debug $entry }
        default { Write-Host $entry }
    }
}

<#
.SYNOPSIS
    Asserts that required commands are available on the system.

.DESCRIPTION
    Checks whether each specified command exists. Throws if any are missing.

.PARAMETER Commands
    Array of command names to verify.

.EXAMPLE
    Assert-Command git, dotnet, az
#>
function Assert-Command {
    param([string[]]$Commands)
    foreach ($cmd in $Commands) {
        if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
            throw "Required command not found: $cmd"
        }
    }
}

<#
.SYNOPSIS
    Removes files older than a specified number of days from a directory.

.DESCRIPTION
    Recursively scans a target directory and deletes files whose LastWriteTime
    exceeds the cutoff. Supports WhatIf dry-run and configurable logging.

.PARAMETER TargetPath
    Path to the target directory (supports wildcard-free -LiteralPath internally).

.PARAMETER OlderThanDays
    Age threshold in days. Files older than this are candidates for removal. Default: 30.

.PARAMETER Filter
    File name filter, e.g. '*.log'. Default: '*' (all files).

.PARAMETER LogLevel
    Logging verbosity: INFO, WARN, ERROR, or DEBUG. Default: INFO.

.EXAMPLE
    Remove-OldFiles -TargetPath C:\Logs -OlderThanDays 60 -WhatIf

.EXAMPLE
    Remove-OldFiles -TargetPath C:\Logs -OlderThanDays 30 -Filter '*.tmp'
#>
function Remove-OldFiles {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory)]
        [string]$TargetPath,

        [Parameter()]
        [ValidateRange(1, 3650)]
        [int]$OlderThanDays = 30,

        [Parameter()]
        [string]$Filter = '*',

        [Parameter()]
        [ValidateSet('INFO','WARN','ERROR','DEBUG')]
        [string]$LogLevel = 'INFO'
    )

    begin {
        # Resolve to absolute path
        $resolved = Resolve-Path -LiteralPath $TargetPath -ErrorAction Stop
        Write-Log -Level $LogLevel -Message "Target directory: $resolved"
        Write-Log -Level $LogLevel -Message "Removing files older than $OlderThanDays days (filter: '$Filter')"
    }

    process {
        $cutoff = (Get-Date).AddDays(-$OlderThanDays)
        $files = Get-ChildItem -LiteralPath $resolved -Filter $Filter -File -Recurse -ErrorAction Stop |
            Where-Object { $_.LastWriteTime -lt $cutoff }

        $totalCount = ($files | Measure-Object).Count
        Write-Log -Level $LogLevel -Message "Found $totalCount file(s) matching criteria"

        if ($totalCount -eq 0) {
            Write-Log -Level 'WARN' -Message 'No files to remove. Exiting.'
            return
        }

        $removed = 0
        $failed  = 0

        $files | ForEach-Object {
            $file = $_
            try {
                if ($PSCmdlet.ShouldProcess($file.FullName, 'Remove')) {
                    Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
                    $removed++
                    Write-Log -Level $LogLevel -Message "Removed: $($file.FullName)"
                }
            }
            catch {
                $failed++
                Write-Log -Level 'ERROR' -Message "Failed to remove '$($file.FullName)': $_"
            }
        }

        Write-Log -Level $LogLevel -Message "Done. Removed: $removed, Failed: $failed"
    }
}

# --- Driver ---
try {
    Write-Log -Level 'INFO' -Message '=== Old File Cleanup Utility ==='
    Write-Log -Level 'INFO' -Message "PowerShell $($PSVersionTable.PSVersion)"

    # Create a small test bed
    $testDir = Join-Path $env:TEMP 'ps-skill-demo'
    if (Test-Path -LiteralPath $testDir) {
        Remove-Item -LiteralPath $testDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null

    # Create some test files with old timestamps
    1..5 | ForEach-Object {
        $f = Join-Path $testDir "old_log_$_.txt"
        New-Item -ItemType File -Path $f -Force | Out-Null
        (Get-Item -LiteralPath $f).LastWriteTime = (Get-Date).AddDays(-60)
    }
    # And a fresh file that should survive
    $f = Join-Path $testDir 'recent.txt'
    New-Item -ItemType File -Path $f -Force | Out-Null

    Write-Log -Level 'INFO' -Message '--- Dry run (WhatIf) ---'
    Remove-OldFiles -TargetPath $testDir -OlderThanDays 30 -WhatIf

    Write-Log -Level 'INFO' -Message '--- Real run ---'
    Remove-OldFiles -TargetPath $testDir -OlderThanDays 30

    # Verify
    $remaining = Get-ChildItem -LiteralPath $testDir -File
    Write-Log -Level 'INFO' -Message "Files remaining after cleanup: $(@($remaining).Count)"
    foreach ($r in $remaining) {
        Write-Log -Level 'INFO' -Message "  -> $($r.Name) (modified: $($r.LastWriteTime))"
    }

    # Cleanup test dir
    Remove-Item -LiteralPath $testDir -Recurse -Force
    Write-Log -Level 'INFO' -Message 'Test directory cleaned up. Demo complete.'
}
catch {
    Write-Log -Level 'ERROR' -Message "Script failed: $_"
    exit 1
}
