# /sdd-spec

> Create a behavior specification — what the system should do, not how.

## Usage

```
/sdd-spec                  # Spec for active change
/sdd-spec {change-name}    # Spec for specific change
```

## Prerequisites

- `proposal.md` created and reviewed

## What it does

1. **Reads proposal.md** — understands problem, scope, and solution before identifying domains
2. **Checks canonical spec** — reads `openspec/specs/{domain}/spec.md` if it exists
3. **Creates delta spec** — only what changes, not a full replacement
4. **Clarifies behavior** — asks about edge cases, validation rules, errors
5. **Presents for review** — applies feedback before saving

## Key concepts

**Delta spec, not full spec.** The change spec only documents new or modified behaviors. On archive, it gets merged into the canonical spec.

**Behavior, not implementation.** Specs describe what the system does ("when a user submits an invalid email, the system returns a 422 error"), not how ("use regex to validate email format").

**Given/When/Then format** for behavior definitions:

```markdown
### User Registration

**Given** a visitor on the registration page
**When** they submit a valid email and password
**Then** the system creates an account and sends a confirmation email

**Given** a visitor on the registration page
**When** they submit an email that already exists
**Then** the system returns a 409 Conflict error
```

## Artifacts produced

- `openspec/changes/{change-name}/specs/{domain}/spec.md`

## Next step

- `/sdd-continue` — proceeds to the design phase
