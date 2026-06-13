# Paper Analysis — Paper Quality Diagnosis Module

DocxCore v2.0 includes a built-in paper analysis pipeline for paper quality diagnosis.

## Quick Start

```csharp
using DocxCore;

// 1. Paper type classification (16 types)
var types = PaperTypeClassifier.Classify(paperText);
var topType = types[0]; // Highest match

// 2. Paper structure extraction
var structure = PaperStructureExtractor.BuildPaperStructure(paperText);

// 3. Variable operationalization table
var variables = VariablePlanGenerator.GenerateVariablePlan(paperText, topType.论文类型);
var plan = VariablePlanGenerator.GenerateDataCollectionPlan(topType.论文类型, variables);

// 4. Reference risk checks
var refs = ReferenceAnalyzer.ExtractReferences(paperText);
var risks = ReferenceAnalyzer.CheckReferenceRisks(paperText, refs);
var strategy = ReferenceAnalyzer.BuildLiteratureSearchStrategy(structure.Keywords, topType.论文类型);

// 5. Paper quality diagnosis
var evidence = PaperDiagnostics.DiagnoseEvidenceChain(paperText, structure.Sections);
var dataReqs = PaperDiagnostics.DiagnoseDataRequirements(paperText);
var gap = PaperDiagnostics.DiagnoseGapGrade(evidence, dataReqs, types);
var quality = PaperDiagnostics.DiagnosePaperQuality(paperText, evidence, dataReqs, gap, structure.Sections);
var semantics = PaperDiagnostics.DiagnoseResearchDesignSemantics(paperText, topType.论文类型);
var chartTips = PaperDiagnostics.RecommendChartsAndTables(paperText, topType.论文类型);
```

## Paper Types (16)

| Type | Example Keywords |
|------|-----------------|
| Questionnaire-based | 问卷, 量表, Likert, 信度, 效度 |
| Experimental | 实验, 实验组, 控制组, 随机, 前测, 后测 |
| Quasi-experimental / DID | DID, 双重差分, 政策冲击, 处理组, 平行趋势 |
| PSM | PSM, 倾向得分, 平衡性, common support |
| Interview-based | 访谈, 半结构, 受访者, 扎根理论 |
| Fieldwork | 田野, 参与观察, 田野日志 |
| Content analysis | 内容分析, 编码表, 编码员, 一致性 |
| Case study | 案例, 个案, 过程追踪 |
| Mixed methods | 混合方法 |
| Secondary database | 数据库, 面板数据, 年鉴 |
| Literature review | 文献综述, 系统综述 |
| Theoretical | 理论阐释, 理论建构, 概念框架 |
| Undergraduate thesis | 本科, 毕业论文 |
| Master's thesis | 硕士, 学位论文 |
| Doctoral thesis | 博士, 博士学位 |
| Journal submission / Grant proposal | 投稿, 期刊, 课题, 申报 |

## Diagnosis Pipeline

### 1. Evidence Chain (10 items)

```
Research question clarity → Subject specificity → Concept clarity →
Hypothesis testability → Variable-answer alignment →
Causal language support → Evidence-sufficiency for conclusions →
Discussion over-extrapolation → Contribution overclaiming →
Theory without empirical support
```

Each item outputs: status (adequate/inadequate), main issue, fix suggestion, priority.

### 2. Data Requirements (9 items)

```
Has data support → Data source clarity → Sample size adequacy →
Sampling rationale → Variable operationalization → Measurement tools →
Method-data type match → Robustness/heterogeneity needed →
Qualitative supplement needed
```

### 3. Gap Grade (A-E)

| Grade | Criteria |
|-------|----------|
| A | Data support adequate, only formatting needed |
| B | Data basically usable, variables or methods need strengthening |
| C | Data insufficient, need additional collection |
| D | Research question and data severely mismatched |
| E | No basis for empirical analysis |

### 4. Quality Diagnosis (3 Tiers)

- **Tier 1 — Fatal**: Causal language unsupported by design, evidence insufficient for conclusions
- **Tier 2 — Structural**: Missing data sources, incomplete variable operationalization, method mismatch
- **Tier 3 — Surface**: Inflated contribution claims, insufficient charts/tables, formatting issues

### 5. Semantic Diagnosis

Detects: causal language mismatch, correlation-as-causation, mechanism claims without evidence, mixed-methods splicing, DID/PSM identification insufficiency, contribution overclaiming.

## Variable Operationalization Table

`VariablePlanGenerator.GenerateVariablePlan()` returns a 12-column standard variable plan:

```
VariableName | ChineseLabel | Role | TheoreticalMeaning | Operationalization | DataType |
MeasurementItems | ValueRange | DataSource | Required | AnalysisUse | MissingRisk
```

`GenerateDataCollectionPlan()` returns one of 7 collection plans by paper type:
Questionnaire plan, Interview plan, Fieldwork plan, Content analysis plan, DID plan, PSM plan, Generic plan.

## Reference Risk Analysis

`ReferenceAnalyzer` provides:
- Reference block extraction (find "References" heading → split entries)
- Entry format risk checks (missing year, too short, unclear author/title)
- Citation-to-reference matching (body citation numbers vs. reference list numbers)
- Year matching checks
- Literature search strategy suggestions (CNKI, Wanfang, WoS, Scopus, Google Scholar)

All checks preserve `需要人工核查 = true` boundary. No fabricated database verification results.

## CLI Usage Example

```csharp
// In Program.cs
var text = File.ReadAllText("paper_text.txt");
var types = PaperTypeClassifier.Classify(text);
Console.WriteLine($"Paper type: {types[0].论文类型} (match: {types[0].当前匹配度}%)");
Console.WriteLine($"Recommended data: {types[0].推荐数据}");
Console.WriteLine($"Recommended methods: {types[0].推荐方法}");

var structure = PaperStructureExtractor.BuildPaperStructure(text);
Console.WriteLine($"Title: {structure.Title}");
Console.WriteLine($"Keywords: {string.Join(", ", structure.Keywords)}");

var refs = ReferenceAnalyzer.ExtractReferences(text);
var risks = ReferenceAnalyzer.CheckReferenceRisks(text, refs);
foreach (var r in risks) Console.WriteLine($"[{r.文献问题}] {r.修改建议}");
```

## Integration with DocumentWriter

```csharp
// Diagnose paper → auto-generate variable table
var types = PaperTypeClassifier.Classify(text);
var variables = VariablePlanGenerator.GenerateVariablePlan(text, types[0].论文类型);

// Embed in document
var w = new DocumentWriter(body);
w.Heading("Variable Operationalization", 2);
w.VariableTable("Variable Operationalization Table", 1, variables);
```

## Compliance Boundaries

- All diagnosis is rule-based (regex + keyword matching), not NLP/ML models
- Reference verification is offline/manual interface only — no fabricated database hits
- Diagnosis results are for method training and writing reference only — not a substitute for advisor or peer review
