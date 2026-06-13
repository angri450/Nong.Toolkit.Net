---
name: skill-manager
description: Create, improve, and maintain skills. Trigger on create skill, edit skill, fix skill, merge skills, split skills, deprecate skill, run evals, benchmark, audit quality, or optimize descriptions.
---

# skill-manager

Meta-skill for creating, improving, and maintaining skills throughout their lifecycle.

## Prerequisites

```bash
dotnet tool install --global Angri450.Nong.Cli
nong commands --json
```

For GroundPA plugin validation, prefer `nong skill ...`. Legacy `skill-manager` commands are still useful for older eval/scaffold workflows, but they are not the primary packaging gate for this repository.

## Core Loop

```
Understand -> Draft -> Test -> Review -> Improve -> Repeat
```

At a high level:
1. Figure out what the skill should do
2. Draft or edit SKILL.md and resources
3. Run tests (task evals, trigger evals, baselines)
4. The user reviews outputs (qualitative + quantitative benchmark)
5. Improve based on feedback
6. Repeat until satisfied
7. Package and ship

## Mode Router

Before starting, determine which workflow applies:

### Create Skill
For creating new skills from scratch. Follow the Quickstart below.

### Improve Skill
For improving existing skills based on real usage data. Follow the Quickstart below.

### Maintenance & Lifecycle
For merge, split, deprecation, audit, or incident repair. See the lifecycle references:
- [`references/maintenance.md`](references/maintenance.md) — Incident repair, trigger debugging, regression prevention
- [`references/merge-split.md`](references/merge-split.md) — Merge criteria, split criteria, shared resources
- [`references/deprecation.md`](references/deprecation.md) — Deprecation notice template, safe removal conditions

## Quickstart: Create Skill

### Step 0: Prerequisites
Check [`references/prerequisites.md`](references/prerequisites.md). Only requirement: .NET SDK.

### Step 1: Capture Intent
Ask (via AskUserQuestion): What should the skill do? When should it trigger? What's the expected output? Should we set up automated test cases?

Classify as Objective (verifiable output), Subjective (writing/design), or Hybrid, and choose the testing strategy.

### Step 2: Prior Art Research
Search for existing tools, MCP servers, and APIs before building from scratch. See [`references/prior-art-research.md`](references/prior-art-research.md) for the 8-channel search table and Adopt/Extend/Build decision matrix.

### Step 3: Initialize
```bash
mkdir -p <skill-name>/{references,assets}
```

### Step 4: Edit
Write SKILL.md following [`references/skill-writing-guide.md`](references/skill-writing-guide.md). Create resource files (references/, assets/) as needed.

### Step 5: Write Test Cases
Save to `evals/evals.json`. 2-3 realistic prompts. Don't write assertions yet — draft those while runs are in progress. Schema: [`references/schemas.md`](references/schemas.md).

### Step 6: Run and Evaluate
See [`references/evaluation-workflow.md`](references/evaluation-workflow.md) for the full workflow (spawn parallel runs, baseline comparison, grading, benchmark, viewer).

### Step 7: Improve
Read feedback from the viewer. Generalize from specific complaints — avoid overfitting. Keep instructions lean. Explain the why. See [`references/improvement-guide.md`](references/improvement-guide.md).

### Step 8: Description Optimization
Optimize for triggering accuracy. See [`references/description-optimization.md`](references/description-optimization.md).

### Step 9: Sanitization Review
For public distribution, remove business-specific content. See [`references/sanitization_checklist.md`](references/sanitization_checklist.md).

### Step 10: Security Review
Run: `nong skill scan . --json`

See [`references/security-guide.md`](references/security-guide.md) for what the scanner detects and how to handle findings.

### Step 11: Package
```bash
nong skill package . --json
```

This validates, scans, and creates the `.zip` archive. See [`references/packaging-guide.md`](references/packaging-guide.md).

### Step 12: Ship or Iterate
Present the final checkpoint via AskUserQuestion. Options: Package, optimize description, expand test set, or done.

## Quickstart: Improve Skill

### Step 0: Enable Recording
Read `~/.claude/CLAUDE.md` . If the line containing `Session` is absent, ask the user to add it. Append:

```
When you encounter and fix errors while using any tool, note them. At the end of the session, run Session (see [`workflows/session/workflow.md`](workflows/session/workflow.md)).
```

### Step 1: Data Gate
Check `~/Documents/GroundPA Toolkit Workplace/skill-manager/session-records/` for entries matching the target skill. If fewer than 3 and the user doesn't insist, stop and say: "Not enough data. Found N records. Use it a few more sessions."

### Step 2: Synthesize
Read accumulated session-records. Group by error type, sort by frequency. See [`references/session-recording.md`](references/session-recording.md).

### Step 3: Wrap
Follow [`workflows/wrapper/workflow.md`](workflows/wrapper/workflow.md).

### Step 4: Run Evals
Use legacy `skill-manager eval evals/evals.json` for eval files. See [`references/evaluation-workflow.md`](references/evaluation-workflow.md).

