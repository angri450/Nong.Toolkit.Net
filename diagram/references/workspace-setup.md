# Diagram Skill — Workspace Setup

本文档说明如何设置 Diagram skill 的工作区。

## 1. 创建 .NET 项目

```powershell
# 创建输出目录
mkdir -p ~/Documents/GroundPA Toolkit Workplace/output

# 创建工作目录和项目
mkdir -p ~/Documents/GroundPA Toolkit Workplace/diagram
cd ~/Documents/GroundPA Toolkit Workplace/diagram
dotnet new console -n DiagramWriter
cd DiagramWriter
dotnet add package Angri450.Nong.Diagram
```

## 2. Program.cs 模板

```csharp
using DiagramCore;
using DiagramCore.Models;

// 输出目录
string outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outDir);

// 选择以下模板之一

// === 流程图模板 ===
var graph = new Graph();
graph.AddNode("A", "Step 1");
graph.AddNode("B", "Step 2");
graph.AddNode("C", "Step 3");

graph.AddEdge("A", "B");
graph.AddEdge("B", "C");

DiagramBuilder.Flowchart(graph, Path.Combine(outDir, "workflow.png"));

// === 网络图模板 ===
var network = new Graph();
network.AddNode("Node1", "Node 1");
network.AddNode("Node2", "Node 2");
network.AddNode("Node3", "Node 3");
network.AddNode("Node4", "Node 4");

network.AddEdge("Node1", "Node2");
network.AddEdge("Node2", "Node3");
network.AddEdge("Node3", "Node4");
network.AddEdge("Node4", "Node1");

DiagramBuilder.NetworkGraph(network, Path.Combine(outDir, "network.png"));

// === 系统发育树模板 ===
var newick = "((A:0.1,B:0.2):0.3,(C:0.4,D:0.5):0.6);";
DiagramBuilder.PhylogeneticTree(newick, Path.Combine(outDir, "tree.png"));

// === 图标表模板 ===
DiagramBuilder.BioIconSheet(Path.Combine(outDir, "icons.png"));
```

## 3. 运行

```powershell
dotnet run
```

输出文件将保存在 `~/Documents/GroundPA Toolkit Workplace/output/` 目录下。

## 4. 验证输出

```powershell
.\scripts\validate-diagram.ps1 ~/Documents/GroundPA Toolkit Workplace/output/workflow.png
```

## 5. 目录结构

```
~/Documents/GroundPA Toolkit Workplace/diagram/              # 工作目录（代码）
└── DiagramWriter/
    ├── Program.cs                # 每次修改此文件
    ├── DiagramWriter.csproj
    └── bin/

~/Documents/GroundPA Toolkit Workplace/output/               # 输出目录（图表）
├── workflow.png
├── network.png
├── tree.png
└── icons.png
```

## 6. 工作流程

1. 修改 `~/Documents/GroundPA Toolkit Workplace/diagram/DiagramWriter/Program.cs` 定义图表内容
2. 在 `~/Documents/GroundPA Toolkit Workplace/diagram/DiagramWriter/` 下运行 `dotnet run`
3. 输出自动保存到 `~/Documents/GroundPA Toolkit Workplace/output/`
4. 运行 `validate-diagram.ps1` 验证输出
5. 将生成的 PNG 插入到 Word 文档中（使用 Word skill）

## 7. 常见问题

### 输出文件在哪里？

默认输出到 `~/Documents/GroundPA Toolkit Workplace/output/`。Program.cs 模板中已包含输出目录设置：

```csharp
string outDir = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output",
    $"<timestamp>+<project>+<seq>");
Directory.CreateDirectory(outDir);
```

### 如何更改输出路径？

在 `DiagramBuilder` 方法中指定完整路径：

```csharp
var customPath = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    "GroundPA Toolkit Workplace", "output", "my_chart.png");
DiagramBuilder.Flowchart(graph, customPath);
```

### 如何调整图表大小？

所有 `DiagramBuilder` 方法都接受 `width` 和 `height` 参数：

```csharp
DiagramBuilder.Flowchart(graph, "chart.png", width: 1200, height: 800);
DiagramBuilder.NetworkGraph(network, "net.png", width: 1000, height: 1000);
DiagramBuilder.PhylogeneticTree(newick, "tree.png", width: 800, height: 600);
```

### 系统发育树的 Newick 格式是什么？

Newick 格式是系统发育树的标准文本表示法：

```
((A:0.1,B:0.2):0.3,(C:0.4,D:0.5):0.6);
```

- `A`, `B`, `C`, `D` 是叶节点名称
- `:0.1` 是分支长度
- 括号表示层级关系
- 以分号 `;` 结尾
