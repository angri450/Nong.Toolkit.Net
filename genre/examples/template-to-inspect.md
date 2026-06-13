# 模板发现后交给 Inspect 写作

## 用户想要什么

找到农业论文模板后，按模板结构生成论文 DOCX。

## 完整流程

```powershell
# 1. 找到需要的模板
nong genre list --json
nong genre show agricultural-paper --json

# 2. 根据模板的 sections 准备 JSON spec
echo '{
  "title": "氮肥施用对玉米产量和品质的影响",
  "authors": ["张三", "李四"],
  "abstract": "...",
  "sections": [
    {"heading": "引言", "content": ["..."]},
    {"heading": "材料与方法", "content": ["..."]},
    {"heading": "结果与分析", "content": ["..."]},
    {"heading": "讨论", "content": ["..."]},
    {"heading": "结论", "content": ["..."]}
  ],
  "references": ["参考文献1", "参考文献2"]
}' > paper-spec.json

# 3. 生成论文 DOCX
nong inspect write-paper paper-spec.json -o paper.docx --json

# 4. 格式验证
nong word format-audit paper.docx --json
nong word academic-format paper.docx -o paper.final.docx --json
```

## 结果

模板提供了章节结构指导 → JSON spec 按模板填充内容 → `inspect write-paper` 生成 DOCX → `word academic-format` 修格式 → 最终产物。

## 关键点

- `genre` 是发现层（"有什么模板可用"），`inspect` 是执行层（"按模板生成文档"），`word` 是格式层（"修到交付标准"）。
- 不要跳步：不能看了模板就直接用 `word create`——`word create` 是 NongMark 到 DOCX，不是论文 JSON spec 到 DOCX。
- `inspect write-paper` 输出的 DOCX 是根据 spec 生成的新文件，不是对已有 DOCX 的修改。
