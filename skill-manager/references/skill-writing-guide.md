# Skill Writing Guide

## Anatomy of a Skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```

## YAML Frontmatter Reference

All frontmatter fields except `description` are optional:

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name. Lowercase letters, numbers, hyphens only (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Primary triggering mechanism. |
| `context` | No | Set to `fork` to run in isolated subagent context. |
| `agent` | No | Subagent type when `context: fork`. Options: `Explore`, `Plan`, `general-purpose`. |
| `disable-model-invocation` | No | Set to `true` to prevent auto-loading. Use `/name` to invoke manually. |
| `user-invocable` | No | Set to `false` to hide from `/` menu. Default: `true`. |
| `allowed-tools` | No | Pre-approved tools list. Recommendation: do NOT set this field. |
| `model` | No | Model override when skill is active. |
| `argument-hint` | No | Hint for autocomplete. Example: `[issue-number]`. |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |

### Description Honesty Boundary

- Description SHOULD cover real trigger phrases that users actually say.
- Description MUST NOT claim capabilities not implemented in the skill.
- Every claimed capability must be traceable to SKILL.md body, references/, scripts/, or assets/.
- False positives are NOT always cheaper than false negatives. Wrong tool invocation, security risk, or user distrust makes false negatives preferable.

Violation examples:

```yaml
# BAD — claims unsupported features
description: Handles all PDF operations including creation, editing, merging, splitting, OCR, form filling, digital signatures.
# Reality: only does text extraction and rotation.

# BAD — claims lifecycle management that doesn't exist
description: Audits entire skill libraries for quality and security.
# Reality: no inventory/audit workflow implemented.

# GOOD — honest about scope
description: Extracts text and rotates pages in PDF files. Use when you need to extract text from PDFs or rotate specific pages.
```

## Inline vs Fork: Critical Decision

**Subagents cannot spawn other subagents.** A skill with `context: fork` CANNOT use Task or Skill tools.

| Your skill needs to... | Use | Why |
|------------------------|-----|-----|
| Orchestrate parallel agents (Task tool) | **Inline** (no `context`) | Subagents can't spawn subagents |
| Call other skills (Skill tool) | **Inline** (no `context`) | Subagents can't invoke skills |
| Run Bash commands for external CLIs | **Inline** (no `context`) | Full tool access |
| Perform a single focused task | **Fork** (`context: fork`) | Isolated context, clean execution |
| Provide reference knowledge | **Inline** (no `context`) | Guidelines enrich main conversation |

## Composable Skill Design (Orthogonality)

Skills should be orthogonal: each handles one concern, combining through composition.

Pattern: **Orchestrator (inline) calls Specialist (fork)**

## Pipeline Handoff

After a skill completes, suggest the natural next step:

```markdown
## Next Step: [Action]

After [this skill completes], suggest:
A) [Next skill] — [reason] (Recommended)
B) [Alternative] — [when this is better]
C) No thanks — [current output is sufficient]
```

Rules:
- Every handoff is opt-in via AskUserQuestion
- Only suggest when output naturally feeds into another skill
- Include a "No thanks" option
- Keep to 1-2 recommendations max

## Auto-Detection Over Manual Flags

Detect capabilities at runtime rather than requiring manual flags:

```markdown
# Good: Auto-detect
Step 0: Check available tools
  - `which codex` → enable cross-model analysis
  - `ls package.json` → tailor for Node.js

# Bad: Manual flags
argument-hint: [scope] [--with-codex] [--docker]
```

## Progressive Disclosure Patterns

1. **Metadata** (name + description) — Always in context
2. **SKILL.md body** — When skill triggers
3. **Bundled resources** — As needed (scripts can execute without loading)

Key patterns:
- SKILL.md length should be driven by information density, not a line count target
- Reference files clearly from SKILL.md with guidance on when to read them
- For large reference files (>300 lines), include a table of contents

**Domain organization**: When skill supports multiple frameworks, organize by variant:
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

## Writing Patterns

### Imperative form
Prefer verb-first instructions: "Validate input before processing" not "You should validate input."

### Defining output formats
```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

### Examples
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

## Dates and Version References

- **Keep factual dates**: "Suno v5.5 (March 2026)" tells readers when info was verified
- **Mark volatile data**: "~$0.035/gen as of last check"
- **Avoid conditional date logic**: Don't write "before X date do Y, after X date do Z"

## Privacy and Path References

For public distribution:
- **Forbidden**: Absolute paths to user directories, personal usernames, company names, hardcoded skill installation paths
- **Allowed**: Relative paths within skill bundle, standard placeholders

## Versioning

Skills should NOT contain version history in SKILL.md. Version is tracked in marketplace.json under `plugins[].version`.

## Reference File Naming

Pattern: `<content-type>_<specificity>.md`
- Bad: `commands.md`, `reference.md`
- Good: `api_endpoints.md`, `database_schema.md`

## Bundled Resources

### Scripts (`scripts/`)
When the same code is rewritten repeatedly or deterministic reliability needed.

### References (`references/`)
For documentation Claude should load as needed. Avoid duplication with SKILL.md.

### Assets (`assets/`)
Files used in output, not loaded into context (templates, icons, fonts).

## What to Not Include in a Skill
No README.md, CHANGELOG.md, INSTALLATION_GUIDE.md, or other extraneous files.
