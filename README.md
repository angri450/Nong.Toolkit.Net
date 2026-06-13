# Nong.Toolkit.Net

Nong.Toolkit.Net is a Claude Code multi-plugin marketplace for agricultural paper and document workflows. 17 plugins — one full bundle plus 16 individual skills. Install only what you need.

Deterministic document and literature work is routed through the pure .NET `nong` CLI from [Nong.Cli.Net](https://github.com/angri450/Nong.Cli.Net); the model handles planning, interpretation, and writing.

## Install

### Full bundle

```bash
claude plugin marketplace add https://gitcode.com/angri450/Nong.Toolkit.Net.git
claude plugin install nong-toolkit@nong-toolkit
```

### Individual skills (lower token cost)

```bash
claude plugin marketplace add https://gitcode.com/angri450/Nong.Toolkit.Net.git
claude plugin install word@nong-toolkit          # ~78 tok always-on
claude plugin install pdf@nong-toolkit
claude plugin install chart@nong-toolkit
# ... install any subset
```

GitHub source:

```bash
claude plugin marketplace add angri450/Nong.Toolkit.Net
claude plugin install word@nong-toolkit
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

Nong.Toolkit.Net 2.5.0 targets Nong 4.1.0+.

## Skills

| Skill | Purpose | Plugin id |
|-------|---------|-----------|
| `word` | DOC/DOCX check, conversion handoff, slicing, layout evidence, repair, filling, edits, validation, merge, comments, images, fonts, and protection | `word@nong-toolkit` |
| `pdf` | PDF check, local slicing, `content.nongmark`, page rendering, embedded image extraction, text/scan routing, merge, split, ocr | `pdf@nong-toolkit` |
| `literature` | CNKI-like search DSL, OpenAlex/Crossref/Unpaywall metadata and OA lookup, local filtering/ranking, and JSON/Markdown/BibTeX export | `literature@nong-toolkit` |
| `inspect` | Agricultural paper diagnosis, references, structure, evidence, data requirements, gaps, and writing support | `inspect@nong-toolkit` |
| `excel` | Workbook reads, sheet inventory, grouped data extraction, workbook creation, cell styling, formulas, pivot tables | `excel@nong-toolkit` |
| `chart` | Statistics and chart workflows: analyze, ANOVA, Duncan, bar, line, scatter, pie, boxplot, histogram, heatmap, radar | `chart@nong-toolkit` |
| `diagram` | Flowchart, network, and tree diagram generation through Nong | `diagram@nong-toolkit` |
| `pptx` | PPTX reads, slide inventory, PPTX creation from JSON spec | `pptx@nong-toolkit` |
| `ocr` | OCR environment checks, image structure QA, cloud OCR, image/PDF-to-Word, OCR model inventory, gated local OCR | `ocr@nong-toolkit` |
| `genre` | Paper genre listing and genre-specific writing guidance | `genre@nong-toolkit` |
| `icons` | Bioicons listing and search | `icons@nong-toolkit` |
| `slice` | NongPandoc package inspection, strict provenance checks, block reads, asset inventory | `slice@nong-toolkit` |
| `skill-grader` | `nong skill validate/scan/inventory/package` lifecycle gates | `skill-grader@nong-toolkit` |
| `skill-breeder` | Skill breeding: templates, naming conventions, structure | `skill-breeder@nong-toolkit` |
| `skill-tester` | Skill testing: trigger precision, feedback loops | `skill-tester@nong-toolkit` |
| `skill-pruner` | Lifecycle pruning: merge, split, deprecate | `skill-pruner@nong-toolkit` |

Archived development-only material is kept outside the repository at `../Nong.Toolkit_archive/`. Development process records stay in `log/`.

## Common Commands

Word:

```powershell
nong word check paper.docx --json
nong word dissect paper.docx --output paper.slice --json
nong word fonts paper.docx --json
nong word styles paper.docx --json
nong word validate paper.docx --json
# Compaction pipeline
nong word estimate paper.docx --json           # page break analysis
nong word crop paper.docx -o cropped.docx      # auto-crop image borders
nong word fit-images paper.docx -o fit.docx    # side-by-side image pairs
nong word compact-tables paper.docx -o out.docx # table width + row height
nong word page-setup paper.docx --size A4 --margin-top 25 -o out.docx
nong word indent paper.docx --role body --first-line 7.4 -o out.docx
nong word paragraph-control paper.docx --role heading --keep-next true -o out.docx
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
nong ocr local scan.png --json
nong ocr to-word scan.png -o out.docx --json
nong ocr batch ./scans/ --pattern "*.png" --json
nong ocr video demo.mp4 -o subtitles.srt --json
nong ocr screen --x 0 --y 0 --w 800 --h 600 --json
```

`ocr cloud` and `ocr to-word` require `PADDLEOCR_ACCESS_TOKEN` from `https://aistudio.baidu.com/account/accessToken`. `ocr local` uses PP-OCRv6 with pure .NET native runtime. `ocr batch` processes directories. `ocr video` extracts frames with dHash dedup and outputs SRT subtitles. `ocr screen` captures screen regions on Windows.

## Development Boundary

This repository is organized as a Claude Code multi-plugin marketplace. Each skill directory has its own `.claude-plugin/plugin.json`. The installable plugin surface is:

```text
.claude-plugin/
word/ pdf/ literature/ inspect/ excel/ chart/ diagram/ pptx/ ocr/ genre/ icons/
slice/ skill-grader/ skill-breeder/ skill-tester/ skill-pruner/
README.md README.zh-CN.md skill.zh skills.sh.json LICENSE
```

The Git commit surface also keeps `log/` for development-process history.

Keep generated outputs, old experiments, local rules, package artifacts, and temporary builds out of both surfaces. Move retained local material to `../Nong.Toolkit_archive/`.

## Validation

Validate the marketplace:

```bash
claude plugin validate .
```

Validate individual plugins:

```bash
claude plugin validate word
claude plugin validate chart
```

Validate Nong-facing skills:

```powershell
nong skill inventory . --json
nong skill validate .\word --json
```

## License

Apache-2.0
