# 查看模板详情

## 用户想要什么

想写一篇农业科学论文，需要知道模板要求的章节结构、数据格式和引用规范。

## 做了什么

```powershell
nong genre show agricultural-paper --json
```

## 结果

```json
{
  "status": "ok",
  "command": "genre show",
  "data": {
    "id": "agricultural-paper",
    "name": "农业科学论文",
    "kind": "paper",
    "sections": [
      "标题与作者",
      "摘要与关键词",
      "引言",
      "材料与方法",
      "结果与分析",
      "讨论",
      "结论",
      "参考文献"
    ],
    "formatRequirements": {
      "references": "GB/T 7714",
      "tables": "三线表",
      "statistics": "ANOVA + Duncan MRT"
    }
  }
}
```

## 关键点

- `genre show <id>` 告诉你模板里有什么——章节要求、格式规范、数据要求。
- 模板是指导性文档，不自动生成内容。你需要根据模板 spec 准备 JSON，然后交给 `inspect write-paper` 生成。
- 如果模板的格式要求和 Word 的命令对应不上（如"三线表"对应 `word academic-format`），需要在生成之后再做格式修复。
