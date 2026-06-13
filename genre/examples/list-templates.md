# 列出可用模板

## 用户想要什么

看看有哪些写作模板可用（论文、公文、报告等）。

## 做了什么

```powershell
nong genre list --json
```

## 结果

```json
{
  "status": "ok",
  "command": "genre list",
  "data": {
    "templates": [
      {"id": "agricultural-paper", "name": "农业科学论文", "kind": "paper"},
      {"id": "official-document", "name": "公文", "kind": "official"},
      {"id": "experiment-report", "name": "试验报告", "kind": "report"}
    ]
  }
}
```

## 关键点

- `genre list` 是模板发现的第一步——浏览有什么可用的。
- 模板只提供写作指导和结构说明，不直接生成文档。
- 发现模板后，用 `genre show <id>` 查看模板详情，然后用 `inspect write-paper` 或 `inspect write-official` 实际生成文档。
- genre 不是写作器，是模板浏览器。
