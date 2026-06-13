# Genre analyze — 一键论文诊断脚本
# 用法：.\analyze.ps1 -Input <paper.docx|text.txt> -ProjectPath <GenreWriter-path> [-Mode <subcommand>]
# Mode: analyze (default), classify, structure, diagnose, references, variable-plan
#
# 依赖：Angri450.Nong.Docx + Angri450.Nong.Genre

param([string]$Input, [string]$ProjectPath, [string]$Mode = "analyze")

[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8

if (-not $Input) { Write-Output "Usage: analyze.ps1 -Input <paper.docx|text.txt> -ProjectPath <GenreWriter-path> [-Mode <subcommand>]"; exit 1 }
if (-not (Test-Path $Input)) { Write-Output "ERROR: file not found: $Input"; exit 1 }
if (-not $ProjectPath -or -not (Test-Path $ProjectPath)) {
    Write-Output "ERROR: ProjectPath is required and must exist. Pass the GenreWriter project directory."
    exit 1
}

# Check Program.cs for subcommand routing
$programCs = Join-Path $ProjectPath "Program.cs"
if (-not (Test-Path $programCs)) {
    Write-Output "ERROR: Program.cs not found at $programCs"
    exit 1
}
$programContent = Get-Content $programCs -Raw
if ($programContent -notmatch 'args\[0\]') {
    Write-Output "ERROR: Program.cs 不包含 subcommand 路由。请使用 workspace-setup.md 的模板 Program.cs 重新生成。"
    exit 1
}

$validModes = @("analyze", "classify", "structure", "diagnose", "references", "variable-plan")
if ($Mode -notin $validModes) {
    Write-Output "ERROR: Invalid mode '$Mode'. Valid modes: $($validModes -join ', ')"
    exit 1
}

Write-Output "=== Genre $Mode : $Input ==="

try {
    $output = dotnet run --project $ProjectPath -- $Mode "$Input" 2>&1
    Write-Output $output
} catch {
    Write-Output "ERROR: dotnet run failed. Check that GenreWriter project builds correctly."
    exit 1
}
