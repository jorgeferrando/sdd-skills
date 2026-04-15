# /sdd-init

> Bootstrap a new project for SDD. Entry point for all projects.

## Usage

```
/sdd-init            # Full or reduced questionnaire (auto-detected)
/sdd-init --quick    # Minimal questions with sensible defaults
```

Safe to re-run. If steering already exists, shows current state and exits.

## What it does

1. **Creates `openspec/` structure** — `specs/`, `changes/`, `steering/` directories
2. **Scans the environment** — runtimes, tools, Docker containers, config files (via `sdd-env-scan.sh`)
3. **Runs guided questionnaire** — adapts based on whether code already exists
4. **Generates steering files** — 7 files in `openspec/steering/`
5. **Creates `openspec/config.yaml`** — project configuration

## Questionnaire modes

### Quick mode (`--quick`)

Asks only Groups A (Project) and B (Stack). Uses sensible defaults for the rest: solo developer, production quality, conventional commits, no CI, AI decides architecture and TDD per task. Best for small projects or quick evaluation.

### Reduced mode (stack detected)

Stack is detected from config files (`pyproject.toml`, `package.json`, etc.). Skips Group B. Asks Groups A and C.

### Full mode (no code detected)

| Group | Questions |
|-------|-----------|
| **A — Project** | What it builds, for whom, what it does NOT do |
| **B — Stack** | Project type, language, framework, database, testing |
| **C — Team** | Size, quality level (MVP/production/OSS), CI/CD |
| **D — Tools** | Detected MCPs (Context7, Jira, GitHub) |
| **E — Patterns** | Architecture style, TDD, commit format |

Each question shows trade-offs with justifications. The user can answer "you decide" — the AI chooses and explains.

## Artifacts produced

| File | Content |
|------|---------|
| `openspec/steering/product.md` | What the project builds, for whom, bounded context |
| `openspec/steering/tech.md` | Stack, dependencies, dev/test commands |
| `openspec/steering/structure.md` | Directory layout, layers, responsibilities |
| `openspec/steering/conventions.md` | Rules in RFC 2119 format (MUST/SHOULD/MAY) |
| `openspec/steering/environment.md` | Available MCPs, CLI tools, runtimes |
| `openspec/steering/project-skill.md` | Quick reference index |
| `openspec/steering/project-rules.md` | Empty — grows with user corrections |
| `openspec/config.yaml` | Project configuration |

## Next step

- `/sdd-discover` — if the project has existing code, generate canonical specs
- `/sdd-new "description"` — start your first change
