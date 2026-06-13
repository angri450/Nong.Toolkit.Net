# Gitee Skill — Workflow Instructions

Detailed MCP tool invocation flows. One section per workflow.

## 1. Create Issue

1. Confirm repo owner/repo — user specifies / `list_user_repos` to select / `search_open_source_repositories` to find
2. Clarify content:
   - Bug: expected behavior / actual behavior / repro steps / environment
   - Feature: problem solved / proposed solution / reference projects
3. `list_repo_issues` to check for duplicates
4. After user confirmation: `create_issue(owner, repo, title, body, labels)`
   - labels: `bug` / `feature` / `enhancement` / `question` / `docs`
5. Return Issue URL and summary

## 2. Create PR

1. Confirm: head branch / base branch (default: master) / linked Issue (optional)
2. `compare_branches_tags(base, head)` to get diff
3. Analyze: what changed / breaking changes?
4. Generate Conventional Commits title: `feat/fix/refactor/docs/test/chore(scope): subject`
5. Generate structured description:
   ```markdown
   ## Summary
   ## Changes
   ## Testing
   ## Related Issue (closes #N)
   ```
6. `create_pull(title, body, head, base)` to create PR

## 3. Review PR

1. `get_pull_detail` to check PR state; stop if closed/merged
2. `get_diff_files` to get changed file list
3. `get_file_content` to read core changed files
4. `list_comments(resource_type: pull)` to avoid duplicate discussion
5. Review across five dimensions:
   - Correctness: logic? edge cases? null pointers?
   - Security: injection? hardcoded secrets? permission checks?
   - Maintainability: clear names? single responsibility? comments?
   - Performance: N+1 queries? memory usage?
   - Consistency: style match? related modules consistent?
6. Classify findings:
   - BLOCKER: correctness or security → must fix
   - SUGGESTION: code quality → recommended
   - OPTIONAL: nice-to-have
7. Present to user for confirmation before posting via `create_comment(resource_type: pull)`
8. If no issues, comment `LGTM!`

## 4. Merge PR

1. `get_pull_detail` to check PR state and conflicts
2. If conflicts → inform user, do NOT auto-merge
3. After confirmation: `merge_pull(owner, repo, number, merge_method)`
   - `merge_method`: `merge` (default) / `squash` / `rebase`

## 5. Create Release

1. `get_releases` to get existing versions
2. Get merged PR list, analyze commits for changelog
3. Group changelog by type: `feat` / `fix` / `refactor` / `docs` / `chore`
4. `create_release(owner, repo, tag_name, name, body)`
   - `tag_name`: v1.0.0
   - `name`: release title
   - `body`: structured changelog

## 6. Daily Digest

1. `list_user_notifications` to get unread notifications
2. `list_repo_pulls` to get pending PRs
3. `list_repo_issues` to get pending Issues
4. Output sorted by priority:
   - PRs awaiting review
   - Issues awaiting triage
   - PRs with no recent activity
5. Highlight high-priority items

## 7. Repo Explorer

1. `list_user_repos` or `search_open_source_repositories` to locate repo
2. `get_file_content` to read key files (README, package.json, .csproj, etc.)
3. Output summary: purpose / tech stack / directory structure / activity level

## 8. Search & Fork

1. `search_open_source_repositories` with params:
   - `q`: search keywords
   - `language`: language filter
   - `sort`: `stars_count` / `forks_count` / `last_push_at`
   - `order`: `desc` (default)
2. Show top 3 candidates with stars/forks/language/last_update
3. After user selects: `fork_repository(owner, repo)`

## 9. Issue Triage

1. `list_repo_issues(state: "open")` to get all open Issues
2. `get_repo_issue_detail` for each to get details
3. Categorize by priority/type/status:
   - High (bug + active discussion) / Medium (feature + recent update) / Low (long inactive)
4. Generate triage report with `labels` suggestions

## 10. Implement Issue

Full Issue → Code → PR → Close pipeline:

1. `get_repo_issue_detail` to read Issue
2. `list_comments(resource_type: issue)` to read existing discussion
3. `grep` / `glob` to locate relevant code
4. Write code (use dotnet/bash/powershell skills)
5. `compare_branches_tags` to analyze changes
6. `create_pull` with `closes #N` in description
7. After merge: `update_issue(state: "closed")` to close Issue
8. `create_comment(resource_type: issue)` with fix summary

## 11. Close Issue Flow

1. `get_repo_issue_detail` to read Issue
2. `list_repo_pulls` to verify related PR is merged
3. After confirming fix is merged: `update_issue(state: "closed")`
4. `create_comment(resource_type: issue)` with close message:
   - Link to merged PR
   - Summary of fix
   - Acknowledge contributors

## 12. Quick Fix Suggestion

1. `get_repo_issue_detail` to understand the Issue
2. `grep` to search for relevant code symbols
3. `glob` to locate relevant files
4. `get_file_content` to analyze affected code
5. Output:
   - Files to modify
   - Suggested changes per file
   - Implementation plan (steps and priority)

## 13. Stale PR Reminder

1. `list_repo_pulls(state: "open")` to get all open PRs
2. `get_pull_detail` for each to check `created_at` and `updated_at`
3. Grade by inactivity duration:
   - Critical (>30 days) / Moderate (14-30 days) / Mild (7-14 days) / Fresh (<7 days)
4. `list_comments` to check recent discussion
5. Generate prioritized reminder report

## Notes

- Repo format is always `owner/repo`
- PR titles ≤ 50 characters
- Review comments must be shown to user for confirmation before posting
- Never auto-merge conflicting PRs
- Search repos defaults to sorting by stars descending
- Source: https://gitee.com/oschina/gitee-agent-skills

## Release Checklist (GroundPA Toolkit)

When releasing a new version, update ALL of these. Claude reads `plugin.json`, NOT git tags.

1. **`.claude-plugin/plugin.json` → `"version"` field** — Claude reads THIS. Missing = shows "1.0.0" forever
2. **`.claude-plugin/plugin.json` → `"skills"` array** — new skills must be registered here or Claude won't see them
3. **`skills.sh.json` → `"version"` + groups** — marketplace manifest, also needs updating
4. **`git tag -a vX.Y.Z`** — code history marker
5. **GitHub + Gitee Release** — human-readable changelog

**The trap we fell into:** bumped skills.sh.json and git tag, forgot plugin.json. Claude showed 1.0.0 through three rounds of "fixes" until we found the real version file.

**New skill registration checklist:**
- `.claude-plugin/plugin.json` → add to `skills` array
- `.claude-plugin/plugin.json` → add to `keywords` array
- `skills.sh.json` → add to appropriate group
- Update description count ("15 skills" → "16 skills")
- `README.zh-CN.md` → add to skills table

**Gitee release via API:**
```bash
curl -X POST "https://gitee.com/api/v5/repos/owner/repo/releases" \
  -H "Content-Type: application/json" \
  -d '{"tag_name":"v1.0.0","name":"Title","body":"Notes","target_commitish":"master"}'
```
Authenticate with `--oauth2-bearer <gitee-token>`.
