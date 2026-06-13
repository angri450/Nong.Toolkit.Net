# CLAUDE.md - Nong.Toolkit.Net

Nong.Toolkit.Net is the Claude Code skill layer for Nong.Cli.Net. It teaches agents how to route document, literature, Office, OCR, slice, and skill lifecycle work through the deterministic `nong` CLI.

## Current Contract

- Toolkit version: `4.1.0`.
- Required CLI: Nong.Cli.Net `4.1.0+`.
- Plugin id: `nong-toolkit`.
- Modular architecture: `nong` (12MB router) + 6 auto-install external tools (chart/diagram/pdf/pptx/ocr/imaging).
  - External tools install on first use: `nong chart bar ...` auto-installs `Angri450.Nong.Tool.Chart`.
  - Package IDs use `Angri450.Nong.Tool.*` prefix. Core library IDs (`Angri450.Nong.Chart` etc.) reserved for library packaging.
- Do not use retired GroundPA or GroundPA-Toolkit names for active docs, manifests, skills, scripts, or install commands.
- This repository contains skills and documentation only. Deterministic execution belongs in Nong.Cli.Net.

## Plugin Infrastructure

`.claude-plugin/` must contain both files:

| File | Purpose |
|------|---------|
| `marketplace.json` | Marketplace descriptor — name, owner, plugin list. Required for `claude plugin marketplace add` |
| `plugin.json` | Plugin manifest — version, skills array, keywords. Required for `claude plugin install` |

Creating a new plugin repository without `marketplace.json` causes `Marketplace file not found` on `marketplace add`. Always create both files together.

**Marketplace name**: use the project name — `nong-toolkit` for this repo, `nong-dev` for Nong.Dev.Net. Never use personal names as marketplace ids.

### Multi-plugin structure

One marketplace, multiple plugins. Each skill directory has its own `.claude-plugin/plugin.json` with `"skills": [\"./\"]`. Users install only what they need:

```
claude plugin install word@nong-toolkit       # ~20 tok
claude plugin install chart@nong-toolkit      # ~20 tok
claude plugin install nong-toolkit@nong-toolkit   # full bundle, ~320 tok
```

Directory layout:
```
.claude-plugin/
  marketplace.json        ← plugins array lists all 17 entries (bundle + 16 skills)
  plugin.json             ← root bundle plugin, skills: all subdirs
word/.claude-plugin/plugin.json   ← skills: ["./"]
chart/.claude-plugin/plugin.json  ← skills: ["./"]
...
```

### marketplace.json fields

Validated by `claude plugin validate . --strict`. Schema URI: `https://anthropic.com/claude-code/marketplace.schema.json` (404, reference only).

**Top-level (marketplace)**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `$schema` | string | no | Schema URI for documentation |
| `name` | string | **yes** | Namespace id. Used as `@<name>` in `claude plugin install`. Must be unique across repos |
| `description` | string | no | Marketplace introduction |
| `owner` | object | no | `{ "name": "..." }` |
| `plugins` | array | **yes** | Plugin entries, at least one |

**plugins[] entry**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | **yes** | Plugin id. Used as `<name>@` in `claude plugin install` |
| `source` | string | **yes** | Path to plugin directory. `"./"` means the marketplace root itself is the plugin |
| `description` | string | no | Plugin description shown during install |
| `author` | object | no | `{ "name": "..." }` |
| `category` | string | no | Category label, e.g. `"developer-tools"` |

## Required Workflow

1. Inspect the relevant `SKILL.md` and linked references before editing.
2. Keep each `SKILL.md` concise. Put shared or detailed rules in `references/`.
3. Use `references/shared/nong-cli-preflight.md` for the common CLI prerequisite instead of duplicating install blocks.
4. Keep generated outputs, package zips, experiments, and cache material outside the repository in `../Nong.Toolkit_archive/`.
5. Record development work under `log/plans/`, `log/changelog/`, `log/debug/`, or `log/guidance/` and update the matching `index.md`.

## Credentials

- GitHub: `gh auth` logged in as angri450. Token in Windows Credential Manager.
- NuGet: `NUGET_API_KEY` in user environment. Persistent across reboots.
- Gitee / GitCode: cached in Windows Credential Manager.
- On 401/403: tell the user to refresh their token.

## Skill governance

Five agricultural personas govern all skill work:

