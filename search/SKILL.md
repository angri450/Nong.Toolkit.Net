---
name: search
description: Semantic search across ingested document blocks via nong. Trigger on document search, similarity queries, or full-text lookup. Sources must be ingested first with --ingest flag on dissect commands.
---

# Semantic Search

Use `nong search` to run semantic (vector) search across document blocks that have been ingested into the local NongDb. Documents are ingested via the `--ingest` flag on dissect commands across all formats.

Requires the embedding model to be installed first: `nong nongcli install-embedding`.

## Nong CLI Preflight

Read [../../.claude/references/nong-cli-preflight.md](../../.claude/references/nong-cli-preflight.md) before the first Nong CLI command.

## Implemented Commands

```powershell
nong search <query> [--limit 5] [--format docx|pdf|xlsx|pptx] [--scores] [--json]
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `<query>` | Search query text (positional, required) | — |
| `--limit` | Max results (1-20) | 5 |
| `--format` | Filter by document format | all |
| `--scores` | Include similarity scores in output | false |
| `--json` | Structured JSON output | false |

## Workflows

### Ingest → Search pipeline
```powershell
# Step 1: Ingest documents (add --ingest to any dissect command)
nong word dissect paper.docx -o slice/ --ingest
nong pdf dissect report.pdf -o slice/ --ingest

# Step 2: Search
nong search "banana ethylene postharvest" --limit 5 --scores --json
```

### Filter by format
```powershell
nong search "methodology" --format pdf --limit 3 --json
```

## Notes

- Sources must be ingested first — dissect commands with `--ingest` write to the local NongDb
- The embedding model (jina-embeddings-v5-text-nano, ONNX) must be installed via `nong nongcli install-embedding`
- Search is semantic (vector similarity), not keyword-based — it finds conceptually related content
- Results include block text, source document, page/slide/sheet location, and optional similarity scores
