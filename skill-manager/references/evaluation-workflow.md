# Evaluation Workflow

## Overview

1. Spawn parallel with-skill and baseline runs
2. While runs progress, draft assertions
3. As runs complete, capture timing data
4. Grade, aggregate, and launch viewer
5. Read user feedback
6. Improve skill based on feedback

## Step 1: Spawn All Runs

For each test case, spawn two subagents simultaneously — one with the skill, one without (or with old version).

### With-Skill Run Prompt
```
Execute this task:
- Skill path: <path>
- Task: <eval prompt>
- Input files: <files or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- Outputs to save: <what to save>
```

### Baseline Run
- **Creating new skill**: Same prompt, no skill at all, save to `without_skill/outputs/`.
- **Improving existing skill**: Snapshot old version (`cp -r <skill> <workspace>/skill-snapshot/`), use as baseline, save to `old_skill/outputs/`.

Write `eval_metadata.json` for each test case:
```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

## Step 2: Draft Assertions

While runs are in progress, draft quantitative assertions. Good assertions are objectively verifiable with descriptive names. Subjective skills are better evaluated qualitatively.

Update `eval_metadata.json` and `evals/evals.json` with assertions.

## Step 3: Capture Timing Data

When subagent tasks complete, notifications include `total_tokens` and `duration_ms`. Save immediately to `timing.json`:
```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

## Step 4: Grade, Aggregate, Launch Viewer

1. **Grade**: Spawn grader subagent (see `agents/grader.md`). Save to `grading.json`.
2. **Review**: `dotnet run --project tools/SkillManager.Cli -- eval serve`

## Step 5: Read Feedback

After user clicks "Submit All Reviews", read `feedback.json`:
```json
{
  "reviews": [
    {"run_id": "eval-0-with_skill", "feedback": "chart is missing axis labels", "timestamp": "..."}
  ],
  "status": "complete"
}
```

Empty feedback means the user was satisfied. Focus improvements on cases with specific complaints.

## Schema Reference

See `references/schemas.md` for complete JSON schemas for grading.json, metrics.json, timing.json, benchmark.json, and comparison.json.

## Blind Comparison Protocol

All A/B comparisons must be truly blind. The comparator must not know which output is the skill version vs. baseline.

### Anonymization Rules

1. **Output artifacts are copied to anonymous names**: `artifact-A/`, `artifact-B/` (not `with_skill/`, `without_skill/`).
2. **All metadata files are stripped of identity fields**: Remove `skill_name`, `version`, `configuration`, and path references that reveal which is which.
3. **Comparator prompt uses only anonymous labels**: "Compare artifact A and artifact B" — never "Compare with_skill and without_skill."
4. **Grader receives only the artifact path, expectation text, and output files** — no skill version context.

### Identity Leakage Checklist

Before submitting to comparator, verify:

- [ ] No directory named `with_skill/`, `without_skill/`, `old_skill/`, `new_skill/`, `baseline/`, `candidate/`
- [ ] No filename containing `with-skill`, `without-skill`, `baseline`, `candidate`
- [ ] No metadata JSON with `skill_path`, `skill_version`, `configuration` fields
- [ ] No prompt text mentioning which version produced which output
- [ ] No timestamp patterns that reveal execution order (if old always before new)
- [ ] No error messages referencing specific skill versions
- [ ] No file creation dates visible to comparator

### Eval Invalid Conditions

An eval is marked INVALID (blind: false) if:

- Identity leakage is detected by the comparator itself
- Identity leakage is found in pre-submission audit
- The two artifacts cannot be anonymized (e.g., output contains embedded skill name)
- The comparator reports it could infer which was which from output content

### Comparator Output

Every comparison result must include:
```json
{
  "blind": true,
  "identity_leakage_detected": false,
  "winner": "A",
  ...
}
```

If `blind: false`, the `identity_leakage_detected` must explain exactly which field leaked.
