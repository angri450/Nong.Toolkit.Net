# Literature Provider Contract

## Providers

Nong.Cli.Net 4.0.0 implements:

- OpenAlex: metadata search and DOI lookup.
- Crossref: metadata search and DOI enrichment.
- Unpaywall: legal open-access lookup by DOI.

Unpaywall requires `NONG_LIT_UNPAYWALL_EMAIL` or `NONG_LIT_MAILTO`. Crossref may use `NONG_LIT_MAILTO`. OpenAlex may use `NONG_LIT_OPENALEX_API_KEY` or `NONG_LIT_OPENALEX_KEY`.

## Workflow

Validate first:

```powershell
nong lit validate --query "<expr>" --json
```

Inspect provider translation before searching:

```powershell
nong lit plan --query "<expr>" --sources openalex,crossref,unpaywall --json
```

Search and export:

```powershell
nong lit search --query "<expr>" --sources openalex,crossref,unpaywall --limit 50 --profile balanced --out refs.json --json
nong lit export --input refs.json --format markdown --style gbt7714 --out refs.md --json
nong lit export --input refs.json --format bibtex --out refs.bib --json
```

## Boundaries

Do not claim commercial database scraping, full-text retrieval, paywall bypass, browser automation, CAPTCHA bypass, Wanfang, PubMed, Semantic Scholar, PMC, arXiv, or automatic Chinese-English synonym expansion. If synonyms matter, put them explicitly into the query.
