# Skill 层问题：2026-06-10 CLI 对齐审查

日期：2026-06-10

## 审查范围

- nong-toolkit 2.4.0 全部 15 个 skill（word/pdf/literature/inspect/excel/chart/diagram/pptx/ocr/genre/icons/slice/skill/skill-manager/progress-report）
- `nong skill validate` / `nong skill scan` / `nong skill inventory` 三项校验
- SKILL.md 示例代码与实际 CLI 行为的一致性
- eval 覆盖率

## Findings

### HIGH — `inspect/SKILL.md` 第 55-65 行 — write-paper JSON spec 示例用 `"body"` 字段，实际 CLI 接受 `"content"`

inspect/SKILL.md 的 paper spec 示例写的是：

```json
{
  "title": "Title",
  "sections": [
    {
      "heading": "1 Introduction",
      "level": 1,
      "body": ["Paragraph one.", "Paragraph two."]
    }
  ]
}
```

但实际 CLI 验证器要求的是 `"content"` 字段（`references/write-paper-spec.md` 文档是对的）。模型如果抄 SKILL.md 的 `"body"` 示例会直接吃 E006 validation_failed。需要把 SKILL.md 的 `"body"` 改为 `"content"`。

**影响**：inspect skill，write-paper 路径。

### MEDIUM — `inspect/references/write-paper-spec.md` — `keywords` 字段类型声明为 `string[]`，实际 CLI 要求分号分隔的 `string`

`write-paper-spec.md` 的字段表写的是 `"type": "string[]"`，并且示例是：

```json
"keywords": ["关键词1", "关键词2"]
```

但实际 CLI 的 E006 校验要求分号分隔的字符串格式 `"keyword1; keyword2"`。传数组直接报错。要么 CLI 放宽为接受数组，要么文档改为字符串并注明分隔符。

**影响**：inspect skill，write-paper 路径。

### MEDIUM — `nong skill validate` 对插件根目录报错信息不友好

在 plugin 根目录运行 `nong skill validate . --json` 返回：

```json
{ "message": "SKILL.md not found in skill directory" }
```

这没错，但它不提示插件下有 15 个 skill、应该对单个 skill 目录 validate。新用户看到这个会困惑，不知道下一步。建议增加 hint："This is a plugin root with 15 skills; validate individual skill directories instead."

**影响**：skill skill，validate 命令。

### MEDIUM — 全部 15 个 skill 缺少 eval（`hasEvals: false`, `evalsFiles: 0`）

没有一个 skill 有 eval 文件。这意味着：

- nong CLI 升级后，skill 描述与 CLI 实际行为是否一致无法自动检测。
- `nong skill package` 的 blind eval gate 永远不触发。
- 回归风险完全依赖人工审查。

建议至少为核心 skill（word/inspect/chart/literature）各补一个最小 eval set。

**影响**：所有 skill，质量保证体系。

## skill scan 结果

```
0 findings, 0 High+
```

安全扫描通过，无阻塞项。

## skill inventory 统计

| 指标 | 值 |
|------|-----|
| skill 总数 | 15 |
| 总文件数 | 65 |
| SKILL.md 覆盖 | 15/15 |
| eval 覆盖 | 0/15 |
| plugin.json | 有 |
| marketplace.json | 有 |
| skills.json | 有 |
