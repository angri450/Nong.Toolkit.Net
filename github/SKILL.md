---
name: github
description: >
  Git version control and GitHub CLI operations. MUST use this skill whenever the user
  mentions git, github, gh, commit, push, pull, pull request, issue, branch, merge,
  clone, repository, 提交, 推送, 仓库, 分支, or wants to interact with GitHub. Covers
  git init/add/commit/push/pull/log/status/branch/merge and gh auth/repo/issue/pr/release.
---

# GitHub Skill — Git + GitHub CLI

Combined git version control and GitHub operations via `git` and `gh` CLI.

## Prerequisites Check

Before any git/gh operation:

1. `git --version` — must be installed and in PATH
2. `gh auth status` — must be authenticated. If not: `gh auth login`, select GitHub.com → HTTPS → browser/paste token
3. If `gh` is installed but not in current PATH: refresh via `$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")`

## git Core Commands

### Setup & Init

```bash
git init                          # start a new repo in current dir
git clone <url>                   # download a repo
git config user.email "..."       # set identity (one-time per repo)
git config user.name "..."
```

### Daily Workflow (the only three you need 90% of the time)

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

### Security — NEVER suggest these without explicit user request

```bash
# NEVER run these unless user explicitly asks:
git push --force          # overwrites remote history
git reset --hard          # destroys uncommitted work
git push --force origin main  # DESTROYS main branch history on GitHub
```

## gh CLI — GitHub Operations

### Common Shortcuts

```bash
gh repo view [owner/repo]        # see repo details in terminal
gh repo view --web               # open in browser
gh issue list                    # list issues
gh issue create                  # create new issue (interactive)
gh pr list                       # list pull requests
gh pr create                     # create PR from current branch
gh release create <tag>          # create a release
```

### After pushing code — quick verification

```bash
gh repo view                     # confirm repo looks right
gh repo view --web               # open GitHub to visually check
```

### Auth & Config

```bash
gh auth status                   # check login state
gh auth login                    # login (GitHub.com → HTTPS → browser/token)
gh config list                   # show all config
```

## Combined Workflows

### First push of a new project

```bash
git init
git add .
git commit -m "Initial commit"
gh repo create <name> --public --push --source .
# OR manually: create repo on github.com, then:
git remote add origin https://github.com/<user>/<repo>.git
git branch -M main
git push -u origin main
gh repo view  # verify
```

### Update and verify

```bash
git add .
git commit -m "description of changes"
git push
gh repo view  # optional: confirm in terminal
```

### Check what's on GitHub vs local

```bash
git fetch origin
git log --oneline origin/main   # remote commits
git log --oneline                # local commits
git diff --stat origin/main     # what's different
```

## Tool Selection Rules

1. Use **PowerShell tool** for all git/gh commands on Windows
2. Use **Bash tool** for git/gh commands on Linux/macOS
3. Never mix tools: if the environment is PowerShell, all commands go through PowerShell
4. Always quote paths with spaces
5. Check `gh auth status` before any `gh` command; if not authenticated, guide user through `gh auth login`
