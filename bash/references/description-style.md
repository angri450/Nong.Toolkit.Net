# `description` Field Style

Style guide for the `description` parameter of a Bash tool call. The user reads this in the permission prompt and the activity log; clarity matters.

## Rules

- Active voice. Describe what the command does, not what category it belongs to.
- **Never use the words "complex" or "risk"** — just describe the action.
- 5–10 words for standard commands.
- Add context (objects, scope, side effects) for piped or unusual commands.

## Examples

| Command | Good description |
|---|---|
| `ls` | "List files in current directory" |
| `git status` | "Show working tree status" |
| `npm install` | "Install package dependencies" |
| `find . -name "*.tmp" -exec rm {} \;` | "Find and delete all .tmp files recursively" |
| `git reset --hard origin/main` | "Discard all local changes and match remote main" |
| `curl -s url \| jq '.data[]'` | "Fetch JSON from URL and extract data array elements" |

## Anti-patterns

| Avoid | Why |
|---|---|
| "Run a complex git command" | Vague, uses banned word "complex". |
| "Risky cleanup" | Banned word "risk", and the user can't tell what's being cleaned. |
| "do stuff" | Tells the user nothing. |
| "Execute command" | Restates the obvious; describe the **effect**. |

A good description lets the user approve or deny without reading the command.
