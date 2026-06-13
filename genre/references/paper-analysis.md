# Paper Analysis — Academic Paper Diagnosis via Nong.Genre

All analysis goes through `dotnet run --project <GenreWriter-path> -- <subcommand> <input>`.

## Available Analyzers

### PaperTypeClassifier — 论文类型分类

```
dotnet run --project <path> -- classify <text-file>
```

Classifies text into 16 paper types. Returns `List<PaperTypeInfo>`:

| Property | Description |
|----------|-------------|
| 论文类型 | Type name (e.g. "实验研究", "综述", "调查研究") |
| 当前匹配度 | Match score (0-100%) |
| 推荐数据 | Recommended data types |
| 推荐方法 | Recommended methods |

### PaperStructureExtractor — 论文结构提取

```
dotnet run --project <path> -- structure <text-file>
```

Returns `PaperStructure`:

| Property | Description |
|----------|-------------|
| Title | Paper title |
| Authors | Author names |
| Abstract | Abstract text |
| Keywords | Keywords |
| Sections | List of sections with canonical labels |

14 canonical section types: abstract, keywords, introduction, literature_review, theory, research_question, method, data, variables, results, discussion, conclusion, references, appendix.

### PaperDiagnostics — 论文质量诊断

```
dotnet run --project <path> -- diagnose <paper.docx>
```

Four diagnostic methods:

| Method | What it checks |
|--------|---------------|
| `DiagnoseEvidenceChain` | Evidence chain completeness — are claims backed? |
| `DiagnoseDataRequirements` | Data requirement satisfaction — enough data for claims? |
| `DiagnoseGapGrade` | Gap grade — severity of missing data/evidence |
| `DiagnosePaperQuality` | Overall paper quality score |

### ReferenceAnalyzer — 参考文献解析

```
dotnet run --project <path> -- references <text-file>
```

Capabilities:
- `ExtractReferences(text)` — parse references from text, returns `List<ReferenceInfo>`
- `CheckReferenceRisks(refs)` — check for missing fields, format issues, retracted papers
- `BuildLiteratureSearchStrategy(refs)` — suggest additional literature to search

### VariablePlanGenerator — 变量方案生成

```
dotnet run --project <path> -- variable-plan <text-file>
```

Generates:
- `GenerateVariablePlan(text)` — variable operationalization table
- `GenerateDataCollectionPlan(text)` — data collection strategy

## Full Pipeline

```
dotnet run --project <path> -- analyze <paper.docx>
```

Runs the complete diagnosis pipeline: classify → structure → diagnose → references. Outputs all results to stdout.

## Analysis Workflow

1. User provides a paper (text or docx)
2. Determine what they want:
   - "What type of paper is this?" → classify
   - "Extract the structure" → structure
   - "Check quality / find problems" → diagnose
   - "Check references" → references
   - "Help me design variables" → variable-plan
   - "Full analysis" → analyze
3. Run the appropriate dotnet command
4. Present results in Chinese, with clear sections
5. For quality issues, suggest concrete fixes
