# GitCode API Reference

Base URL: `https://gitcode.com/api/v5`

GitCode 基于 GitLab CE，API 兼容 GitLab v4 API。

## Authentication

所有请求需要 header:
```
Authorization: Bearer <token>
Content-Type: application/json
```

Token 类型: Personal Access Token
Scope: `api`, `read_repository`, `write_repository`

## Endpoints

### User
- `GET /user` — 获取当前用户信息
- `GET /users/{id}` — 获取指定用户

### Repositories
- `GET /user/repos` — 列出用户仓库
- `GET /repos/{owner}/{repo}` — 获取仓库详情
- `POST /user/repos` — 创建仓库
  ```json
  {"name": "my-repo", "description": "...", "private": false, "default_branch": "master"}
  ```
- `DELETE /repos/{owner}/{repo}` — 删除仓库
- `PUT /repos/{owner}/{repo}` — 更新仓库设置
- `POST /repos/{owner}/{repo}/forks` — Fork 仓库

### Branches
- `GET /repos/{owner}/{repo}/branches` — 列出分支
- `POST /repos/{owner}/{repo}/branches` — 创建分支
  ```json
  {"branch_name": "feature-x", "ref": "master"}
  ```

### Files
- `GET /repos/{owner}/{repo}/contents/{path}` — 读取文件
  - 可选 `?ref=branch-or-tag`
- `PUT /repos/{owner}/{repo}/contents/{path}` — 创建/更新文件
  ```json
  {"content": "<base64>", "branch": "master", "commit_message": "Update file", "encoding": "base64"}
  ```

### Issues
- `GET /repos/{owner}/{repo}/issues` — 列出 Issues
  - 可选 `?state=opened|closed&labels=bug&assignee_id=1`
- `GET /repos/{owner}/{repo}/issues/{number}` — 获取 Issue 详情
- `POST /repos/{owner}/{repo}/issues` — 创建 Issue
  ```json
  {"title": "Bug: ...", "body": "Description", "labels": ["bug"], "assignee_ids": []}
  ```
- `PUT /repos/{owner}/{repo}/issues/{number}` — 更新 Issue (关闭: `{"state_event": "close"}`)
- `GET /repos/{owner}/{repo}/issues/{number}/comments` — 列出评论
- `POST /repos/{owner}/{repo}/issues/{number}/comments` — 创建评论

### Pull Requests
- `GET /repos/{owner}/{repo}/pulls` — 列出 PRs
  - 可选 `?state=opened|closed|merged&sort=created&direction=desc`
- `GET /repos/{owner}/{repo}/pulls/{number}` — 获取 PR 详情
- `POST /repos/{owner}/{repo}/pulls` — 创建 PR
  ```json
  {"title": "feat: add feature", "head": "feature-branch", "base": "master", "body": "Description"}
  ```
- `PUT /repos/{owner}/{repo}/pulls/{number}` — 更新 PR
- `GET /repos/{owner}/{repo}/pulls/{number}/files` — 获取 PR 文件变更
- `POST /repos/{owner}/{repo}/pulls/{number}/reviews` — 创建 review
  ```json
  {"body": "Review comments", "event": "APPROVE|REQUEST_CHANGES|COMMENT"}
  ```
- `PUT /repos/{owner}/{repo}/pulls/{number}/merge` — 合并 PR
  ```json
  {"merge_method": "squash|merge|rebase"}
  ```

### Releases
- `GET /repos/{owner}/{repo}/releases` — 列出 Releases
- `POST /repos/{owner}/{repo}/releases` — 创建 Release
  ```json
  {"tag_name": "v1.0.0", "name": "v1.0.0", "body": "Release notes", "ref": "master"}
  ```

### Search
- `GET /search/repositories?q=keyword` — 搜索仓库
- `GET /search/issues?q=keyword` — 搜索 Issues

## Error Codes

| HTTP | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad request |
| 401 | Invalid token |
| 403 | Insufficient permissions |
| 404 | Not found |
| 422 | Validation failed |
| 429 | Rate limited |

## Rate Limits

GitCode 默认速率限制为 500 requests/hour。返回 429 时等待 Retry-After 秒后重试。
