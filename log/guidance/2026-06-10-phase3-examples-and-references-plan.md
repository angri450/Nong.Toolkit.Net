# 2026-06-10 Toolkit A/B 类 Skill 补 example 和 reference 详细方案

## 背景

2026-06-10 Toolkit 全量 Skill 系统审计发现：15 个 skill 中只有 `diagram` 有 examples，另外 14 个都没有。5 个 skill 缺 references。这项工作是补基础，不是改结构。

## 总则

1. A 类和 B 类 skill 的 SKILL.md 主体结构和路由方式不动（已经够用）。
2. 只补：examples/（例子）和 references/（下钻材料）。
3. 例子纪律：每个 skill 至少 1 个成功例子。高频/复杂 skill 再加 1 个失败例子或边界例子。
4. Reference 纪律：高频 skill 至少 2 份 reference。策略 skill 至少 3 份 reference。简单命令镜像 skill 最少 1 份。

## 分 skill 施工清单

### A 类（骨架已稳，补例子）

#### word

**当前**：7 份 reference，5 份 format，3 份 script。0 个 examples。

**补什么**：
```
word/examples/
  academic-format-paper.md（新增：论文格式修复例子）
  existing-docx-repair.md（新增：旧合同样式清理例子）
  table-reflow-report.md（新增：申报表表格重排例子）
  failed-com-automation.md（新增：COM 自动化失败 → 回到 nong word 的例子）
```

**不补 references**（已有 7 份，够厚）。

**估算**：1h。

#### pdf

**当前**：1 份 reference。0 个 examples。

**补什么**：
```
pdf/examples/
  text-pdf-dissect.md（新增：文字层 PDF 切片例子）
  scan-pdf-ocr.md（新增：扫描件 OCR 路由例子）
  hybrid-pdf-routing.md（新增：混合 PDF 判断例子）
```

**不补 references**（已有 1 份，方向对但偏薄；阶段三集中补）。

**估算**：40min。

#### literature

**当前**：1 份 reference。0 个 examples。

**补什么**：
```
literature/examples/
  doi-lookup.md（新增：DOI 查找和元数据获取）
  complex-query.md（新增：复杂检索式例子）
  provider-failure.md（新增：某个 provider 失败时的处理）
```

**不补 references**（已有 1 份，够用）。

**估算**：30min。

#### chart

**当前**：2 份 reference，1 份 format，2 份 script。0 个 examples。

**补什么**：
```
chart/examples/
  anova-duncan-bar.md（新增：ANOVA+Duncan+柱状图完整流）
  bad-input-json.md（新增：输入 JSON 坏了怎么修）
  scatter-with-groups.md（新增：分组散点图例子）
```

**不补 references**（已有 2 份，够用）。

**估算**：30min。

#### excel

**当前**：3 份 reference，6 份 format，2 份 script。0 个 examples。

**补什么**：
```
excel/examples/
  read-to-statistics.md（新增：读表→to-groups→chart 的完整管线）
  create-simple-workbook.md（新增：从 JSON 创建简单 workbook）
  multi-sheet-workbook.md（新增：多 sheet 读取例子）
```

**不补 references**（已有 3 份，够用）。

**估算**：30min。

#### diagram

