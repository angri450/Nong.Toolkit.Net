---
name: skill-manager
description: Create, maintain, and audit skills for Nong.Toolkit.Net. Trigger on create skill, edit skill, fix skill, merge skills, split skills, deprecate skill, run evals, benchmark, audit quality, or optimize descriptions.
---

# Skill Manager

Policy skill for designing and maintaining skills. For deterministic validation, scanning, inventory, and packaging, use the `skill` skill and `nong skill ...` commands.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before running validation or packaging gates. Confirm Nong.Cli.Net `4.0.0+` and the `skill` command group.

## Route Table

| User wants | Where to go |
|------------|-------------|
| Create a new skill | [references/authoring.md](references/authoring.md) |
| Audit an existing skill | [references/trigger-audit.md](references/trigger-audit.md) |
| Recover from a failure | [references/feedback-loop.md](references/feedback-loop.md) |
| Package and publish | `nong skill validate` → `nong skill scan` → `nong skill package` |
| List skills | `nong skill inventory . --json` |

## Boundaries

- Do not bypass `nong skill` commands for packaging. The CLI is the deterministic gate.
- Do not replace word/pdf/ocr execution skills. This is a governance skill, not an execution skill.
- Keep old marketplace cache copies read-only. Edit the source repository.
- Remove retired project names from active docs and manifests.
