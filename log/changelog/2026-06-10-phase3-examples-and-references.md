# 2026-06-10 阶段三 A/B 类 Skill 补 Examples 和 References 完工

## What changed

为 11 个 A/B 类 skill 补充了 32 个 examples 和 6 个 references。不改 SKILL.md 主体结构。

### A 类 skill（6 个，补 18 个 examples）

| Skill | Examples |
|-------|----------|
| `word` | `academic-format-paper.md`, `existing-docx-repair.md`, `table-reflow-report.md`, `failed-com-automation.md` |
| `pdf` | `text-pdf-dissect.md`, `scan-pdf-ocr.md`, `hybrid-pdf-routing.md` |
| `literature` | `doi-lookup.md`, `complex-query.md`, `provider-failure.md` |
| `chart` | `anova-duncan-bar.md`, `bad-input-json.md`, `scatter-with-groups.md` |
| `excel` | `read-to-statistics.md`, `create-simple-workbook.md`, `multi-sheet-workbook.md` |
| `diagram` | `tree-newick.md`, `diagram-bad-input.md` |

### B 类 skill（5 个，补 14 个 examples + 6 个 references）

| Skill | Examples | References |
|-------|----------|------------|
| `skill` | `validate-success.md`, `package-plugin.md`, `scan-has-findings.md` | `skill-lifecycle.md`, `security-scan-解读.md` |
| `slice` | `read-word-slice.md`, `read-pdf-slice.md`, `block-level-evidence.md` | `slice-package-contract.md` |
| `pptx` | `read-slides.md`, `dissect-slide.md` | — |
| `genre` | `list-templates.md`, `show-template.md`, `template-to-inspect.md` | — |
| `inspect` | `paper-diagnose.md`, `gongwen-write.md`, `refs-check-vs-lit-search.md` | `diagnose-steps.md`, `write-paper-spec.md`, `write-official-spec.md` |

## Why

2026-06-10 Toolkit 全量审计发现 15 个 skill 中只有 1 个有 examples，5 个缺 references。补完后所有 skill 都具备至少 1 个 example 和必要的下钻材料。

## Files touched

32 个新 examples + 6 个新 references，分布如下：

```
word/examples/      4 files
pdf/examples/       3 files
literature/examples/ 3 files
chart/examples/     3 files
excel/examples/     3 files
diagram/examples/   2 files
skill/references/   2 files (new)
skill/examples/     3 files
slice/references/   1 file (new)
slice/examples/     3 files
pptx/examples/      2 files
genre/examples/     3 files
inspect/references/ 3 files (new)
inspect/examples/   3 files
```

## Verification

```text
nong skill validate (all 11)
Result: word PASS, pdf PASS, literature PASS, chart PASS, excel PASS,
        diagram PASS, skill PASS, slice PASS, pptx PASS, genre PASS, inspect PASS

nong skill inventory . --json
Result: 15 skills

nong skill scan . --json
Result: 0 findings

nong skill package . --json
Result: status ok, 15 skills
```

## Completion status

After Phase 1 (CLI 5 aliases), Phase 2 (4 C-class skill rewrites), and Phase 3 (32 examples + 6 references):

- All 15 Toolkit skills now have at least 1 example
- All skills that needed references now have them
- 0 scan findings, 0 validation errors
- All 3 phases DONE
