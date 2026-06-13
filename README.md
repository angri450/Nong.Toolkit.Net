# Nong.Toolkit.Net

Nong.Toolkit.Net is a Claude Code multi-skill plugin for agricultural paper and document workflows.

The plugin gives Claude Code a focused set of skills for Word, PDF, literature retrieval, Excel, statistics charts, diagrams, PPTX reads, OCR/image QA, format templates, Bioicons, and paper inspection. Deterministic document and literature work is routed through the pure .NET `nong` CLI from [Nong.Cli.Net](https://github.com/angri450/Nong.Cli.Net); the model handles planning, interpretation, and writing.

## Install

Install the Claude Code plugin from a marketplace source:

```bash
claude plugin marketplace add https://gitcode.com/angri450/Nong.Toolkit.Net.git
claude plugin install nong-toolkit@angri450
```

GitHub source:

```bash
claude plugin marketplace add angri450/Nong.Toolkit.Net
claude plugin install nong-toolkit@angri450
```

After installation, restart Claude Code or run `/reload-plugins`.

The plugin installs skills only. Install or update the required Nong CLI separately:

```powershell
dotnet tool install --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
```

If Nong is already installed:

```powershell
dotnet tool update --global Angri450.Nong.Cli --add-source https://mirrors.huaweicloud.com/repository/nuget/v3/index.json
```

Check the command surface before using the skills:

```powershell
nong commands --json
```

Nong.Toolkit.Net 2.4.0 targets Nong 4.0.0+ with the 93-command surface.

## Skills

| Skill | Purpose |
|-------|---------|
| `word` | DOC/DOCX check, conversion handoff, slicing, layout evidence, repair, filling, edits, validation, merge, comments, images, fonts, and protection |
| `pdf` | PDF check, local slicing, `content.nongmark`, page rendering, embedded image extraction, and text/scan routing |
| `literature` | CNKI-like search DSL, OpenAlex/Crossref/Unpaywall metadata and OA lookup, local filtering/ranking, and JSON/Markdown/BibTeX export |
| `inspect` | Agricultural paper diagnosis, references, structure, evidence, data requirements, gaps, and writing support |
| `excel` | Workbook reads, sheet inventory, grouped data extraction, and workbook creation |
| `chart` | Statistics and chart workflows: analyze, ANOVA, Duncan, bar, line, scatter, and pie |
| `diagram` | Flowchart, network, and tree diagram generation through Nong |
| `pptx` | PPTX reads and slide inventory |
| `ocr` | OCR environment checks, image structure QA, cloud OCR, image/PDF-to-Word, OCR model inventory, and gated local OCR |
| `genre` | Paper genre listing and genre-specific writing guidance |
| `icons` | Bioicons listing and search |
| `slice` | NongPandoc package inspection, strict provenance checks, block reads, and asset inventory |
| `skill` | `nong skill validate/scan/inventory/package` lifecycle gates |
| `skill-manager` | Skill design, maintenance, trigger quality, and legacy workflow migration |
| `progress-report` | Structured log summaries and HTML progress report guidance |

Archived development-only material is kept outside the repository at `../Nong.Toolkit_archive/` and ignored by Git if it is accidentally copied back. Development process records stay in `log/` and are committed.

## Common Commands

Word:

```powershell
nong word check paper.docx --json
nong word dissect paper.docx --output paper.slice --json
nong word fonts paper.docx --json
nong word styles paper.docx --json
nong word validate paper.docx --json
```

PDF:

```powershell
nong pdf check guide.pdf --json
nong pdf dissect guide.pdf --output guide.slice --mode auto --json
nong pdf render guide.pdf --output guide.pages --dpi 150 --json
nong pdf images guide.pdf --output guide.assets --json
```

Literature:

```powershell
nong lit validate --query "SU=('腐植酸'+'腐殖酸')*('稀土'+'微肥')" --json
nong lit plan --query "SU=('腐植酸'+'腐殖酸')*('稀土'+'微肥')" --sources openalex,crossref,unpaywall --json
nong lit search --query "DOI='10.1016/j.chemgeo.2007.05.018'" --sources openalex,crossref,unpaywall --limit 20 --profile balanced --out refs.json --json
nong lit export --input refs.json --format bibtex --out refs.bib --json
```

Stage19 literature providers are OpenAlex, Crossref, and Unpaywall only. Unpaywall requires `NONG_LIT_UNPAYWALL_EMAIL` or `NONG_LIT_MAILTO`; OpenAlex may use `NONG_LIT_OPENALEX_API_KEY` or `NONG_LIT_OPENALEX_KEY`; Crossref may use `NONG_LIT_MAILTO`. Full-text retrieval, scraping, paywall bypass, Semantic Scholar, PubMed, PMC, arXiv, Wanfang, and automatic Chinese-English synonym expansion are not implemented.

Excel, chart, and diagram:

```powershell
nong excel sheets data.xlsx --json
nong excel to-groups data.xlsx --group Treatment --value Yield --raw
nong chart analyze groups.json --json
nong chart bar groups.json -o fig.png --json
nong diagram flowchart flow.json -o flow.png --json
```

PPTX and OCR:

```powershell
nong pptx read deck.pptx --json
nong pptx slides deck.pptx --json
nong ocr check-env --json
nong ocr analyze-image fig.png -o fig.analysis --json
nong ocr cloud scan.png -o ocr-out --json
nong ocr to-word scan.png -o out.docx --json
```

`ocr cloud` and `ocr to-word` require `PADDLEOCR_ACCESS_TOKEN` from `https://aistudio.baidu.com/account/accessToken`.

## Development Boundary

This repository is organized as an installable Claude Code plugin. The installable plugin surface is:

```text
.claude-plugin/
word/ pdf/ literature/ inspect/ excel/ chart/ diagram/ pptx/ ocr/ genre/ icons/
slice/ skill/ skill-manager/ progress-report/
README.md README.zh-CN.md skill.zh skills.sh.json LICENSE
```

The Git commit surface also keeps `log/` for development-process history. `nong skill package` packages the plugin surface, while `log/` remains visible in the repository.

Keep generated outputs, old experiments, local rules, package artifacts, and temporary builds out of both surfaces. Move retained local material to `../Nong.Toolkit_archive/`, not to a repo-local `_archive/`.

## Validation

Validate the plugin:

```bash
claude plugin validate .
```

Validate the Nong-facing skills:

```powershell
nong skill inventory . --json
```

For a specific skill:

```powershell
nong skill validate .\word --json
```

## License

Apache-2.0
