---
name: nongcli
description: Project-level workspace management via nong. Trigger on workspace init, NongWorkplace path resolution, or embedding model installation for semantic search.
---

# Nong CLI Workspace

Use `nong nongcli` for project-level workspace setup. Creates the `.nong/` workspace skeleton, resolves the NongWorkplace root path, and installs the ONNX embedding model for semantic search (`nong search`).

## Nong CLI Preflight

Read [../../.claude/references/nong-cli-preflight.md](../../.claude/references/nong-cli-preflight.md) before the first Nong CLI command.

## Implemented Commands

```powershell
nong nongcli init <path>                    # Create .nong/ workspace skeleton
nong nongcli where                          # Print resolved NongWorkplace root path
nong nongcli install-embedding              # Install jina-embeddings-v5 ONNX model (~100MB)
```

## Workflows

### First-time project setup
```powershell
nong nongcli init ./my-project
nong nongcli install-embedding  # enables nong search
```

### Check workspace root
```powershell
nong nongcli where
# → C:\Users\Administrator\Documents\workplace
```

## Notes

- `install-embedding` downloads ~100MB ONNX model to the NongWorkplace cache
- Semantic search (`nong search`) requires the embedding model to be installed
- The workspace persists across sessions at `%USERPROFILE%/Documents/workplace` (or configured alternative)
