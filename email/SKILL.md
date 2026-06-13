---
name: email
description: >
  Send and receive emails using the ClawEmail mail-cli tool. Use this skill
  whenever the user wants to send an email, check their inbox, read messages,
  reply to emails, forward emails, search mail history, download attachments,
  or manage mailboxes — even if they don't explicitly say "email" or "mail-cli".
  Also trigger when the user mentions any @claw.163.com address, mentions
  ClawEmail, or pastes content that looks like email threads. If in doubt and
  the task involves any kind of electronic message, prefer invoking this skill
  over guessing.
---

# ClawEmail 邮件收发

`mail-cli` is the command-line client for ClawEmail. It wraps IMAP/SMTP behind a
single binary and exposes a stable JSON interface that Claude can parse reliably.

This skill is designed to run **inline** (no `context: fork`) because it needs to
execute shell commands directly.

## Why `--json` on every command

Always append `--json`. The plain-text output is for humans; Claude needs
machine-readable output to extract the message ID, subject, or body without
fragile string parsing.

## Why filter the JSON before reading into context

`mail-cli read body --json` returns 4500+ chars but ~63% is `headerRaw` — raw
SMTP headers with DKIM signatures, routing info, spam scores, and other
machine-level metadata that is useless for answering the user's question.
The fields you actually need are: `id`, `from`, `to`, `subject`, `date`,
`priority`, `html.content` (body), and `text` (if a plain-text body exists).

**Always pipe through a filter.** This saves ~70% of tokens per call and
prevents huge DKIM/signing blobs from polluting the context.

```bash
mail-cli read body --id "$id" --json | jq '{
  id: .data.id,
  from: .data.from,
  to: .data.to,
  subject: .data.subject,
  date: .data.date,
  priority: .data.priority,
  body: (.data.html.content // .data.text.content)
}'
```

Same principle for `mail list`: you only need `id`, `from`, `subject`, `date`,
and `read`. Don't pipe raw list output into context without trimming.

```bash
mail-cli mail list --fid 1 --unread --limit 50 --json | jq '[.data[] | {
  id, from, subject, date, read
}]'
```

## Discovering the user's email

Never hardcode an email address. Resolve it at runtime:

```bash
mail-cli clawemail list --json
# → .data.mailbox.email  is the active mailbox
# → .data.userEmail       is the human owner's personal email
```

Use the mailbox email as the "from" identity. Use the user email as the default
recipient for reports, summaries, and forwards unless the user specifies otherwise.

## Authentication

Before any IMAP operation, verify the profile is authenticated:

```bash
mail-cli auth test
```

If this fails with `PROFILE_NOT_FOUND` or an auth error, the user needs to run:

```bash
mail-cli auth login --user <their-email>@claw.163.com
```

This opens a browser for OAuth. After successful login, all subsequent commands
work until the token expires.

## Folder IDs

| ID | Name       |
|----|------------|
| 1  | 收件箱     |
| 2  | 草稿箱     |
| 3  | 已发送     |
| 4  | 已删除     |
| 5  | 垃圾邮件   |
| 6  | 病毒文件夹 |

The inbox is folder `1`. Use numeric IDs rather than names — names are localized
and will break on non-Chinese systems.

## Message IDs

Message IDs look like `53:xxxxx` (base64-ish string after a colon). Extract them
from `mail list` output under the `id` field. Always quote them in shell commands
because they may contain characters that the shell interprets.

---

## Common Workflows

These are the patterns that come up repeatedly. Use them as templates rather than
inventing new command sequences.

### 1. Check inbox and report new mail

The standard "what's in my inbox" flow: list, then read each one.

```bash
# Step 1: List unread (filtered — only the fields you need)
mail-cli mail list --fid 1 --unread --limit 50 --json | jq '[.data[] | {
  id, from, subject, date, read
}]'

# Step 2: For each message, read the body (filtered to skip headerRaw)
mail-cli read body --id "53:xxxxx" --json | jq '{
  id: .data.id,
  from: .data.from,
  to: .data.to,
  subject: .data.subject,
  date: .data.date,
  priority: .data.priority,
  body: (.data.html.content // .data.text.content)
}'

# Step 3 (only if user asks to "process" or "handle" — see below)
mail-cli mail mark --ids "53:xxxxx" --fid 1 --read
```

**Why this order:** Listing first is cheap (headers only). Reading bodies is
expensive. Only read bodies for messages the user actually cares about.

