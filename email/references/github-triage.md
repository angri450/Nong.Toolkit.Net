# GitHub Notification Triage

Automatically classify and route GitHub notification emails arriving on a sub-mailbox.

## Prerequisites

- `mail-cli` with API key configured
- A dedicated sub-mailbox for GitHub notifications (created via setup script)

## Setup

Create the sub-mailbox via:

```bash
# resolve main email
MAIN_EMAIL=$(mail-cli clawemail list --json | jq -r '.data.userEmail')

# derive sub-mailbox address (workspace prefix + .ghbot)
WORKSPACE=$(mail-cli clawemail list --json | jq -r '.data.mailbox.email' | cut -d@ -f1)
SUB_EMAIL="${WORKSPACE}.ghbot@claw.163.com"
echo "Main: $MAIN_EMAIL  Sub: $SUB_EMAIL"
```

Then:
1. Add the sub-mailbox as an email channel account in your agent config
2. Go to GitHub → Settings → Notifications → Custom routing → set email to the sub-mailbox address
3. Restart your agent gateway

## Triage Workflow

When an email arrives on the ghbot account:

0. **Fetch only UNSEEN emails** — always filter for unread messages only
1. **Identify priority** — read subject and body, match against rules below
2. **Act on priority** (see P0/P1/P2 below)
3. **Always mark as read after processing** to prevent re-processing

## Priority Levels

### 🔴 P0 — Immediate Forward

Forward to the human owner immediately. Prepend `[紧急]` to subject.

**Matching patterns** (case-insensitive, check subject + body):
- CI/CD failures: `failed`, `broken`, `build error`, `workflow run failed`, `check suite failed`
- Security: `dependabot`, `security alert`, `vulnerability`, `CVE-`
- Direct mentions requiring action: body contains `@<your-username>` AND words like `please`, `need`, `urgent`, `ASAP`, `decision`, `approve`, `block`
- Deploy failures: `deploy failed`, `rollback`

**Forward command:**

```bash
OWNER_EMAIL=$(mail-cli clawemail list --json | jq -r '.data.userEmail')
mail-cli compose send \
  --to "$OWNER_EMAIL" \
  --subject "[紧急] <original-subject>" \
  --body "<original-body>" --html
mail-cli mail mark --ids "$id" --fid 1 --read
```

### 🟡 P1 — Buffer for Daily Summary

Do NOT forward immediately. Store metadata in `memory/gh-triage-buffer-YYYY-MM-DD.json`.

**Matching patterns:**
- PR review requests: `requested your review`, `review requested`
- PR merged: `merged`, `pull request merged`
- PR approved: `approved your pull request`
- Issue assigned: `assigned to you`, `you were assigned`

**Buffer format:**

```json
[
  {
    "repo": "owner/repo",
    "type": "review_request",
    "title": "PR title",
    "number": 123,
    "url": "https://github.com/...",
    "author": "username",
    "receivedAt": "ISO-8601"
  }
]
```

Read existing file first (create `[]` if missing), append new entry, write back. Then:

```bash
mail-cli mail mark --ids "$id" --fid 1 --read
```

### 🟢 P2 — Silent Archive

No forward. No reply. Mark as read.

```bash
mail-cli mail mark --ids "$id" --fid 1 --read
```

**Everything else**, including: star/watch notifications, comment threads you're CC'd on, subscription digests, bot auto-comments (codecov, dependabot auto-merge, etc.).

## Daily Summary

A cron job fires daily at the configured time (default `0 18 * * *`). The job:

1. Read `memory/gh-triage-buffer-YYYY-MM-DD.json` for today
2. **If file is missing, empty, or all entries already sent → do nothing** (never send empty summary)
3. Resolve human email: `OWNER_EMAIL=$(mail-cli clawemail list --json | jq -r '.data.userEmail')`
4. Group entries by repo and type
5. Compose summary email
6. Send to `$OWNER_EMAIL` via `mail-cli compose send`
7. After successful send, rename buffer file to `.sent.json`

### Summary Format

```
Subject: [GitHub 日报] <date> — <n> 条待处理通知

# GitHub 通知日报 — <date>

## 🔍 待你 Review 的 PR（<count>）
### <repo-name>
- [ ] #<number> <title>  — <author>, <time-ago>

## ✅ 今日 Merged PR（<count>）
- <repo>#<number> <title>

## 🔒 今日 Closed Issue（<count>）
- <repo>#<number> <title>

---
此邮件由 GitHub Triage 自动生成
```
