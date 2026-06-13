# Skill Creator — Architecture

## Version

Target: `net11.0`. Execution: `dotnet run --project tools/SkillManager.Cli`.

## Directory Layout

```
skill-manager/
├── SKILL.md                          # kernel/router
├── Directory.Build.props              # build output -> ~/Documents/GroundPA Toolkit Workplace/skill-manager
├── LICENSE.txt                        # Apache 2.0
├── .scan-allowlist.json               # scan allowlist

├── tools/SkillManager.Cli/            # .NET CLI
│   ├── SkillManager.Cli.csproj        # net11.0
│   ├── Program.cs                     # entry + command routing
│   ├── Models/                        # data models
│   │   ├── SkillFrontmatter.cs
│   │   ├── SecurityFinding.cs
│   │   ├── ValidationResult.cs
│   │   ├── EvalItem.cs
│   │   └── AllowlistEntry.cs
│   ├── Tools/                         # command implementations
│   │   ├── SkillValidator.cs          # validate
│   │   ├── SecurityScanner.cs         # scan
│   │   ├── Packager.cs                # package
│   │   ├── EvalRunner.cs              # eval
│   │   ├── EvalViewer.cs              # eval serve (HTTP + embedded viewer)
│   │   ├── Scaffolder.cs              # scaffold (wrapper skeleton)
│   │   ├── InventoryRunner.cs         # inventory
│   │   ├── DescriptionOptimizer.cs    # optimize-description
│   │   ├── LoopRunner.cs              # run-loop
│   │   └── BlindAnonymizer.cs         # blind comparison
│   └── assets/
│       └── viewer.html                # embedded frontend (CDN-free)

├── tests/SkillManager.Cli.Tests/      # regression tests
│   ├── SkillValidatorTests.cs
│   ├── SecurityScannerTests.cs
│   ├── PackagerTests.cs
│   ├── BlindComparisonTests.cs
│   ├── DescriptionOptimizerTests.cs
│   └── LoopRunnerTests.cs

├── references/                        # documentation (~16 files)
│   ├── architecture-conventions.md    # read-only source, Version="*", no global.json
│   ├── session-recording.md           # JSONL auto-logging protocol
│   ├── skill-development-methodology.md
│   ├── skill-writing-guide.md
│   ├── evaluation-workflow.md
│   ├── description-optimization.md
│   ├── prior-art-research.md
│   ├── schemas.md
│   ├── prerequisites.md
│   ├── sanitization_checklist.md
│   ├── security-guide.md
│   ├── packaging-guide.md
│   ├── improvement-guide.md
│   ├── maintenance.md
│   ├── merge-split.md
│   ├── deprecation.md
│   ├── anti-patterns.md
│   └── platform-specific.md

├── agents/                            # sub-agent definitions
│   ├── grader.md
│   ├── comparator.md
│   └── analyzer.md

├── evals/                             # regression evals
│   └── evals.json

├── workflows/                         # sub-workflows
│   ├── session/workflow.md            # Session Mining (auto, end-of-session)
│   └── wrapper/                       # Wrapper (formal improve)
│       ├── workflow.md
│       ├── patterns.md
│       ├── architecture_contract.md
│       └── verification_protocol.md

└── .github/workflows/ci.yml           # CI
```

## Commands

| Command | Purpose |
|---------|---------|
| `dotnet run -- validate .` | Validate SKILL.md structure and references |
| `dotnet run -- scan .` | Security scan (always-on) |
| `dotnet run -- package .` | Validate + scan + create .zip |
| `dotnet run -- eval evals.json` | Load and validate eval schema |
| `dotnet run -- eval serve` | Start interactive eval viewer (browser) |
| `dotnet run -- scaffold <name> --tool <x>` | Scaffold wrapper skill skeleton |
| `dotnet run -- inventory .` | List all components |

## Architectural Conventions

See [`references/architecture-conventions.md`](references/architecture-conventions.md).
