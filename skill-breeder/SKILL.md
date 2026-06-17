---
name: skill-breeder
description: Breed well-structured Nong.Toolkit.Net skills. Trigger on create skill, write SKILL.md, design skill, skill template, skill naming conventions, or skill structure guidance.
---

# Skill Breeder

How to breed a well-structured Nong.Toolkit.Net skill from scratch.

## Nong CLI Preflight

Read [../../.claude/references/nong-cli-preflight.md](../../.claude/references/nong-cli-preflight.md) before running validation gates. Confirm the `nong` CLI is installed and the `skill` command group.

## Route Table

| User wants | Where to go |
|------------|-------------|
| SKILL.md template and structure | [references/authoring.md](references/authoring.md) |
| Naming rules for skills | [references/authoring.md](references/authoring.md) |
| When to split into references | [references/authoring.md](references/authoring.md) |
| When to add examples | [references/authoring.md](references/authoring.md) |
| Validate the result | `nong skill validate .\<name> --json` |

## Boundaries

- Does not test existing skills → use `skill-tester`
- Does not decide merge/split/deprecate → use `skill-pruner`
- Does not run CLI lifecycle gates → use `skill-grader`
