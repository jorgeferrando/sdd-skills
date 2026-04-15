# /sdd-recall

> Search archived specs and past decisions for context relevant to the current problem.

## Usage

```
/sdd-recall "authentication middleware"   # Search by topic
/sdd-recall api                           # Search by domain
/sdd-recall                               # Show all domains with summaries
```

## Prerequisites

- `openspec/` initialized
- At least one archived change or canonical spec exists

## What it does

1. **Scans** canonical specs (`openspec/specs/`), archived changes (`openspec/changes/archive/`), and the index (`openspec/INDEX.md`)
2. **Matches** the query against domain names, problem descriptions, design decisions, business rules, and keywords
3. **Ranks** results by relevance (canonical > archived, exact match > partial)
4. **Presents** a grouped summary with source references
5. **Suggests** how the found context applies to the current work

## Output format

```
RECALL: "authentication middleware"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Canonical specs:
  openspec/specs/auth/spec.md
    - BR-01: Sessions expire after 24h of inactivity

Archived decisions:
  openspec/changes/archive/2026-03-10-add-auth/design.md
    - Chose JWT over session cookies — stateless

Suggestions:
  - The auth domain already has conventions — follow them
  - Admin roles were explicitly deferred — start a new spec if needed
```

## When to use

- Before `/sdd-new` — check if a similar problem was solved before
- During `/sdd-propose` — find alternatives that were already evaluated
- During `/sdd-design` — review past architectural decisions in the same domain
- When onboarding — understand why things were built a certain way
