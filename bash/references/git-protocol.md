# Git Safety Protocol

Rules and workflow for git operations from an AI agent. **Only commit when the user asks.** If unclear, ask first.

## Seven hard rules

1. **NEVER** update the git config.
2. **NEVER** run destructive git commands (`push --force`, `reset --hard`, `checkout .`, `restore .`, `clean -f`, `branch -D`) unless the user explicitly requests it.
3. **NEVER** skip hooks (`--no-verify`, `--no-gpg-sign`, etc.) unless the user explicitly asks.
4. **NEVER** force-push to `main`/`master`. If the user requests it, warn them first.
5. **CRITICAL — always create NEW commits, not amend.** When a pre-commit hook fails, the commit did **not** happen, so `--amend` would modify the **previous** commit and may destroy work. After hook failure: fix the issue, re-stage, create a new commit.
6. **Stage files by name**, not `git add -A` / `git add .` — those silently include `.env`, credentials, build artifacts.
7. **NEVER** commit unless the user explicitly asks. Proactive commits feel pushy.

## Commit workflow (parallel-optimized)

### Step 1 — read state in parallel (single message, multiple Bash calls)

- `git status` (NEVER `-uall`; on large repos it can OOM).
- `git diff` (staged + unstaged combined, or run both).
- `git log --oneline -n 10` (match the repo's commit-message style).

### Step 2 — draft the commit message

- Categorize: `add` (new feature), `update` (enhancement), `fix` (bug fix), `refactor`, `test`, `docs`.
- 1–2 sentences. Focus on **why**, not **what**.
- Use HEREDOC for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
fix: handle empty array in summary aggregator

Empty input previously triggered a divide-by-zero in the average
calculation. Skip aggregation when the input is empty.
EOF
)"
```

### Step 3 — commit in parallel (single message)

- `git add <specific files>` — by name, not `-A`.
- `git commit -m "…"` — with the HEREDOC above.
- `git status` — verify result. (This must run **after** the commit; don't parallelize the verification.)

### Step 4 — if the hook failed

Fix the underlying problem, re-stage, create a **NEW** commit. Do not amend.

## What you may NOT do during a commit flow

- No additional code-exploration commands beyond git itself.
- No `TodoWrite` / `Agent` tool calls.
- No `git push` to a remote unless the user explicitly asks.
- No `-i` interactive flags (`git rebase -i`, `git add -i`) — they require a terminal editor.
- No `--no-edit` with `git rebase` — it's not a valid option for rebase.
- No empty commits if there are no changes.

## Pull requests

Use `gh` via the Bash tool for all GitHub work (issues, PRs, checks, releases, comments).

```bash
gh pr create --title "concise title under 70 chars" --body "$(cat <<'EOF'
## Summary
- bullet 1
- bullet 2

## Test plan
- [ ] checklist item 1
- [ ] checklist item 2
EOF
)"
```

- PR title under 70 characters; details belong in the body.
- Analyze **all** commits the PR will introduce, not just the latest.
- Return the PR URL when done.
- View PR comments: `gh api repos/<owner>/<repo>/pulls/<n>/comments`.