**当前**：2 份 reference，1 份 script。**已有 examples/** 目录。已有 examples/flowchart-success.md 和 examples/network-success.md。

**补什么**：
```
diagram/examples/
  tree-newick.md（新增：Newick 系统发育树例子）
  diagram-bad-input.md（新增：输入描述不够时怎么补）
```

**不补 references**（已有 2 份，够用）。

**估算**：20min。

### B 类（方向对但偏薄，补 references + examples）

#### skill

**当前**：CLI 镜像型，命令面直接对应 `nong skill validate/scan/inventory/package`。0 个 references，0 个 examples。

**补什么**：
```
skill/references/
  skill-lifecycle.md（新增：validate→scan→inventory→package 的标准管线）
  security-scan-解读.md（新增：scan 的输出怎么看、High/Medium/Low 各怎么处理）

skill/examples/
  validate-success.md（新增：对单个 skill 跑 validate）
  package-plugin.md（新增：打包整个 plugin）
  scan-has-findings.md（新增：scan 发现问题的处理流程）
```

**估算**：40min。

#### slice

**当前**：CLI 镜像型，命令面直接对应 `nong slice inspect/blocks/block/assets`。0 个 references，0 个 examples。

**补什么**：
```
slice/references/
  slice-package-contract.md（新增：统一切片包的 manifest/document/content/structure/format/assets 结构说明）

slice/examples/
  read-word-slice.md（新增：读一个 Word 切片包的例子）
  read-pdf-slice.md（新增：读一个 PDF 切片包的例子）
  block-level-evidence.md（新增：块级证据追踪例子）
```

**估算**：30min。

#### pptx

**当前**：3 份 reference，7 份 format，2 份 script。0 个 examples。当前能力为只读。

**补什么**：
```
pptx/examples/
  read-slides.md（新增：读取 PPT slide 列表）
  dissect-slide.md（新增：切片单个 slide）
```

**不补 references**（已有 3 份，够用）。SKILL.md 继续保持"当前只读"口径。

**估算**：20min。

#### genre

**当前**：3 份 reference，1 份 script。0 个 examples。

**补什么**：
```
genre/examples/
  list-templates.md（新增：列出可用模板）
  show-template.md（新增：查看某个模板的内容）
  template-to-inspect.md（新增：发现模板后交给 inspect write-paper）
```

**不补 references**（已有 3 份，够用）。

**估算**：20min。

#### inspect

**当前**：1 份 reference。0 个 examples。

**补什么**：
```
inspect/references/
  diagnose-steps.md（新增：diagnose 的 7 步诊断详解）
  write-paper-spec.md（新增：write-paper 的 JSON spec 格式）
  write-official-spec.md（新增：write-official 的 JSON spec 格式）

inspect/examples/
  paper-diagnose.md（新增：论文全诊断流程）
  gongwen-write.md（新增：公文生成流程）
  refs-check-vs-lit-search.md（新增：inspect refs 和 lit search 的区别）
```

**估算**：50min。

## 汇总

| Skill | 分类 | 补 examples | 补 references | 估时 |
|-------|------|------------|--------------|------|
| word | A | 4 个 | 0（已够） | 1h |
| pdf | A | 3 个 | 0（暂不补） | 40min |
| literature | A | 3 个 | 0（已够） | 30min |
| chart | A | 3 个 | 0（已够） | 30min |
| excel | A | 3 个 | 0（已够） | 30min |
| diagram | A | 2 个 | 0（已够） | 20min |
| skill | B | 3 个 | 2 个 | 40min |
| slice | B | 3 个 | 1 个 | 30min |
| pptx | B | 2 个 | 0（已够） | 20min |
| genre | B | 3 个 | 0（已够） | 20min |
| inspect | B | 3 个 | 3 个 | 50min |
| **合计** | | **32 个** | **6 个** | **≈5.5h** |

C 类 4 个 skill（ocr/skill-manager/progress-report/icons）已在 `2026-06-10-phase2-c-class-skill-rewrite-plan.md` 中规划。

## 执行方式

按模块分批，每批做完验证一次，不一次全部改完。

**批次 1**：word + pdf + literature（三个 A 类高频 skill，1h50min）
**批次 2**：chart + excel + diagram（三个 A 类数据 skill，1h20min）
**批次 3**：skill + slice + pptx + genre（四个 B 类镜像 skill，1h50min）
**批次 4**：inspect（一个 B 类复杂 skill，50min）

## 例子格式规范

每个 example 文件统一结构：

```markdown
# 场景名

## 用户想要什么
（一句话描述用户意图）

## 做了什么
（CLI 命令序列，带实际参数）

## 结果
（输出摘要 / 验证方法）

## 关键点
（这个例子说明什么边界、什么规则、什么常见错误）
```

## 验证

每批改完跑：
```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill validate .\<skill> --json
```

全部改完跑：
```powershell
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill inventory . --json
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill scan . --json
..\Nong.Cli.Net\Cli\bin\Release\net8.0\nong.exe skill package . --json
```

## 不改什么

- 不改任何 SKILL.md 的主体结构和路由方式
- 不改 CLI
- 不改 plugin.json / marketplace.json / skills.sh.json（除非 example 引入新文件引用）
- 不改 C 类 skill（另有独立 plan）

## 状态

plan — **DONE**。2026-06-10 已完工。11 个 A/B 类 skill 补 32 个 examples + 6 个 references。全部 15 skill validate 通过，scan 0 findings，package 成功。
