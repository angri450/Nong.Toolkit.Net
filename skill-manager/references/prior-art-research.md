# Prior Art Research

Before building a skill from scratch, search for existing tools, MCP servers, and APIs that provide infrastructure.

## Search Channels (in priority order)

| Priority | Channel | What to search | How |
|----------|---------|---------------|-----|
| 1 | **Conversation history** | User's proven workflows, verified API patterns | Grep recent conversations |
| 2 | **Local documents & SOPs** | User's private methodology, runbooks, existing skills | Search ~/.claude/ references/ |
| 3 | **Installed plugins & MCPs** | Already-integrated tools | Check ~/.claude/plugins/ |
| 4 | **skills.sh** | Community skills | WebFetch https://skills.sh/?q=<keyword> |
| 5 | **Anthropic official plugins** | Official/partner plugins | external_plugins directory |
| 6 | **MCP servers on GitHub** | Existing MCP servers for same API | WebSearch "<service> MCP server site:github.com" |
| 7 | **Official API docs** | Target service documentation | WebSearch or WebFetch docs URL |
| 8 | **npm / PyPI** | SDK or CLI packages | npm search or PyPI JSON API |

## Clone and Verify (Don't Trust README)

When a public MCP server or skill is found:
1. Read actual source code — many have polished READMEs on hollow codebases
2. Verify auth method — does it match how the API actually authenticates?
3. Check test coverage — zero tests = prototype, not production-grade
4. Check maintenance — last commit date, open issue count
5. Check environment compatibility — proxy/network assumptions, hardcoded DNS
6. Check license — MIT/Apache fine; GPL/SSPL may conflict with proprietary use
7. Check dependency weight — huge dependency trees create conflict surface

## Decision Matrix

| Finding | Action |
|---------|--------|
| Mature MCP/SDK handles the infrastructure | **Adopt it, build on top** |
| Partial MCP or SDK exists | **Extend** — use for infrastructure, fill gaps |
| Public skill covers same domain | **Use for structural inspiration only** |
| Nothing public exists | **Build from scratch** |
| Integration cost > build cost | **Build it** — ownership beats integration friction |