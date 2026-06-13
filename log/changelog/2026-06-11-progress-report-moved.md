# 2026-06-11 progress-report 移入 .claude/skills/

## What changed

`progress-report` skill 从公开 plugin 面移除，移入 `.claude/skills/` 作为开发者内部工具。

## Why

`progress-report` 是用 `nong progress report` 读取 `log/` 目录生成项目报告的开发工具。它是项目维护者用的，不是 Nong CLI 的终端用户需要的。放在公开 plugin 里会让用户安装一个他们用不上的 skill。

现在的位置：
- `.claude/skills/progress-report/` — Claude Code 自动加载，只在开发者机器上生效
- 已从 plugin.json、skills.sh.json、skill.zh、CLAUDE.md、README 中移除

## Files touched

- `.claude/skills/progress-report/` — 新增（原位置为公开 skill 目录）
- `.claude-plugin/plugin.json` — 移除 progress-report
- `skills.sh.json` — 移除
- `skill.zh` — 移除
- `CLAUDE.md` — 移除
- `README.md` / `README.zh-CN.md` — 移除
- `progress-report/` — 删除

## Plugin 面变更

- 17 skills → 16 skills
- 公开 skill: word, pdf, literature, inspect, excel, chart, diagram, pptx, ocr, genre, icons, slice, skill-grader, skill-breeder, skill-tester, skill-pruner