**Step 3 is conditional — don't auto-mark as read.** "Check my inbox" or
"看看收件箱" is a read-only peek. Marking as read is destructive: the user loses
the "unread" signal they rely on to find messages later. Only run Step 3 when
the user explicitly asks to process, handle, or mark messages (e.g. "处理一下",
"帮我看看这些邮件", "标记已读"). When in doubt, ask: "要帮你标记为已读吗？"

### 2. Send a simple email

```bash
mail-cli compose send \
  --to "recipient@example.com" \
  --subject "Subject line" \
  --body "Plain text body"
```

For HTML email, add `--html`:

```bash
mail-cli compose send \
  --to "recipient@example.com" \
  --subject "Subject" \
  --body "<h1>Heading</h1><p>Body</p>" --html
```

For long bodies, write to a file first and use `--body-file ./content.txt` to
avoid shell quoting nightmares.

### 3. Reply to an email

```bash
mail-cli compose reply --id "53:xxxxx" --body "Your reply"
```

Use `--all` to reply-all. Use `--html` if the reply body is HTML. The original
message is automatically quoted in the reply.

### 4. Forward an email

```bash
# Default "quote" mode — original is inline
mail-cli compose forward --id "53:xxxxx" --to "recipient@example.com"

# "attach" mode — original is an attachment
mail-cli compose forward --id "53:xxxxx" --to "recipient@example.com" --mode attach
```

Add `--body "Please see attached"` to prepend a note.

### 5. Search and filter

```bash
# By keyword (matches subject + body + from) — filter for readability
mail-cli mail search --fid 1 --keyword "invoice" --json | jq '[.data[] | {
  id, from, subject, date
}]'

# By date range
mail-cli mail search --fid 1 --since "2026-05-01" --json | jq '[.data[] | {
  id, from, subject, date
}]'
```

### 6. Download attachments

This is a two-step process because attachments live inside the MIME structure.

```bash
# Step 1: Inspect MIME structure — only show attachment entries
mail-cli read structure --id "53:xxxxx" --json | jq '[.data[] | select(.filename != null) | {
  partId, filename, contentType, size
}]'

# Step 2: Download by partId
mail-cli read attachment --id "53:xxxxx" --part <partId> --out-file ./downloads/
```

### 7. Batch operations

When processing many messages, always mark them as read *after* processing to
prevent duplicate handling:

```bash
# Get all unread IDs (filtered to just ids)
ids=$(mail-cli mail list --fid 1 --unread --json | jq -r '.data[].id')

# Process each one — filter body to skip headerRaw
for id in $ids; do
  mail-cli read body --id "$id" --json | jq '{
    id: .data.id,
    from: .data.from,
    subject: .data.subject,
    date: .data.date,
    body: (.data.html.content // .data.text.content)
  }'
  mail-cli mail mark --ids "$id" --fid 1 --read
done
```

### 8. Real-time monitoring

For live notification (not polling — uses WebSocket):

```bash
mail-cli mail watch --quiet
```

Outputs one NDJSON line per incoming message. Pipe to `jq` or another tool for
processing. Use `--quiet` to suppress connection status on stderr.

---

## Error Handling

| Error                          | Cause                                    | Fix                                           |
|--------------------------------|------------------------------------------|-----------------------------------------------|
| `PROFILE_NOT_FOUND`            | No profile configured                    | `mail-cli auth login --user <email>`          |
| `OPEN_API_1022` API_KEY_INVALID | API key expired or wrong                 | `mail-cli auth apikey set <new-key>`          |
| `AUTH_EXPIRED`                 | OAuth token expired                      | Re-run `mail-cli auth login`                  |
| Empty `data` array             | No messages match criteria               | Normal — not an error                         |
| `unknown command 'read'`       | Used `mail read` instead of `read body`  | Use `mail-cli read body --id <id>`            |

## Debugging

```bash
mail-cli debug:config       # inspect resolved config and transport
mail-cli auth test          # validate current profile
mail-cli auth list          # list all profiles and their status
```

## Sending to the human owner

When the skill needs to send a summary, report, or forward to the human user
(not to a ClawEmail sub-mailbox), resolve their personal email at runtime:

```bash
OWNER_EMAIL=$(mail-cli clawemail list --json | jq -r '.data.userEmail')
mail-cli compose send --to "$OWNER_EMAIL" --subject "..." --body "..."
```

This avoids hardcoding personal addresses in the skill.

## Reference Index

| Topic | File | Read when |
|-------|------|-----------|
| GitHub notification triage | [`references/github-triage.md`](references/github-triage.md) | GitHub notifications arriving on a sub-mailbox need automatic P0/P1/P2 routing, buffering, or daily summaries |
