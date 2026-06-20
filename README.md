# Nong.Toolkit.Net — Skill Distribution

The skill source files now live in [Nong.Cli.Net/skills/](https://github.com/angri450/Nong.Cli.Net/tree/main/skills).

This repository is a **thin distribution mirror**. Install via the marketplace:

```bash
claude plugin marketplace add https://github.com/angri450/Nong.Toolkit.Net.git
claude plugin install nong-toolkit@nong-toolkit
```

## What's here

- `.claude-plugin/marketplace.json` — marketplace entry pointing to Cli.Net skill source
- CI pipeline pulls skills from Cli.Net before packaging

## Development

All skill authoring, testing, and versioning happens in Nong.Cli.Net's `skills/` directory.
