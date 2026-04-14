# /sdd-new

> Start a new change. Combines explore + propose in one command.

## Usage

```
/sdd-new "add user authentication"
/sdd-new TICKET-123
```

## Prerequisites

- `openspec/` initialized (via `/sdd-init`)

## What it does

1. **Picks a change name** — kebab-case from description or ticket (e.g., `add-user-auth`)
2. **Creates change directory** — `openspec/changes/{change-name}/`
3. **Explores the codebase** — reads existing code, patterns, affected files, canonical specs
4. **Creates proposal** — `proposal.md` with problem, solution, alternatives, impact

## Artifacts produced

- `openspec/changes/{change-name}/proposal.md`

## Next step

- `/sdd-continue` — proceeds to the spec phase
