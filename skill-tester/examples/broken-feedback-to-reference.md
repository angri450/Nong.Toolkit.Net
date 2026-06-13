# Convert COM Automation Failure into Skill Boundaries

## What the user wants

Understand why a Word automation task failed and prevent it from happening again.

## What happened (failure)

A user asked to fix formatting in an old `.doc` contract. The AI escaped from `nong word` into PowerShell COM automation:

```powershell
$word = New-Object -ComObject Word.Application
$doc = $word.Documents.Open("contract.doc")
# ... 9 distinct COM failures ...
```

Failures included: `Marshal.GetActiveObject` not found, HRESULT errors on merged cells, file locks, `null` references, and `SaveAs` producing `.doc` instead of `.docx`.

## How it was fed back

1. **Captured** the failure in `log/debug/2026-06-05-word-com-automation-failure-report.md` with all 9 COM failure types listed.

2. **Analyzed** the pattern: The root cause was that the AI didn't know the boundary between COM and `nong word`.

3. **Added a reference**: Created a COM automation reference with explicit rules (later moved to Nong.Dev.Net `references/word-com-automation.md`):
   - No desktop Word COM automation for normal Word operations
   - COM is only an explicit escape hatch for operations `nong word` cannot do
   - For `.doc` files: `nong word check` → `nong word convert` → then full `nong word` pipeline

4. **Updated SKILL.md**: Added boundary text in the Word skill:
   ```
   Do not use desktop Word COM automation for normal tasks.
   For legacy .doc files, use nong word convert as the boundary step.
   ```

## Result

The Word skill now has a permanent boundary against COM escape. Future AI runs will see this rule before attempting COM automation.

## Key takeaways

- When a failure is reproducible and systematic, add a reference, not just a one-line boundary.
- Reference the actual debug log in the reference file so future readers can see the raw evidence.
- Update SKILL.md with a brief boundary line that links to the full reference.
