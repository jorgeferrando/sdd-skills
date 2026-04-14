# /sdd-design

> Translate the behavior spec into a concrete implementation plan.

## Usage

```
/sdd-design                # Design for active change
/sdd-design {change-name}
```

## Prerequisites

- `proposal.md` and `specs/` approved

## What it does

1. **Reviews context** — reads proposal, spec, and existing code patterns
2. **Scope analysis** — lists ALL files to create or modify
3. **Creates `design.md`** — technical summary, file list, decisions, implementation notes
4. **Validates with user** — presents design for feedback

## Scope assessment

| Files | Assessment | Action |
|-------|-----------|--------|
| < 10 | Ideal | Proceed |
| 10-20 | Evaluate | Consider splitting |
| > 20 | Split required | Break into multiple changes |

## Artifact format

```markdown
# Design: {Change Title}

## Technical Summary
{1-2 paragraphs on approach}

## Files to Create
| File | Type | Purpose |
|------|------|---------|

## Files to Modify
| File | Change | Reason |
|------|--------|--------|

## Design Decisions
{Alternatives considered and why this approach was chosen}

## Implementation Notes
{Gotchas, ordering constraints, known issues}
```

## Next step

- `/sdd-continue` — proceeds to the tasks phase
