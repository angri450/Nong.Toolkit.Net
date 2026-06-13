---
name: diagram
description: >
  Scientific diagram generator — flowcharts, network graphs, phylogenetic trees, mechanism diagrams.
  MUST use this skill when the user wants to create flowcharts, network diagrams, phylogenetic trees,
  system trees, process diagrams, or any scientific/technical illustrations. Also trigger when the
  user mentions flowchart, network graph, phylogenetic tree, 流程图, 网络图, 系统发育树,
  机制图, 关系图, Newick, diagram, illustration — even if they do not explicitly say "diagram".
---

# DiagramCore — Scientific Diagram Generator

Three capabilities, loaded on demand:

- **Flowchart** (process diagrams) → load [diagram-api.md](references/diagram-api.md)
- **Network** (relationship graphs) → load [diagram-api.md](references/diagram-api.md)
- **Tree** (phylogenetic trees) → load [diagram-api.md](references/diagram-api.md)

## Dependencies

- .NET SDK (`dotnet` command available)

If missing, stop immediately and tell the user to install. Do not attempt to fix.

## Dispatch Logic

1. User mentions "flowchart", "process", "workflow", "流程图", "流程", "工作流" → **flowchart mode**
2. User mentions "network", "relationship", "graph", "网络图", "关系图", "图谱" → **network mode**
3. User mentions "tree", "phylogenetic", "Newick", "系统发育树", "进化树", "树状图" → **tree mode**
4. User mentions "bioicons", "icon", "图标", "素材" → **icon sheet mode**

## Cross-Skill Flow

| Step | Skill | Role |
|------|-------|------|
| 1. Data preparation | Excel | Create .xlsx with raw data |
| 2. Statistical analysis | Chart | ANOVA + Duncan → significance letters |
| 3. Chart generation | Chart | Bar charts with error bars + significance |
| 4. Diagram generation | Diagram | Flowcharts, network graphs, phylogenetic trees |
| 5. Paper insertion | Word | Insert figures into academic paper |

## Core Operations

### Flowchart (Sugiyama layout)

```powershell
dotnet run --project <project-path>
```

Generates flowchart PNG. Typical flow: `Graph` → `SugiyamaLayout` → `FlowchartRenderer` → PNG output.

### Network (Force-directed layout)

```powershell
dotnet run --project <project-path>
```

Generates network graph PNG. Typical flow: `Graph` → `ForceDirectedLayout` → `NetworkGraphRenderer` → PNG output.

### Tree (Newick format)

```powershell
dotnet run --project <project-path>
```

Generates phylogenetic tree PNG. Typical flow: `NewickTree.Parse()` → `TreeLayout` → `TreeRenderer` → PNG output.

### Icon Sheet

```powershell
dotnet run --project <project-path>
```

Generates bioicons sheet PNG with all 40 scientific icons organized by category.

### Validate

```powershell
.\scripts\validate-diagram.ps1 <output.png>
```

Checks: file exists → non-zero size → reasonable dimensions. Reports PASS/FAIL.

## Workspace

First use: create the .NET project:

```powershell
dotnet new console -n DiagramWriter -o <target-dir> --force
dotnet add <target-dir> package Angri450.Nong.Diagram
```

Then write a `Program.cs` template. See [workspace-setup.md](references/workspace-setup.md) for the full template and details.

After setup, each session only modifies `Program.cs` in `~/Documents/GroundPA Toolkit Workplace/diagram/`. Output goes to `~/Documents/GroundPA Toolkit Workplace/output/`.

## Icon Library

40 scientific SVG icons across 6 categories: Biology, Chemistry, Medical, LabEquipment, Arrows, Experimental.
Use `DiagramBuilder.BioIconSheet()` to generate a preview sheet of all available icons.
