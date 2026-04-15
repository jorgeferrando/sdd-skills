# /sdd-discover

> Reverse-engineer canonical specs from an existing codebase.

## Usage

```
/sdd-discover              # Analyze entire project
/sdd-discover {domain}     # Analyze specific domain only
```

Run once after `/sdd-init` on projects with existing code.

## Prerequisites

- `/sdd-init` executed (`openspec/` exists with `config.yaml`)

## What it does

1. **Detects domains** by scanning `src/`, `app/`, `lib/`, `packages/`
2. **Shows interactive summary** — list of detected domains with file counts, asks confirmation
3. **Analyzes domains in parallel** — one subagent per domain
4. **Generates canonical specs** — `openspec/specs/{domain}/spec.md` with `Status: inferred`
5. **Updates `openspec/INDEX.md`** — domain index with descriptions

Skips domains that already have specs.

## Artifacts produced

- `openspec/specs/{domain}/spec.md` for each detected domain
- `openspec/INDEX.md` (created or updated)

Inferred specs include: metadata, context, current behavior, EARS requirements, decisions, and open questions.

## Next step

- Review each spec directly in `openspec/specs/{domain}/spec.md` and edit to correct inaccuracies
- `/sdd-new "description"` — start a change (creates delta specs via `/sdd-spec`)
