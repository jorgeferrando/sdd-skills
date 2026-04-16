# /sdd-recall

> Search archived specs and past decisions for context relevant to the current problem.

## Usage

```
/sdd-recall "authentication middleware"   # Search by topic
/sdd-recall api                           # Search by domain
/sdd-recall                               # Show all domains with summaries
/sdd-recall compact                       # Synthesize and prune learnings.md
```

## Prerequisites

- `openspec/` initialized
- At least one archived change or canonical spec exists

## What it does

### Search mode (default)

1. **Reads** `openspec/steering/learnings.md` first — synthesized decisions, couplings, and anti-patterns from past cycles
2. **Scans** canonical specs (`openspec/specs/`), archived changes (`openspec/changes/archive/`), and the index (`openspec/INDEX.md`)
3. **Matches** the query against domain names, problem descriptions, design decisions, business rules, and keywords
4. **Ranks** results by relevance (learnings > canonical > archived, exact match > partial)
5. **Presents** a grouped summary with source references
6. **Suggests** how the found context applies to the current work

### Compact mode (`/sdd-recall compact`)

Reviews `openspec/steering/learnings.md` and proposes a cleanup plan:

- **Merge** — duplicate entries about the same domain → keep the most precise
- **Supersede** — later entry contradicts an earlier one → keep the latest
- **Remove** — entry refers to a module or pattern that no longer exists
- **Promote** — anti-pattern that appears 3+ times → suggest adding it to `conventions.md`

Shows the plan and waits for confirmation before rewriting the file. Any entry promoted to conventions is shown as text to add manually — it does not write `conventions.md` automatically.

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
- Periodically — run `/sdd-recall compact` to keep `learnings.md` lean and actionable
