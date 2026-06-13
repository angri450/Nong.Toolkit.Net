# Gitee MCP Tool Reference

所有 Gitee 操作通过 MCP Server 的工具完成。工具名格式：`snake_case`。

## Issue

| 工具 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `create_issue` | `owner, repo, title, body, labels` | Issue 对象 | 创建新 Issue |
| `list_repo_issues` | `owner, repo, state, labels, page` | Issue 列表 | 列出仓库 Issue |
| `get_repo_issue_detail` | `owner, repo, number` | Issue 详情 | 获取单个 Issue |
| `update_issue` | `owner, repo, number, state, labels, title, body` | Issue 对象 | 更新 Issue（关闭/修改标签等） |

## Pull Request

| 工具 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `create_pull` | `owner, repo, title, body, head, base` | PR 对象 | 创建 PR |
| `get_pull_detail` | `owner, repo, number` | PR 详情 | 获取 PR 详情和状态 |
| `list_repo_pulls` | `owner, repo, state, sort` | PR 列表 | 列出仓库 PR |
| `get_diff_files` | `owner, repo, number` | 文件列表 | 获取 PR 变更文件 |
| `compare_branches_tags` | `owner, repo, base, head` | diff 内容 | 比较两个分支/tag |
| `merge_pull` | `owner, repo, number, merge_method` | 合并结果 | 合并 PR (merge/squash/rebase) |

## Comment

| 工具 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `list_comments` | `owner, repo, number, resource_type` | 评论列表 | 获取 PR/Issue 的评论 |
| `create_comment` | `owner, repo, number, body, resource_type` | 评论对象 | 在 PR/Issue 上评论 |

## Repository

| 工具 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `list_user_repos` | 无 | 仓库列表 | 当前用户有权访问的仓库 |
| `search_open_source_repositories` | `q, language, sort, order` | 搜索结果 | 搜索开源仓库 |
| `fork_repository` | `owner, repo` | Fork 结果 | Fork 仓库 |
| `get_file_content` | `owner, repo, path, ref` | 文件内容 | 读取仓库文件 |
| `search_files_by_content` | `owner, repo, q, ref` | 搜索结果 | 在仓库内搜索文件内容 |

## Release

| 工具 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `create_release` | `owner, repo, tag_name, name, body` | Release 对象 | 创建版本发布 |
| `get_releases` | `owner, repo` | Release 列表 | 获取已发布版本 |

## User & Notification

| 工具 | 参数 | 返回 | 说明 |
|------|------|------|------|
| `get_user_info` | 无 | 用户信息 | 获取当前用户信息 |
| `list_user_notifications` | `page, per_page` | 通知列表 | 获取用户通知 |

## 辅助参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `owner` | string | 仓库所有者 |
| `repo` | string | 仓库名 |
| `labels` | string | 逗号分隔标签: `bug`, `feature`, `enhancement`, `question`, `docs` |
| `state` | string | `open`, `closed`, `all` |
| `resource_type` | string | `issue` 或 `pull` |
| `sort` | string | `created`, `updated`, `popularity` |
| `order` | string | `asc`, `desc` |
| `merge_method` | string | `merge`, `squash`, `rebase` |
| `language` | string | 编程语言过滤 |
