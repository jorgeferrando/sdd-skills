# /sdd-explore

> Read-only codebase exploration to understand context before making changes.

## Usage

```
/sdd-explore "how does authentication work"
/sdd-explore
```

## Prerequisites

- `openspec/` initialized (`/sdd-init`)

## What it does

1. **Recalls past decisions** — searches archived specs, canonical specs, and `openspec/INDEX.md` for previous decisions, discarded alternatives, and business rules related to the change. Skips silently if no history exists.
2. **Finds similar patterns** — existing implementations of the same type
3. **Identifies affected files** — what will need to change and why
4. **Reviews domain models** — data structures, interfaces, contracts
5. **Checks tests** — how existing tests are structured for similar code
6. **Reads canonical specs** — relevant domains from `openspec/specs/`
7. **Compiles constraints** — key constraints affecting the design

## Artifacts produced

- `openspec/changes/{change-name}/notes.md` — structured exploration findings (prior decisions, relevant files, existing patterns, specs, constraints)

## Next step

- `/sdd-propose` — create a proposal based on the exploration