### Step 5: Ship
Commit, package, ship per Create Skill Steps 11-12. See [`references/packaging-guide.md`](references/packaging-guide.md).

## .NET CLI Command Reference

Primary commands are in `Angri450.Nong.Cli`: `dotnet tool install --global Angri450.Nong.Cli`

| Command | Purpose |
|---------|---------|
| `nong skill validate <skill-dir> --json` | Validate one SKILL.md directory |
| `nong skill inventory <plugin-root> --json` | List plugin skills and manifests |
| `nong skill scan <plugin-root> --json` | Security scan with High+ gate |
| `nong skill package <plugin-root> --json` | Validate + scan + create plugin .zip |
| `skill-manager eval <file>` | Legacy eval schema workflow |
| `skill-manager eval serve` | Legacy interactive eval viewer |
| `skill-manager scaffold <name> --tool <x>` | Legacy wrapper skill skeleton |

`nong skill validate` accepts a single skill directory. For plugin roots, run `nong skill inventory`, then validate each returned `skill.path`.

## Non-Negotiables

1. **Deterministic work goes into .NET tools, not model prompts** — if a task can be done by code (validate, scan, package, scaffold), ship it as a NuGet package. Save model capacity for semantic work (mining, synthesizing, writing).
2. **Progressive disclosure** — SKILL.md is a flat index. Every section is one sentence + a pointer. Full details live in references/ or workflows/. Never inline a tutorial into SKILL.md.
3. **No version pinning** — no `global.json`, no `Version="x.y.z"` in csproj (use `*`), no SDK floor in docs. The user's machine decides what runs.
4. **Never edit skills in `~/.claude/plugins/cache/`** — that's read-only cache. Edit source repositories.
5. **Never delete backup versions** — only deprecate active copies.
6. **Never introduce remote CDNs** — viewer and reports must be CDN-free.
7. **Security scan is always-on** — `nong skill scan . --json` detects High+ findings.
8. **Description honesty boundary** — descriptions must only claim implemented capabilities. "Pushy" is OK; false claims are not.
9. **SKILL.md is a kernel, not a tutorial** — move detailed content to references/.
10. **Convert real failures to regression evals** — every production incident gets an eval entry.
11. **Prefer imperative form** — "Do X" not "You should do X."

## Reference Map

| File | When to Read |
|------|-------------|
| [`references/skill-development-methodology.md`](references/skill-development-methodology.md) | Full 8-phase methodology with counter-review and parallel research |
| [`references/architecture-conventions.md`](references/architecture-conventions.md) | Read-only source tree, Version="*", no global.json, session recording |
| [`references/session-recording.md`](references/session-recording.md) | JSONL format and auto-logging protocol for error recording |
| [`references/skill-writing-guide.md`](references/skill-writing-guide.md) | Frontmatter reference, Inline vs Fork, Progressive Disclosure, Bundled Resources |
| [`references/prior-art-research.md`](references/prior-art-research.md) | 8-channel search table, clone-and-verify checklist, Adopt/Extend/Build matrix |
| [`references/evaluation-workflow.md`](references/evaluation-workflow.md) | Parallel subagent spawning, grading, benchmark aggregation, viewer launch |
| [`references/description-optimization.md`](references/description-optimization.md) | Trigger eval generation, 60/40 train/test split, run_loop.py usage |
| [`references/improvement-guide.md`](references/improvement-guide.md) | How to generalize from feedback, keep lean, explain the why |
| [`references/schemas.md`](references/schemas.md) | JSON structures for evals.json, grading.json, benchmark.json, timing.json |
| [`references/prerequisites.md`](references/prerequisites.md) | Dependency auto-detection and installation |
| [`references/sanitization_checklist.md`](references/sanitization_checklist.md) | 8 categories to sanitize before public distribution |
| [`references/security-guide.md`](references/security-guide.md) | What the security scanner detects, how to handle findings |
| [`references/packaging-guide.md`](references/packaging-guide.md) | Package creation, verification, marketplace update |
| [`references/maintenance.md`](references/maintenance.md) | Incident repair, trigger debugging, regression prevention |
| [`references/merge-split.md`](references/merge-split.md) | Merge criteria, split criteria, shared resource handling |
| [`references/deprecation.md`](references/deprecation.md) | When to deprecate, notice template, safe removal conditions |
| [`references/anti-patterns.md`](references/anti-patterns.md) | Common mistakes and anti-patterns to avoid |
| [`agents/grader.md`](agents/grader.md) | How to spawn a grader subagent for assertion evaluation |
| [`agents/comparator.md`](agents/comparator.md) | How to run blind A/B comparison between two outputs |
| [`agents/analyzer.md`](agents/analyzer.md) | How to analyze benchmark results and identify patterns |
| [`workflows/session/workflow.md`](workflows/session/workflow.md) | Session — 会话结束时自动运行，提取 bug 病历和设计决策 |
| [`workflows/wrapper/workflow.md`](workflows/wrapper/workflow.md) | Wrapper — 将挖掘结果封装为带文档的可复用 skill |
