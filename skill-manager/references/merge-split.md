# Skill Merge and Split

Operations for managing skill topology in a growing library.

## Merge Criteria

Consider merging two skills when any TWO of these are true:

1. **Overlapping purpose**: Both skills address > 50% of the same user intent
2. **Shared resources**: They reference the same scripts, references, or assets
3. **Description conflict**: Their descriptions compete for the same user queries
4. **User confusion**: Users invoke the wrong skill because boundaries are unclear
5. **Maintenance duplication**: Bug fixes in one predictably apply to the other

### Merge Process

1. **Diff inventory**: Run `dotnet run --project tools/SkillManager.Cli -- inventory .` on both skills.
2. **Identify common core**: Which SKILL.md sections, scripts, references overlap?
3. **Identify unique parts**: What does each skill do that the other doesn't?
4. **Design unified structure**: Core logic shared, variants as parameter or separate reference files.
5. **Unify descriptions**: Merged description must cover both original scopes.
6. **Update cross-references**: Check all skills that referenced either original.
7. **Add regression evals**: Tests covering both original scopes.
8. **Deprecate originals**: Mark both originals as deprecated → replaced by merged skill.

## Split Criteria

Consider splitting a skill when any TWO of these are true:

1. **Mega-skill**: SKILL.md exceeds 700 lines despite references/ usage
2. **Divergent use cases**: Single skill handles > 3 unrelated workflows
3. **Oversized tool collection**: > 10 scripts in one skill covering unrelated domains
4. **Description bloat**: Description lists > 8 trigger phrases from different domains
5. **User confusion**: Users say "I only need the X part, skip the Y"

### Split Process

1. **Cluster analysis**: Which scripts/references serve which user intents?
2. **Define split points**: Natural separations by domain, input type, or workflow.
3. **Extract sub-skills**: One sub-skill per cluster, each with focused SKILL.md.
4. **Share via references**: Common logic stays in a shared reference file both sub-skills point to.
5. **Add cross-references**: Each sub-skill mentions siblings in a "Related Skills" section.
6. **Pipeline handoff**: If the sub-skills form a sequence, add "Next Step" handoff sections.
7. **Deprecate original**: Mark original as deprecated → replaced by sub-skills.

## Shared Resources Handling

When skills share resources (scripts, references, templates):

- **Preferred**: Extract to a standalone shared skill or reference that both point to.
- **Acceptable**: Duplicate if the resource is small (< 50 lines) and unlikely to diverge.
- **Avoid**: Hard symbolic links between skill directories (breaks portability).

## Anti-Mega-Skill Rules

- A skill should handle ONE primary domain.
- SKILL.md should be a router/kernel, not a tutorial (target < 500 lines).
- If a SKILL.md section exceeds 50 lines of continuous prose, it should be a reference file.
- If a skill has > 3 distinct "modes" or "workflows," consider splitting.
- Never add a feature to a skill just because the description accidentally claimed it.
