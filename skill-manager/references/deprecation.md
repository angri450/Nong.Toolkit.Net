# Skill Deprecation

Process for retiring obsolete or superseded skills.

## When to Deprecate

- A replacement skill exists that covers the same use cases better
- The skill's tool/API dependency is no longer available
- The skill has been unused for an extended period
- The skill's instructions are incompatible with current Claude versions
- The skill has been merged into another skill (both originals deprecated)

## Deprecation Notice Template

Add to the deprecated skill's SKILL.md frontmatter:

```yaml
---
name: deprecated-skill-name
description: [DEPRECATED] This skill is no longer maintained. Use replacement-skill-name instead.
---
```

And add to the body:

```markdown
## DEPRECATED — Migration Notice

This skill has been deprecated as of YYYY-MM-DD.

**Replacement**: Use `replacement-skill-name` instead.
**Migration guide**: See [MIGRATION.md](MIGRATION.md) for step-by-step migration.
**Last compatible Claude version**: Claude X.Y
**Support ends**: YYYY-MM-DD

### Why was this skill deprecated?

[One paragraph explanation]
```

## Replacement Mapping

Maintain a replacement mapping for users:

| Deprecated Skill | Replacement | Migration Complexity |
|-----------------|-------------|---------------------|
| skill-name | replacement-name | Low / Medium / High |

## Safe Removal Conditions

A skill can be safely removed when ALL of these are true:

1. All active users have migrated to the replacement
2. No other skill references the deprecated skill's resources
3. The replacement has been stable for at least one Claude version cycle
4. The deprecation notice has been in place for at least 30 days
5. No regression evals reference the deprecated skill

## Archive

Do NOT delete deprecated skills immediately. Move them to an archive:

```
archive/
└── deprecated-skill-name/
    └── DEPRECATED.md (explains when archived and why)
```

This preserves history and allows rollback if the replacement proves insufficient.

## Important: Backup Versions

**Never delete backup versions, workspace copies, or historical snapshots during deprecation.** Only mark the active skill as deprecated. Backup versions in Desktop/, Downloads/, or other locations are not part of the active skill library and should remain untouched.
