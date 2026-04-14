# /sdd-tasks

> Break the design into an ordered list of atomic tasks.

## Usage

```
/sdd-tasks                 # Tasks for active change
/sdd-tasks {change-name}
```

## Prerequisites

- `design.md` approved

## What it does

1. **Reads design** — extracts file list, dependencies, tests
2. **Orders by dependencies:**
   - Interfaces and contracts first
   - Base files before files that depend on them
   - Tests after or interleaved with implementation
3. **Checks git state** — creates branch if needed
4. **Creates `tasks.md`** — presents for review

## Principles

- **One file per task** — keeps commits atomic
- **One commit per task** — traceable history
- **Dependencies explicit** — "Depends on: T01"
- **Quality gate at the end** — test + lint check

## Artifact format

```markdown
# Tasks: {Change Title}

## Metadata
- **Change:** {change-name}
- **Branch:** {branch-name}
- **Date:** {YYYY-MM-DD}

## Implementation Tasks

- [ ] **T01** Create `path/to/file` -- description
  - Commit: `[{change-name}] Add file description`

- [ ] **T02** Modify `path/to/file` -- what changes
  - Commit: `[{change-name}] Update file description`
  - Depends on: T01

## Quality Gate

- [ ] **QG** Run tests and quality checks
```

## Next step

- `/sdd-apply` — implement task by task
