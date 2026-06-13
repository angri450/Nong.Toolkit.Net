---
name: gitee
description: >
  Gitee platform via MCP Server. Trigger on create issue, create PR, review PR,
  merge PR, release, fork, search repos, notifications, or triage issues.
---

# Gitee Skill

Gitee platform operations via MCP Server. No local CLI needed.

## Prerequisites

1. Obtain a [Gitee personal access token](https://gitee.com/profile/personal_access_tokens) with scopes: `projects`, `issues`, `pull_requests`, `notifications`
2. Configure MCP Server → [workspace-setup.md](references/workspace-setup.md)
3. Run `/mcp` to verify `gitee` is connected

## Dispatch Logic

See [workflows.md](references/workflows.md) for detailed instructions per workflow.

| Intent | Trigger keywords | MCP tools to use |
|--------|-----------------|-----------------|
| Create Issue | "create issue", "report bug", "feature request" | `list_repo_issues`, `create_issue` |
| Create PR | "create PR", "pull request", "open PR" | `compare_branches_tags`, `create_pull` |
| Review PR | "review", "code review", "check PR" | `get_pull_detail`, `get_diff_files`, `list_comments`, `create_comment` |
| Merge PR | "merge", "merge PR" | `get_pull_detail`, `merge_pull` |
| Create Release | "release", "publish version", "changelog" | `get_releases`, `create_release` |
| Daily Digest | "today", "what's pending", "notifications", "daily" | `list_user_notifications`, `list_repo_pulls`, `list_repo_issues` |
| Explore Repo | "what does this repo do", "explore", "tell me about" | `list_user_repos`, `get_file_content` |
| Search & Fork | "search", "find project", "fork" | `search_open_source_repositories`, `fork_repository` |
| Issue Triage | "triage", "categorize issues", "organize issues" | `list_repo_issues`, `get_repo_issue_detail`, `create_comment` |
| Implement Issue | "implement issue", "work on issue", "develop" | `get_repo_issue_detail`, `create_pull`, `update_issue` |
| Close Issue | "close issue", "wrap up issue" | `get_repo_issue_detail`, `list_repo_pulls`, `update_issue` |
| Quick Fix Suggestion | "how to fix", "fix suggestion", "what to change" | `grep`, `glob`, `get_file_content` |
| Stale PR Reminder | "stale PR", "inactive PR", "aging PR" | `list_repo_pulls`, `get_pull_detail`, `list_comments` |

Full MCP tool reference: [mcp-tools.md](references/mcp-tools.md)
Lessons learned: [lessons-learned.md](references/lessons-learned.md)

## Cross-Skill Flow

| Step | Skill | Role |
|------|-------|------|
| 1. Understand requirements | Gitee (read Issue) | Read Issue content and comments |
| 2. Locate code | Gitee (quick-fix) | `grep`/`glob`/`get_file_content` to find relevant files |
| 3. Write code | dotnet / bash / powershell | Actual implementation |
| 4. Submit PR | Gitee (create PR) | Generate Conventional Commits title, create PR |
| 5. Code review | Gitee (review PR) | Multi-dimension review, classify as Block/Suggest/Optional |
| 6. Merge & Release | Gitee (merge + release) | Merge PR, generate changelog, publish release |
