# DiagramCore API Reference

所有 API 位于 `DiagramCore` 命名空间。完整类型定义见 NuGet 包的 IntelliSense。

## DiagramBuilder — 统一入口

### Flowchart (流程图)

```csharp
var graph = new Graph();
graph.AddNode("A", "Sample Collection");
graph.AddNode("B", "DNA Extraction");
graph.AddNode("C", "PCR Amplification");
graph.AddNode("D", "Sequencing");
graph.AddNode("E", "Analysis");

graph.AddEdge("A", "B");
graph.AddEdge("B", "C");
graph.AddEdge("C", "D");
graph.AddEdge("D", "E");

DiagramBuilder.Flowchart(graph, "workflow.png");
```

### NetworkGraph (网络图)

```csharp
var graph = new Graph();
graph.AddNode("Gene1", "BRCA1");
graph.AddNode("Gene2", "TP53");
graph.AddNode("Gene3", "EGFR");
graph.AddNode("Gene4", "KRAS");

graph.AddEdge("Gene1", "Gene2");
graph.AddEdge("Gene2", "Gene3");
graph.AddEdge("Gene3", "Gene4");
graph.AddEdge("Gene4", "Gene1");

DiagramBuilder.NetworkGraph(graph, "network.png");
```

### PhylogeneticTree (系统发育树)

```csharp
var newick = "((Human:0.1,Chimp:0.12):0.05,(Gorilla:0.15,Orangutan:0.2):0.1);";
DiagramBuilder.PhylogeneticTree(newick, "tree.png");

// 径向布局
DiagramBuilder.PhylogeneticTree(newick, "tree_radial.png", radial: true);
```

### BioIconSheet (图标表)

```csharp
DiagramBuilder.BioIconSheet("icons.png");
```

## Graph — 图模型

```csharp
var graph = new Graph();

// 添加节点
graph.AddNode("id1", "Label 1");
graph.AddNode("id2", "Label 2");

// 添加边
graph.AddEdge("id1", "id2");

// 获取节点
var node = graph.GetNode("id1");
```

### GraphNode 属性

```csharp
var node = graph.GetNode("id");
node.X = 100;           // X 坐标
node.Y = 200;           // Y 坐标
node.Width = 80;        // 宽度
node.Height = 40;       // 高度
node.FillColor = "#E8F4F8";
node.StrokeColor = "#2C5F7D";
node.TextColor = "#1A1A1A";
```

## NewickTree — Newick 格式解析

```csharp
var tree = NewickTree.Parse(newickString);

// 属性
tree.Name           // 节点名称
tree.BranchLength   // 分支长度
tree.X, tree.Y      // 坐标（布局后设置）
tree.Children       // 子节点列表
tree.IsLeaf         // 是否为叶节点

// 方法
tree.GetLeaves()    // 获取所有叶节点
```

## Layout — 布局算法

### SugiyamaLayout (层级布局)

```csharp
var layout = new SugiyamaLayout();
layout.Layout(graph, width: 800);
```

适用于流程图、有向无环图（DAG）。基于拓扑排序的层级布局。

### ForceDirectedLayout (力导向布局)

```csharp
var layout = new ForceDirectedLayout();
layout.Layout(graph, width: 800, height: 600);
```

适用于网络图、关系图。基于 Fruchterman-Reingold 算法的力导向布局。

### TreeLayout (树布局)

```csharp
var layout = new TreeLayout();
layout.Layout(tree, width: 800, height: 600, radial: false);
layout.Layout(tree, width: 800, height: 600, radial: true);  // 径向布局
```

适用于系统发育树。支持矩形和径向两种布局。

## Renderer — 渲染器

### FlowchartRenderer

```csharp
var renderer = new FlowchartRenderer(graph);
var bitmap = renderer.RenderToBitmap(width: 800, height: 600);
renderer.Render("output.png", width: 800, height: 600);
```

### NetworkGraphRenderer

```csharp
var renderer = new NetworkGraphRenderer(graph);
var bitmap = renderer.RenderToBitmap(width: 800, height: 600);
renderer.Render("output.png", width: 800, height: 600);
```

### TreeRenderer

```csharp
var renderer = new TreeRenderer(tree);
var bitmap = renderer.RenderToBitmap(width: 800, height: 600, radial: false);
renderer.Render("output.png", width: 800, height: 600, radial: true);
```

### BioIconRenderer

```csharp
var renderer = new BioIconRenderer();
var bitmap = renderer.RenderToBitmap(width: 800, height: 600);
renderer.Render("icons.png", width: 800, height: 600);
```

## Bioicons — 科学图标库

40 个 SVG 图标，分为 6 个类别：

| 类别 | 图标 |
|------|------|
| Biology | cell, dna, protein, bacteria, virus, mitochondria, ribosome, membrane, antibody, neuron |
| Chemistry | flask, beaker, test-tube, atom, molecule, pipette |
| Medical | heart, brain, lung, kidney, syringe, microscope, petri-dish |
| LabEquipment | centrifuge, incubator, pcr-machine, gel-electrophoresis, flow-cytometer |
| Arrows | arrow-right, arrow-down, arrow-curved, arrow-double, process-arrow, inhibition |
| Experimental | sample, buffer, reagent, plate-96well, western-blot, elisa-plate |

### 在流程图节点中使用图标

```csharp
var node = graph.AddNode("sample", "Sample");
node.Shape = "icon:Biology:cell";  // 使用生物学-细胞图标
```

或者使用 `icon:category:name` 格式：

```csharp
graph.AddNode("dna", "DNA").Shape = "icon:Biology:dna";
graph.AddNode("pcr", "PCR").Shape = "icon:LabEquipment:pcr-machine";
```

## 完整示例

### 实验流程图

```csharp
using DiagramCore;
using DiagramCore.Models;

var graph = new Graph();

// 添加节点
graph.AddNode("sample", "样品采集");
graph.AddNode("dna", "DNA 提取");
graph.AddNode("pcr", "PCR 扩增");
graph.AddNode("seq", "测序");
graph.AddNode("analysis", "生物信息分析");

// 添加边
graph.AddEdge("sample", "dna");
graph.AddEdge("dna", "pcr");
graph.AddEdge("pcr", "seq");
graph.AddEdge("seq", "analysis");

// 渲染
DiagramBuilder.Flowchart(graph, "workflow.png");
```

### 系统发育树

```csharp
using DiagramCore;

var newick = @"
((Human:0.1,Chimp:0.12):0.05,
 (Gorilla:0.15,(Orangutan:0.2,Gibbon:0.25):0.1):0.08);
";

DiagramBuilder.PhylogeneticTree(newick, "tree.png");
```

### 蛋白互作网络

```csharp
using DiagramCore;
using DiagramCore.Models;

var graph = new Graph();

// 添加蛋白节点
graph.AddNode("BRCA1", "BRCA1");
graph.AddNode("TP53", "TP53");
graph.AddNode("EGFR", "EGFR");
graph.AddNode("KRAS", "KRAS");
graph.AddNode("MYC", "MYC");

// 添加互作边
graph.AddEdge("BRCA1", "TP53");
graph.AddEdge("TP53", "EGFR");
graph.AddEdge("EGFR", "KRAS");
graph.AddEdge("KRAS", "MYC");
graph.AddEdge("MYC", "BRCA1");
graph.AddEdge("BRCA1", "EGFR");

// 渲染
DiagramBuilder.NetworkGraph(graph, "protein_network.png");
```
