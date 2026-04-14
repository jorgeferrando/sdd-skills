# /sdd-archive

> Close the SDD cycle. Merge specs into canonical and move to archive.

## Usage

```
/sdd-archive                # Archive active change
/sdd-archive {change-name}
```

## Prerequisites

- All tasks in `tasks.md` marked `[x]`
- `/sdd-verify` passed
- PR created

## What it does

### 1. Merge delta specs into canonical

For each domain in the change specs:

- Reads the canonical spec at `openspec/specs/{domain}/spec.md`
- Merges the delta (new behaviors, updated rules, decisions)
- If no canonical exists, creates it from the delta

After this step, canonical specs reflect the current system state.

### 2. Update INDEX.md

- Creates `openspec/INDEX.md` if it doesn't exist
- Adds new domains, updates existing entries
- Verifies all domains have entries

### 3. Move to archive

```bash
mv openspec/changes/{change} openspec/changes/archive/{date}-{change}
```

### 4. Summary

```
ARCHIVE COMPLETE: {change-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Canonical specs updated: core, auth
INDEX.md: updated (2 domains)
Archived to: openspec/changes/archive/2026-03-15-add-user-auth/
Active changes remaining: 1
```

## After archive

- Canonical specs are up to date
- Change artifacts are preserved in archive for history
- Start next change with `/sdd-new`

## Post-archive bugs

If a bug is found after archive, document it in the archived `tasks.md` as `POST-BUGxx` and start a new change with `/sdd-new` to fix it.
