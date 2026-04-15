# /sdd-ff

> Fast-Forward: generate all change documentation in one pass.

## Usage

```
/sdd-ff "add health check endpoint"
/sdd-ff TICKET-789
```

## Prerequisites

- `openspec/` initialized (via `/sdd-init`)

## What it does

Runs five phases without pausing between them:

1. **Explore** — quick codebase exploration
2. **Propose** — creates `proposal.md` (asks questions if gaps found)
3. **Spec** — creates `specs/{domain}/spec.md`
4. **Design** — creates `design.md` (runs as **agent** to keep context clean)
5. **Tasks** — creates `tasks.md`

Design runs as a subagent because it is non-interactive and reads substantial code. The FF context stays focused on the interactive phases (propose, spec, tasks). If ambiguity is found at any point, the AI pauses to ask, then continues.

## When to use

- The change is straightforward and well-understood
- You trust the AI's judgment for intermediate phases
- You want to move fast

## When NOT to use

- Complex changes that need careful spec review
- Changes spanning multiple domains
- When the team needs to review each phase

## Artifacts produced

- `proposal.md`
- `specs/{domain}/spec.md`
- `design.md`
- `tasks.md`

All in `openspec/changes/{change-name}/`.

## Next step

- `/sdd-apply` — implement task by task
