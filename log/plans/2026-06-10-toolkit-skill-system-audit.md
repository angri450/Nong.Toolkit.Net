# toolkit skill system audit plan

## Goal

Write a Chinese HTML audit for the full Nong.Toolkit.Net skill system, focusing on:

1. trigger precision;
2. progressive disclosure depth;
3. example discipline;
4. naming clarity;
5. feedback/regression maturity across skills.

## Work

1. Read `CLAUDE.md`, the existing `skill-manager` audit, and every `SKILL.md` entry file.
2. Compare skill names and descriptions against Nong.Cli.Net command-group alignment.
3. Check which skills have `references/`, `scripts/`, `formats/`, and `examples/`.
4. Produce a standalone Chinese HTML page that says clearly which skills are already usable, which are thin, and which need targeted repair.

## Status

Done.

## Verification

- Targeted read audit of all 15 `SKILL.md` files.
- Spot checks of key references and structured log indexes.
- Report written under `log/reports/toolkit-skill-system-audit.html`.
