# Output & Pipeline Patterns

## Output: The Right Cmdlet for the Job

| Scenario | Use | Avoid | Notes |
|---|---|---|---|
| Structured data for pipeline | `Write-Output` | `Write-Host` | Writes to success stream |
| User-facing progress/status | `Write-Host` or `Write-Information` | `Write-Output` | `Write-Host` is `Write-Information` wrapper since PS 5.0 |
| Debug info (hidden by default) | `Write-Debug` | `Write-Host` | |
| Non-fatal warnings | `Write-Warning` | `Write-Host` | |
| Verbose info | `Write-Verbose` | `Write-Host` | |
| Errors | `Write-Error` / `throw` | `Write-Host` | `Write-Error` → error stream |

Never use `Write-Host` for data the caller may need to consume — it bypasses the pipeline.

## Pipeline Patterns

```powershell
# Filter and transform
Get-ChildItem -Path $SourceDir -Filter '*.log' -Recurse |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Select-Object Name, LastWriteTime, @{N='SizeKB';E={[math]::Round($_.Length/1KB,1)}} |
    Sort-Object LastWriteTime |
    Export-Csv -Path old_logs.csv -NoTypeInformation

# Parallel
$items | ForEach-Object -Parallel {
    process_item $_
} -ThrottleLimit 4
```
