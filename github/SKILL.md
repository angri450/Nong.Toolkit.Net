---
name: github
description: >
  Git version control and GitHub CLI. Trigger on git init, commit, push, pull,
  branch, merge, clone, gh repo, gh issue, gh pr, gh release, or gh actions.
  git init/add/commit/push/pull/log/status/branch/merge and gh auth/repo/issue/pr/release/
  actions/search/projects/gist/label/secret/api/codespace.
---

# GitHub Skill — Git + GitHub CLI

Combined git version control and GitHub operations via `git` and `gh` CLI.

## Prerequisites

1. `git --version` — must be installed and in PATH
2. `gh auth status` — must be authenticated. If not: `gh auth login`, select GitHub.com → HTTPS → browser/paste token
3. On Windows, refresh PATH if gh not found: `$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")`

## Dispatch Logic

| 用户意图 | 关键词 | 参考 |
|---------|--------|------|
| Git 基本操作 | "git init", "clone", "commit", "push", "pull", "branch", "merge", "rebase", "reset" | 见下方 git Core Commands |
| Repo 操作 | "创建仓库", "fork", "clone", "view repo", "delete repo" | [gh-cli.md](references/gh-cli.md) §2 |
| Issue | "issue", "bug", "feature", "label", "close issue" | [gh-cli.md](references/gh-cli.md) §3 |
| PR | "PR", "pull request", "review", "merge", "draft" | [gh-cli.md](references/gh-cli.md) §4 |
| Actions/CI | "action", "workflow", "run", "rerun", "log" | [gh-cli.md](references/gh-cli.md) §5 |
| Release | "release", "发版", "changelog", "tag" | [gh-cli.md](references/gh-cli.md) §6 |
| Gist | "gist", "代码片段" | [gh-cli.md](references/gh-cli.md) §7 |
| Search | "搜索", "search", "找代码" | [gh-cli.md](references/gh-cli.md) §8 |
| Labels | "label", "标签", "clone labels" | [gh-cli.md](references/gh-cli.md) §9 |
| Secrets/Variables | "secret", "密码", "环境变量", "env" | [gh-cli.md](references/gh-cli.md) §10 |
| Projects V2 | "project", "项目", "board", "看板" | [gh-cli.md](references/gh-cli.md) §12 |
| API | "api", "graphql", "REST" | [gh-cli.md](references/gh-cli.md) §13 |
| Codespaces | "codespace", "云开发" | [gh-cli.md](references/gh-cli.md) §15 |

完整 gh CLI 参考: [gh-cli.md](references/gh-cli.md)
开发与发布经验: [lessons-learned.md](../gitee/references/lessons-learned.md) (21 节, 覆盖所有 gh 命令)

## git Core Commands

### Setup & Init

```bash
git init                          # start a new repo in current dir
git clone <url>                   # download a repo
git config user.email "..."       # set identity (one-time per repo)
git config user.name "..."
```

### Daily Workflow

```bash
git add .                         # stage everything
git commit -m "message"           # save with description
git push origin main              # upload to GitHub
```

### Checking Status

```bash
git status                        # what's changed, staged, pending
git log --oneline                 # recent commits, compact
git log --oneline origin/main     # what's on GitHub
git diff                          # unstaged changes
git diff --stat origin/main       # what differs from GitHub
```

### Remote Operations

```bash
git remote -v                     # show remote URLs
git remote add origin <url>       # link to GitHub repo
git push -u origin main           # first push, set upstream
git pull origin main              # fetch + merge remote changes
git fetch origin                  # download without merging
```

### Branching

```bash
git branch                        # list local branches
git branch -M main                # rename current branch
git checkout -b <name>            # create and switch to new branch
git checkout main                 # switch back to main
```

### Undoing / Fixing

```bash
git reset HEAD <file>             # unstage a file
git checkout -- <file>            # discard local changes (DANGEROUS)
git commit --amend -m "new msg"   # fix last commit message (before push)
git reset --soft HEAD~1           # undo last commit, keep changes staged
```

### Security — NEVER suggest without explicit user request

```bash
git push --force          # overwrites remote history
git reset --hard          # destroys uncommitted work
git push --force origin main  # DESTROYS main branch history
```

## Combined Workflows

### First push of a new project

```bash
git init
git add .
git commit -m "Initial commit"
gh repo create <name> --public --push --source .
```

### Update and verify

```bash
git add .
git commit -m "description of changes"
git push
```

### Check what's on GitHub vs local

```bash
git fetch origin
git log --oneline origin/main
git log --oneline
git diff --stat origin/main
```

## Cross-Skill Flow

| Step | Skill | Role |
|------|-------|------|
| 1. 研究需求 | Gitee / GitHub | 浏览 Issue, 搜索代码 |
| 2. 编写代码 | dotnet / bash / powershell | 实际编码 |
| 3. 提交代码 | GitHub (git + gh pr) | 提交 PR, 关联 Issue |
| 4. CI 检查 | GitHub (gh run/checks) | 查看 CI 状态 |
| 5. 发布版本 | GitHub (gh release) | 创建 Release |

## Tool Selection Rules

1. Use **PowerShell tool** for all git/gh commands on Windows
2. Use **Bash tool** for git/gh commands on Linux/macOS
3. Never mix tools: if the environment is PowerShell, all commands go through PowerShell
4. Always quote paths with spaces
5. Check `gh auth status` before any `gh` command
