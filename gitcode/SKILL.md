---
name: gitcode
description: >
  GitCode platform operations. Trigger on gitcode, create issue, create PR,
  review PR, merge PR, fork, search repos, or manage GitCode projects.
---

# GitCode Skill

GitCode platform (gitcode.com) operations via REST API. No local CLI or MCP needed.

## Prerequisites

1. Obtain a [GitCode personal access token](https://gitcode.com/-/user_settings/personal_access_tokens) with scopes: `api`, `read_repository`, `write_repository`
2. Set environment variable: `GITCODE_TOKEN` (preferred) or pass as `--token` in API calls
3. Base URL: `https://gitcode.com/api/v5`

## Dispatch Logic

See [workflows.md](references/workflows.md) for detailed instructions per workflow.

| Intent | Trigger keywords | API endpoints |
|--------|-----------------|---------------|
| Auth / Status | "login", "whoami", "token" | `GET /user` |
| Create Issue | "create issue", "report bug", "feature request" | `POST /repos/{owner}/{repo}/issues` |
| Create PR | "create PR", "pull request", "open PR" | `POST /repos/{owner}/{repo}/pulls` |
| Review PR | "review", "code review", "check PR" | `GET /repos/{owner}/{repo}/pulls/{number}`, `GET /repos/{owner}/{repo}/pulls/{number}/files`, `POST /repos/{owner}/{repo}/pulls/{number}/reviews` |
| Merge PR | "merge", "merge PR" | `PUT /repos/{owner}/{repo}/pulls/{number}/merge` |
| List Repos | "list repos", "my repos", "search" | `GET /user/repos`, `GET /repos/{owner}/{repo}` |
| Create Repo | "create repo", "new repo", "init" | `POST /user/repos` |
| Fork Repo | "fork", "fork repo" | `POST /repos/{owner}/{repo}/forks` |
| Branches | "branch", "branches", "create branch" | `GET /repos/{owner}/{repo}/branches`, `POST /repos/{owner}/{repo}/branches` |
| File Ops | "read file", "update file", "create file" | `GET /repos/{owner}/{repo}/contents/{path}`, `PUT /repos/{owner}/{repo}/contents/{path}` |
| Release | "release", "publish", "changelog" | `POST /repos/{owner}/{repo}/releases` |
| Comments | "comment", "reply" | `POST /repos/{owner}/{repo}/issues/{number}/comments` |

## Authentication

All API requests need header:
```
Authorization: Bearer $GITCODE_TOKEN
Content-Type: application/json
```

Token优先从环境变量 `GITCODE_TOKEN` 读取。未设置时提示用户去 https://gitcode.com/-/user_settings/personal_access_tokens 创建。

## Common Patterns

### Create Issue
```
POST /api/v5/repos/{owner}/{repo}/issues
Body: {"title": "...", "body": "...", "labels": ["bug"], "assignee_ids": []}
```

### Create PR
```
POST /api/v5/repos/{owner}/{repo}/pulls
Body: {"title": "...", "head": "feature-branch", "base": "master", "body": "..."}
```

### Merge PR
```
PUT /api/v5/repos/{owner}/{repo}/pulls/{number}/merge
Body: {"merge_method": "squash"}
```

### Create Release
```
POST /api/v5/repos/{owner}/{repo}/releases
Body: {"tag_name": "v1.0.0", "name": "v1.0.0", "body": "Release notes"}
```

Full API reference: [api.md](references/api.md)

## Cross-Skill Flow

| Step | Skill | Role |
|------|-------|------|
| 1. Understand requirements | gitcode | Read Issue content and comments |
| 2. Locate code | gitcode | Read repo files to find relevant areas |
| 3. Write code | dotnet / bash / powershell | Actual implementation |
| 4. Submit PR | gitcode | Create PR with Conventional Commits title |
| 5. Code review | gitcode | Multi-dimension review, post findings |
| 6. Merge & Release | gitcode | Merge PR, create release with changelog |
