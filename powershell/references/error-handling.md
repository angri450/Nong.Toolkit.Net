# Error Handling

## Terminating vs Non-Terminating

- **Terminating errors**: stop execution; can be caught by `try/catch`.
- **Non-terminating errors**: write to error stream, execution continues.
- `$ErrorActionPreference = 'Stop'` promotes non-terminating errors to terminating.

## try/catch/finally

```powershell
try {
    $result = Invoke-RestMethod -Uri $Uri -Method Get
}
catch [System.Net.WebException] {
    Write-Error "Network error: $_"
    exit 1
}
catch {
    Write-Error "Unexpected error: $_"
    exit 1
}
finally {
    # cleanup always runs
}
```

- `Write-Error` writes to the error stream (non-terminating, caller can choose to handle).
- `throw` produces a terminating error that bubbles up unless caught.

## Native Command Errors

With `$ErrorActionPreference = 'Stop'`, native command failures throw automatically:

```powershell
$ErrorActionPreference = 'Stop'
git status   # throws if git exits non-zero
```

## Retry Logic

```powershell
function Invoke-WithRetry {
    param(
        [ScriptBlock]$Action,
        [int]$Attempts = 3,
        [int]$DelaySeconds = 5
    )
    for ($i = 1; $i -le $Attempts; $i++) {
        try   { & $Action; return }
        catch {
            if ($i -ge $Attempts) { throw }
            Write-Warning "Attempt $i failed. Retrying in ${DelaySeconds}s..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}
```

## Logging

```powershell
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
```
