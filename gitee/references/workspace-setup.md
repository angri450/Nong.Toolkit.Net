# Gitee Skill — Workspace Setup

## 1. Get Personal Access Token

Visit https://gitee.com/profile/personal_access_tokens to generate a token.

Required scopes: `projects`, `issues`, `pull_requests`, `notifications`

## 2. Configure MCP Server

Run in terminal:

```
claude mcp add --transport http gitee https://api.gitee.com/mcp
```

When prompted, enter your personal access token as the `Authorization` header value. The CLI writes directly to `~/.claude.json` (user-level config) and triggers a connection check immediately.

Alternatively, edit `~/.claude.json` manually and add the `gitee` entry under `mcpServers`:

```json
{
  "mcpServers": {
    "gitee": {
      "url": "https://api.gitee.com/mcp",
      "headers": {
        "Authorization": "Bearer <your-personal-access-token>"
      }
    }
  }
}
```

Do NOT write to `~/.claude/mcp.json` — that path is not read by Claude Code. `mcp.json` (without leading dot) is for project-level config only.

## 3. Verify

Restart Claude Code, run `/mcp`, confirm `gitee` appears in connected servers.

## 4. Usage

Once configured, describe your intent directly. The skill activates based on keywords:

```
Create a bug issue in owner/repo
```

```
Review PR #42 in owner/repo
```

```
Merge feature/login into main, create a PR
```

```
What's pending for me today?
```

```
Search gitee for C# chart libraries
```
