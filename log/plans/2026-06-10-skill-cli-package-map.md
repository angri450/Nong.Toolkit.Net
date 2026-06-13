# skill cli package map plan

## Goal

Write a Chinese HTML mapping page that explains, for every Nong.Toolkit.Net skill:

1. which `nong` CLI command group it routes to;
2. which core package/project actually implements that area;
3. which direct dependency packages matter;
4. which runtime repository or runtime packages matter when applicable;
5. whether the current shape matches the desired "skill -> cli -> package" control axis.

## Work

1. Read Toolkit skill files and the existing Toolkit skill-system audit.
2. Read Nong.Cli.Net project-structure docs and the relevant `.csproj` files.
3. Read the sibling `Nong.OcrRuntime` repository naming and package matrix.
4. Produce a standalone Chinese HTML mapping page and update the OCR wording in the Toolkit system audit.

## Status

Done.

## Verification

- Read Nong.Cli.Net `Cli/AGENT.md`, `.claude/references/project-structure.md`, and relevant `.csproj` files.
- Read `Nong.OcrRuntime` `README.md` and `OcrRuntime.csproj`.
- Wrote `log/reports/toolkit-skill-cli-package-map.html`.