```
skill-breeder   Breeder   — create: templates, naming, reference structure
skill-tester    Tester    — test: trigger precision, description accuracy, feedback loops
skill-grader    Grader    — gate: validate → scan → inventory → package
skill-patrol    Patrol    — monitor: detect stale skills after CLI upgrades (pending)
skill-pruner    Pruner    — prune: merge, split, deprecate
```

## Skill Boundaries

- `word`, `pdf`, `excel`, and `pptx` teach document routing and evidence reading.
- `ocr` teaches OCR and image-structure QA through `nong ocr`.
- `slice` teaches the unified NongPandoc package reader commands.
- `skill-grader` teaches `nong skill validate/scan/inventory/package`.
- `skill-breeder` teaches skill authoring: templates, naming, structure.
- `skill-tester` teaches skill quality testing and feedback loops.
- `skill-pruner` teaches lifecycle governance: merge, split, deprecate.
- `progress-report` teaches project log reporting. If a report generator is needed, it should be implemented in Nong.Cli.Net, not as a private Toolkit script.

## Validation

Use the local 4.0.0 CLI when the global `nong` tool is stale:

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill inventory . --json
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill scan . --json
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill package . --json
```

Validate changed skills directly:

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\word --json
```

## Nong CLI reference

Global `nong` tool: 125 commands across 16 modules. All support `--json`. Command surface: `nong commands --json`. NanoBot bridge: `nong commands --format openai-tools`.

| Module | Key commands |
|--------|-------------|
| word (39) | check, create, read, dissect, diagnose, clean-styles, format-gongwen, format-audit, table-reflow, add *, merge, protect, compare, crop, fit-images, compact-tables, regroup-images, estimate, page-setup, indent, paragraph-control, image-wrap, cell-format, run-format, images (->nong-imaging for analyze/crop) |
| inspect (12) | diagnose, classify, structure, refs, evidence, data-req, gap, semantics, write-paper, write-official, official-check |
| chart (11) | analyze, anova, duncan, bar, line, scatter, pie, boxplot, histogram, heatmap, radar |
| excel (8) | sheets, read, to-groups, create, dissect, style, formula, pivot |
| pdf (8) | check, dissect, render, images, merge, split, ocr, compress |
| ocr (11) | local, cloud, check-env, analyze-image, models, install-model, to-word, batch, video, screen, camera |
| lit (5) | parse, validate, plan, search, export |
| pptx (4) | read, slides, dissect, create |
| diagram (3) | flowchart, network, tree |
| genre (2) | list, show |
| icons (2) | list, search |
| slice (4) | inspect, blocks, block, assets |
| skill (4) | validate, scan, inventory, package |
| progress (1) | report |
| commands (1) | list commands (--json / --format openai-tools) |

## Skill authoring rules

### Every skill must have

1. **SKILL.md** — name + description frontmatter, route table, boundaries
2. **At least 1 example** in `examples/`. Format: What the user wants → What was done → Result → Key takeaways
3. **At least 1 reference** in `references/`. Split files exceeding 30 lines. High-frequency skills need 2-3 references.
4. **At least 1 eval** in `evals/`. One JSON file, 2-3 items, covering the most-used CLI entry points.
5. **Exact parameter names** — every CLI command shown in SKILL.md must use parameters that actually exist. Do not write `--block-id` if the CLI takes a positional argument.

### Gate checklist after any skill change

```
nong skill validate .\<name> --json
nong skill scan . --json
nong skill inventory . --json
nong skill package . --json
```

### CLI-mirror naming rule

CLI-mirror skills must match the CLI command group name exactly: `ocr` ↔ `nong ocr`, `word` ↔ `nong word`. Never give a CLI-mirror skill a vague name like `multimodal` when the CLI group is `ocr`.

### CLI → skill sync

After changing the CLI:
- Never rename existing commands. Use aliases for better names.
- Never expand the semantics of an existing command (e.g. do not stuff histograms into `chart analyze`).
- Sync affected SKILL.md, references, and examples immediately.
- Verify with `nong commands --json` and `nong skill validate`.

## Legacy rules

- SKILL.md is the routing kernel. Long guidance goes in references.
- Deterministic work goes in .NET CLI tools. Python is legacy fallback only.
- Security scan is mandatory (`nong skill scan`).
- Blind eval must be blind.
- Description must be honest. Do not declare capabilities the CLI does not implement.
