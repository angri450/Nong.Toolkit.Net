---
name: skill-pruner
description: Prune skill lifecycle governance. Trigger on merge skills, split skills, deprecate skill, or skill lifecycle decisions.
---

# Skill Pruner

Decide when to merge, split, or deprecate skills.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before running validation gates. Confirm Nong.Cli.Net `4.1.0+` and the `skill` command group.

## Route Table

| User wants | Where to go |
|------------|-------------|
| Merge two skills | [references/lifecycle.md](references/lifecycle.md) |
| Split an oversized skill | [references/lifecycle.md](references/lifecycle.md) |
| Deprecate a retired skill | [references/lifecycle.md](references/lifecycle.md) |
| Breed a new skill | `skill-breeder` |
| Test skill quality | `skill-tester` |
| Validate/package skills | `skill-grader` |

## Boundaries

- Does not breed skills → use `skill-breeder`
- Does not test skills → use `skill-tester`
- Does not run CLI lifecycle gates → use `skill-grader`
