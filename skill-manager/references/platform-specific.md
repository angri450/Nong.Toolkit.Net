# Platform-Specific Adaptations

## Claude Code (Desktop/CLI)

**Full capabilities available:**
- Subagents for parallel test execution
- Browser-based eval viewer (or `--static` HTML)
- Baseline comparisons (with_skill vs without_skill/old_skill)
- Blind comparison via `agents/comparator.md`
- Description optimization via `claude -p`
- Full .NET CLI toolchain

## Claude.ai (Web)

**Adaptations:**
- No subagents → run test cases sequentially, yourself
- Skip baseline runs — just use the skill to complete each task
- No browser viewer → present results inline in conversation
- Skip benchmarking — relies on baseline comparisons
- Skip description optimization — requires `claude -p` CLI
- Skip blind comparison — requires subagents
- Packaging works — `dotnet run --project tools/SkillManager.Cli -- package .`

### Updating Existing Skills on Claude.ai
- Copy to `/tmp/skill-name/` before editing (installed path may be read-only)
- Package from the copy
- Preserve the original skill name

## Cowork

**Adaptations:**
- Subagents available — main workflow works (parallel runs, baselines, grading)
- No browser/display → use `--static <output.html>` for viewer
- Feedback downloads as `feedback.json` file instead of server POST
- Packaging works — Python + filesystem
- Description optimization works — uses `claude -p` via subprocess

### Cowork-Specific Reminders
- Generate the eval viewer BEFORE evaluating inputs yourself — get results in front of the human ASAP
- Use `--static` mode for the viewer
- Read `feedback.json` after download (may require requesting file access)

## Windows-Specific Notes

- `/tmp/` paths do not exist — use `$env:TEMP` or `Path.GetTempPath()`
- `open` command doesn't exist — use `start` or `Invoke-Item`
- Path separators: .NET tools use `Path.Combine()` and `Path.DirectorySeparatorChar` (cross-platform)
- `chmod` doesn't exist on Windows — .NET `ZipFile` doesn't preserve Unix permissions anyway
- Shell scripts (`.sh`) need WSL or Git Bash — prefer `.ps1` for native Windows
