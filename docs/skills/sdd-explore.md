# /sdd-explore

> Read-only codebase exploration to understand context before making changes.

## Usage

```
/sdd-explore "how does authentication work"
/sdd-explore
```

## Prerequisites

None. This is a read-only operation.

## What it does

1. **Finds similar patterns** — existing implementations of the same type
2. **Identifies affected files** — what will need to change and why
3. **Reviews domain models** — data structures, interfaces, contracts
4. **Checks tests** — how existing tests are structured for similar code
5. **Reads canonical specs** — relevant domains from `openspec/specs/`
6. **Compiles constraints** — key constraints affecting the design

## Artifacts produced

None. Produces a summary in the conversation — no files created or modified.

## Next step

- `/sdd-propose` — create a proposal based on the exploration
