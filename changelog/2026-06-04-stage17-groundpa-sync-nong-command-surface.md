# Stage 17: GroundPA sync to Nong command surface

Date: 2026-06-04

## Source Truth

Nong source:

```text
git short hash: fe0b7ec
nong commands summary: 71 commands available
nong commands meta.version: 3.1.0
dotnet build Cli/NongCli.csproj -c Release: PASS, 0 errors
dotnet test Cli.Tests/Cli.Tests.csproj -c Release: 58/58 PASS, 0 skip
```

GroundPA source before this sync:

```text
git short hash: 2f8a16a
plugin version: 2.0.0
inventory: 17 skills
scan before local absolute-path fix: 1 High caused by this branch's DEVELOP.md validation example
```

GroundPA target:

```text
plugin version: 2.1.0
inventory: 19 skills
newly registered skills: pptx, multimodal
```

## Changed Skills

Updated Nong-facing skills:

```text
word
inspect
excel
chart
diagram
pptx
multimodal
```

Updated registry and docs:

```text
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
skills.sh.json
README.md
README.zh-CN.md
DEVELOP.md
skill-manager/SKILL.md
github/references/gh-cli.md
skill-manager/references/security-guide.md
```

## Command Surface Exposed

Word now exposes the full current implemented Word surface:

```text
read, preview, fill, rebuild, extract, dissect, stats, fonts, styles,
validate, merge, outline, images, comments, revisions, infer-format,
fix-order, protect, embed-font,
add paragraph, add table, add footnote, add endnote, add image, add toc,
add xref, add link, add bookmark, add comment, add math
```

Word routing now treats `word dissect --output` as the primary complex DOCX path. Add commands use canonical nested names such as `word add paragraph`; flattened add aliases are described only as compatibility aliases.

Inspect now exposes:

```text
diagnose, refs, write-paper, classify, structure, varplan, evidence,
data-req, gap, semantics
```

Excel now exposes:

```text
sheets, read, to-groups, create
```

Chart now exposes:

```text
analyze, anova, duncan, bar, line, scatter, pie
```

Diagram now exposes:

```text
flowchart, network, tree
```

PPTX is restored as a read-only skill:

```text
pptx read
pptx slides
```

Multimodal is restored for OCR and image-structure QA:

```text
ocr check-env
ocr analyze-image
ocr cloud
ocr to-word
ocr models
ocr install-model
ocr local
```

`ocr local` is documented as gated. It must not be described as a stable local OCR path unless the environment and a real image smoke test pass.

## Deliberate Boundaries

Still not promised:

```text
PPTX generation or editing
OCR local success without installed and verified local model path
cloud OCR without PADDLEOCR_ACCESS_TOKEN
Excel dashboards, pivot tables, arbitrary styling, complex formulas, macros
Chart box plots, histograms, heatmaps, radar charts, combined panels
Diagram semantics beyond rendered flowchart/network/tree commands
Python OCR fallback or ad hoc document parsing
```

## Validation

Nong source validation:

```text
dotnet build Cli/NongCli.csproj -c Release: PASS
dotnet test Cli.Tests/Cli.Tests.csproj -c Release: 58 PASS, 0 fail, 0 skip
nong commands --json: 71 commands available
nong commands --all --json: 71 commands available
```

GroundPA plugin validation:

```text
nong skill inventory <repo>: PASS, 19 skills
nong skill validate <each skill path>: PASS for all 19 skills
nong skill scan <repo>: PASS, 9 findings, 0 High+
nong skill package <repo>: PASS, packageType plugin, skillCount 19
claude plugin validate .: PASS
```

Remaining scan findings are historical Medium/Low findings:

```text
LICENSE HTTP URL: Low
historical changelog home-path references: Medium
genre workspace home-path reference: Medium
github gh-cli home-path reference: Medium
skill-manager architecture/session path references: Medium
```

These do not block packaging.

Stale and secret gates:

```text
current Nong-facing stale command scan: 0 hits
token/secret regex scan: 0 hits
absolute local path scan in current docs: 0 hits
```

Smoke validation:

```text
word dissect sample DOCX: PASS
word add paragraph sample DOCX: PASS
inspect classify sample text: PASS
excel create sample spec: PASS
chart line/scatter/pie sample specs: PASS
diagram tree sample Newick: PASS
ocr check-env: PASS, imageAnalyzer ok, token missing, local model missing
ocr analyze-image generated line chart: PASS
ocr models: PASS, 0 models
pptx read/slides first available fixture: PASS
ocr cloud/to-word: skipped because PADDLEOCR_ACCESS_TOKEN was unavailable
```

`ocr analyze-image` reported high whitespace on a simple line chart, which is useful as a structural QA signal but not a semantic chart judgment.

## Artifacts

`nong skill package` produced a plugin zip during validation. The package was treated as a verification artifact and should not be committed unless an explicit release step retains it.

Smoke outputs were written under the system temp directory, not inside the GroundPA source tree.

## Notes

The Stage 17 sync intentionally favors the current `nong commands --json` result over older changelog statements. Historical notes that said PPTX/OCR were unavailable or that only a small Word/Inspect/Chart/Excel subset was exposed are now stale for GroundPA 2.1.0.
