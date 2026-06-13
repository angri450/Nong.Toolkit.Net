# Nong Stage19 literature skill sync

Date: 2026-06-07

## Scope

Synchronized Nong.Toolkit.Net with the Angri450.Nong Stage19 literature module described in:

- `Nong.Cli.Net/log/changelog/2026-06-07-stage19-lit-unified-literature-dsl-result.md`
- `Nong.Cli.Net/log/guidance/2026-06-07-stage19-lit-unified-literature-dsl-guidance.md`

GroundPA remains a pure .NET / Nong CLI plugin. No Python package or ToolUniverse dependency was introduced.

## Changes

1. Added the `literature` skill for `nong lit` workflows.
2. Updated plugin metadata to version `2.3.0`.
3. Added `./literature` to `.claude-plugin/plugin.json`.
4. Added `literature` to `skills.sh.json`.
5. Updated `README.md`, `README.zh-CN.md`, and `skill.zh` to include Stage19 literature retrieval.
6. Tightened `inspect` wording so `inspect refs` is not presented as an external database search.
7. Corrected the PDF slice asset manifest wording to `assets/manifest.json`.
8. Updated `.gitignore` for local Claude/Codex rules and temporary/package artifacts while keeping `log/` committed.

## Literature Contract

Implemented Stage19 `nong lit` command surface to document:

```powershell
nong lit parse --query "<expr>" --json
nong lit validate --query "<expr>" --json
nong lit plan --query "<expr>" --sources openalex,crossref,unpaywall --json
nong lit search --query "<expr>" --sources openalex,crossref,unpaywall --limit 50 --profile balanced --out refs.json --json
nong lit export --input refs.json --format json|markdown|bibtex --out <path> --json
```

The skill documents only Stage19 providers:

```text
OpenAlex, Crossref, Unpaywall
```

Known non-implemented items remain explicit:

```text
Semantic Scholar, PubMed, PMC, arXiv, Wanfang, Sciverse, Tavily, iFlow, AMiner,
Lewen, DBLP, Qinyan, local PDF literature providers, scraping, browser automation,
paywall bypass, full-text search, automatic Chinese-English synonym translation
```

## Local CLI Reality Check

The currently installed global Nong tool reports:

```text
3.2.4+6854a00297ff6b21e043ca56e048b3fe07bef6c6
```

`nong commands --json` in this environment still reports `77 commands available` and does not include `lit` commands. Therefore the GroundPA docs and skill explicitly say literature workflows require a Nong build/version that includes Stage19 `lit` commands.

The local Angri450.Nong release build at `../Nong.Cli.Net/Cli/bin/Release/net8.0/nong.exe` reports:

```text
3.2.5+e5c6124afce2e869fb28b3366d589f289d3bfb9f
```

Its `commands --json` output reports `82 commands available` and includes:

```text
lit parse
lit validate
lit plan
lit search
lit export
```

Smoke command:

```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe lit validate --query "AU=钱伟长 AND (AF=清华大学 OR AF=上海大学)" --json
```

Result: PASS, `status=ok`, fields `AF` and `AU`, 3 concepts.

## Verification

Commands run:

```powershell
nong skill validate .\literature --json
claude plugin validate .
nong skill inventory . --json
nong skill scan . --json
nong skill package . --json
```

Results:

- `literature` skill validate: PASS, 0 errors, 0 warnings.
- Claude plugin validate: PASS.
- Nong skill inventory: PASS, 11 skills found.
- Nong skill scan: PASS, 0 findings, 0 High+.
- Nong skill package: PASS, `Nong.Toolkit.Net.zip`, 11 skills, 94358 bytes.
- Generated package moved out of the repository to `../Nong.Toolkit_archive/package-artifacts/Nong.Toolkit.Net.zip`.
- Package contents are the plugin release surface only; `log/` remains in the Git commit surface and is not included by `nong skill package`.

## Archive Boundary

Repo-local `_archive/` remains ignored as a guard only. The actual retained local archive should stay outside this repository:

```text
../Nong.Toolkit_archive/
```

This avoids `nong skill scan .` and `nong skill package .` reading old local archive material, because those commands do not use `.gitignore` as their scan boundary.
