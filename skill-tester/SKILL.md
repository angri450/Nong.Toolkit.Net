---
name: skill-tester
description: Test skill quality and capture failure feedback. Trigger on test skill, check skill triggers, skill quality review, trigger precision, description accuracy, or feedback loop.
---

# Skill Tester

Test existing skills for trigger precision, description quality, and failure pattern capture.

## Nong CLI Preflight

Read [../../.claude/references/nong-cli-preflight.md](../../.claude/references/nong-cli-preflight.md) before running validation gates. Confirm the `nong` CLI is installed and the `skill` command group.

## Route Table

| User wants | Where to go |
|------------|-------------|
| Check trigger precision and description quality | [references/trigger-audit.md](references/trigger-audit.md) |
| Capture failures and feed back into skill docs | [references/feedback-loop.md](references/feedback-loop.md) |
| Validate changes after fixing | `nong skill validate .\<name> --json` |

## Boundaries

- Does not breed new skills → use `skill-breeder`
- Does not decide merge/split/deprecate → use `skill-pruner`
- Does not run CLI lifecycle gates → use `skill-grader`
