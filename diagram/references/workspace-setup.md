# Diagram Workspace Setup

Diagram workflows in GroundPA are CLI-first. A separate DiagramCore project is not required for the supported command surface.

## Recommended Workspace

Keep specs, Newick files, generated diagrams, and optional QA output in a task-local directory:

```text
GroundPA Toolkit Workplace/
  diagram/
    specs/
    figures/
    analysis/
```

## Smoke Commands

Flowchart:

```powershell
nong diagram flowchart specs\flow.json -o figures\flow.png --json
```

Network:

```powershell
nong diagram network specs\network.json -o figures\network.png --json
```

Phylogenetic tree from Newick:

```powershell
nong diagram tree specs\tree.nwk -o figures\tree.png --json
```

Phylogenetic tree from JSON:

```powershell
nong diagram tree specs\tree.json -o figures\tree-json.png --json
```

Optional structural image QA:

```powershell
nong ocr analyze-image figures\tree.png -o analysis\tree --json
```

The QA command checks dimensions, whitespace, blankness, and content regions. It is not OCR, text recognition, or semantic understanding.

## Minimal Tree Input

`specs\tree.nwk`:

```text
((A:0.1,B:0.2):0.3,C:0.4);
```

`specs\tree.json`:

```json
{
  "type": "tree",
  "newick": "((A:0.1,B:0.2):0.3,C:0.4);",
  "radial": false
}
```

## Error Handling

Use `--json` and treat `status: "error"` as failure. For validation or internal parse errors, fix the JSON or Newick input and rerun the same command.

## Boundary

Do not install diagram libraries or build custom rendering projects for GroundPA routing. The current implemented diagram surface is `flowchart`, `network`, and `tree`.
