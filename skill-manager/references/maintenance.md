# Skill Maintenance

Lifecycle maintenance for skills that have been shipped. This covers operations after the create → test → package pipeline.

## Incident-Driven Repair

When a skill breaks in production:

1. **Triage**: Determine if the failure is description (not triggering), content (triggered but not followed), or environment (paths, dependencies).

2. **Diagnose common failure modes**:
   - **Not triggering**: Description no longer matches user intent, or adjacent skill overrides. Run description optimization.
   - **Triggered but not applied**: Skill instructions ignored or overridden. Check SKILL.md clarity and competing context.
   - **Script not found**: Path resolution failure. Validate with `dotnet run --project tools/SkillManager.Cli -- validate .`
   - **Reference not found**: Missing file referenced in SKILL.md. Check inventory.
   - **Version mismatch**: Skill uses deprecated tool/API. Upgrade needed.

3. **Always convert real failures to regression evals**: After fixing, add an eval entry that reproduces the failure mode. This prevents recurrence.

## Trigger Debugging

### Over-Triggering

When a skill triggers too often:
- Check description for overly broad claims
- Check for keyword overlap with adjacent skills
- Narrow description to specific triggers
- Test with should-not-trigger eval queries

### Under-Triggering

When a skill never triggers:
- Description may be too narrow or technical
- Missing common user phrases in description
- Description fails to mention when to use the skill
- Run description optimization loop

### Loaded But Not Applied

When skill loads but Claude ignores its instructions:
- Instructions may be too verbose (lost in context)
- Instructions may conflict with Claude's default behavior
- Skill may lack clear "do this, not that" guidance
- Add explicit decision points and non-negotiable steps

## Regression Prevention

Every real production incident should produce:
1. A regression eval entry in `evals/evals.json`
2. A fix to the skill (description, instructions, or resources)
3. A brief incident note (root cause + fix) — see below

### Incident Note Format

```markdown
### INCIDENT-YYYY-MM-DD: [One-line summary]

**Symptom**: [What the user observed]
**Root cause**: [What was wrong]
**Fix**: [What changed]
**Regression eval**: [Link to eval ID]
```
