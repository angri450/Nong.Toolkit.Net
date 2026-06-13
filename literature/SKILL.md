---
name: literature
description: Literature retrieval workflows through nong lit. Trigger on CNKI-like search expressions, literature search planning, DOI lookup, OpenAlex/Crossref/Unpaywall metadata or OA lookup, reference export to JSON/Markdown/BibTeX, or bibliography preparation for agricultural papers.
---

# Literature

Use `nong lit` as the deterministic literature retrieval entrypoint. Nong.Toolkit.Net prepares CNKI-like search expressions, checks provider plans, reads normalized JSON records, and exports references; it does not use Python literature packages, browser automation, scraping, or paywall bypass.

## Nong CLI Preflight

Read [../references/shared/nong-cli-preflight.md](../references/shared/nong-cli-preflight.md) before the first Nong command in a session. Confirm Nong.Cli.Net `4.0.0+` and the needed command group.
## DSL

The stable contract is the CNKI-like Nong DSL, not any provider's native query language.

Supported fields:

```text
SU TI KY AB FT AU FI F AF JN RF YE FU CLC SN CN IB CF DOI
```

Supported syntax:

```text
FIELD=...
'quoted phrase'
unquoted terms
+  *  -
AND OR NOT
()
YE BETWEEN ('2000','2013')
```

Operator mapping:

- `+` means OR.
- `*` means AND.
- `-` means NOT.
- `AND`, `OR`, and `NOT` keep their usual boolean meanings.

Useful examples:

```powershell
nong lit parse --query "SU=('腐植酸'+'腐殖酸')*('稀土'+'微肥')" --json
nong lit validate --query "AU=钱伟长 AND (AF=清华大学 OR AF=上海大学)" --json
nong lit plan --query "DOI='10.1016/j.chemgeo.2007.05.018'" --sources openalex,crossref,unpaywall --json
```

Unsupported operators such as `%`, `/SEN`, `/NEAR`, `/PREV`, `/AFT`, `/PRG`, and `$N` must fail with `E006 validation_failed`. Do not silently reinterpret them.

## Default Workflow

1. Parse or validate the query before running provider work:

```powershell
nong lit validate --query "<expr>" --json
```

2. Inspect the provider plan:

```powershell
nong lit plan --query "<expr>" --sources openalex,crossref,unpaywall --json
```

Use the plan to explain field coverage, generated rough queries, provider limitations, and credential availability. Credential diagnostics expose environment variable names and booleans only; do not print real values.

3. Search with implemented providers:

```powershell
nong lit search --query "<expr>" --sources openalex,crossref,unpaywall --limit 50 --profile balanced --out refs.json --json
```

Ranking profiles are `balanced`, `classic`, and `recent`.

4. Export references:

```powershell
nong lit export --input refs.json --format markdown --style gbt7714 --out refs.md --json
nong lit export --input refs.json --format bibtex --out refs.bib --json
```

Do not treat export success as valid unless the output artifact exists and is non-empty.

## Providers

For provider credentials, query planning, and boundaries, read [references/provider-contract.md](references/provider-contract.md).

Implemented Nong.Cli.Net 4.0.0 providers:

- OpenAlex: metadata search and DOI lookup; optional `NONG_LIT_OPENALEX_API_KEY` or `NONG_LIT_OPENALEX_KEY`.
- Crossref: metadata search and DOI enrichment; optional `NONG_LIT_MAILTO`.
- Unpaywall: legal open-access lookup by DOI; requires `NONG_LIT_UNPAYWALL_EMAIL` or fallback `NONG_LIT_MAILTO`.

Unpaywall is DOI-only. If selected without a DOI or without the required email variable, report the machine-readable issue instead of pretending the provider searched broadly.

## Boundaries

Stage19 does not implement Semantic Scholar, PubMed, PMC, arXiv, Wanfang, Sciverse, Tavily, iFlow, AMiner, Lewen, DBLP, Qinyan, local PDF literature providers, scraping, browser automation, CAPTCHA bypass, institutional login automation, commercial database scraping, paywall bypass, full-text search, or automatic Chinese-English synonym translation.

If users need English synonyms, include them explicitly in the query. If users need full-text evidence from PDFs, use the `pdf` skill to slice local PDFs first, then reason over `content.nongmark` and cite that local evidence separately from `lit` metadata.

## Error Contract

Always pass `--json` when output feeds another tool or model decision. Treat `status: "error"` as failed.

Common codes:

- `E001 file_not_found`: fix the input or export path.
- `E005 dependency_missing`: provider credential or runtime prerequisite is missing.
- `E006 validation_failed`: query syntax, unsupported field/operator, provider name, rank profile, or source selection is invalid.
- `E007 read_failed`: input literature JSON cannot be parsed.
- `E008 write_failed`: output artifact was not created or is empty.
- `E004 internal_error`: unexpected bug; keep command JSON and stderr/stdout for diagnosis.
