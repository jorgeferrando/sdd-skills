---
name: sdd-archive
description: SDD Archive - Close the change cycle. Move the change to the archive and update canonical specs. Usage - /sdd-archive or /sdd-archive {change-name}.
requires: ["openspec/changes/{change}/tasks.md", "openspec/changes/{change}/specs/*/spec.md"]
produces: ["openspec/specs/*/spec.md", "openspec/INDEX.md", "openspec/changes/archive/", "openspec/steering/learnings.md"]
---

# SDD Archive

> Close the SDD cycle. Move the change to the archive and merge specs into the canonical ones.

## Usage

```
/sdd-archive                   # Archive active change
/sdd-archive {change-name}     # Archive specific change
```

## Prerequisites

- `/sdd-verify` completed (all checks green, PR created)

## Step 1: Verify state

Before archiving, confirm:
1. All tasks in `tasks.md` marked `[x]`
2. `/sdd-verify` passed
3. PR exists (created during verify)

```bash
# Should return 0
grep -c "\[ \]" openspec/changes/{change-name}/tasks.md
```

## Step 2: Update canonical specs

The change specs (`openspec/changes/{change}/specs/`) contain **deltas**.
Now merge them into the canonical specs (`openspec/specs/`).

For each `openspec/changes/{change}/specs/{domain}/spec.md`:
1. Read the current canonical spec at `openspec/specs/{domain}/spec.md`
2. Read the change delta
3. Merge: update the canonical with new behaviors, rules, decisions
4. Update the canonical metadata (version, date)

If no canonical spec exists for the domain, create it:
```bash
mkdir -p openspec/specs/{domain}
cp openspec/changes/{change}/specs/{domain}/spec.md openspec/specs/{domain}/spec.md
```

## Step 2b: Update openspec/INDEX.md

### If `openspec/INDEX.md` does NOT exist

Check whether `openspec/specs/` contains any domains:

- **Domains found** → **Bootstrap**: read each `specs/{domain}/spec.md` and generate a complete
  `openspec/INDEX.md` with one entry per domain following this format:
  ```markdown
  # OpenSpec Index

  > Index of canonical domains. Updated by sdd-archive on each change.
  > **Usage:** read this file first; load only the spec files relevant to the change.
  > If this file does not exist, scan openspec/specs/ directly.

  ---

  ## {domain} (`specs/{domain}/spec.md`)
  {1-2 line summary of what this domain covers}
  **Entities:** {Symbol1}, {function()}, {ClassName}
  **Keywords:** {kw1}, {kw2}, {kw3}
  ```
  After generating, continue with the update logic below (the current change may introduce
  new entities that should already be in the freshly created index).

- **No domains found** → skip this step silently (no point creating an empty index).

### If `openspec/INDEX.md` exists

1. For each domain modified in this change, update its entry in INDEX.md:
   - Refresh the summary if the domain's scope changed significantly
   - Add any new entities introduced by this change to `**Entities:**`
   - Add new keywords if relevant new concepts were introduced

2. If this change adds a **new domain** (new entry under `openspec/specs/`):
   - Add a new entry to INDEX.md following the existing format.

3. After updating, verify that every directory in `openspec/specs/` has an entry in INDEX.md.
   If any domain is missing, warn the user:
   > ⚠️ Domain `{domain}` exists in openspec/specs/ but has no entry in INDEX.md. Add it before continuing.

## Step 3: Move to archive

```bash
DATE=$(date +%Y-%m-%d)
CHANGE={change-name}
mv "openspec/changes/${CHANGE}" "openspec/changes/archive/${DATE}-${CHANGE}"
```

## Step 4: Verify post-archive structure

```bash
ls openspec/changes/          # change should be gone from active
ls openspec/changes/archive/  # change should appear here
ls openspec/specs/            # canonical specs updated
```

## Step 5: Update learnings

Append a new entry to `openspec/steering/learnings.md` (create the file if it doesn't exist).

Reflect on what happened during this change cycle and extract useful signals. Write only what is non-obvious and would help future changes — skip boilerplate.

Look at:
- Alternatives discarded in `design.md` — why were they rejected?
- Tasks that were re-opened or re-done — what assumption was wrong?
- Domains that were touched unexpectedly — are they coupled?
- Conventions that were violated and then corrected — should they be explicit?
- Any recurring pattern that appeared in this change for the second time or more

Append to `openspec/steering/learnings.md`:

```markdown
## {YYYY-MM-DD} — {change-name}

**Domains touched:** {domain1}, {domain2}

**Decisions:**
- {What was decided and why — especially if it contradicts what someone might naturally do}

**Discarded alternatives:**
- {Alternative} — {reason it was rejected}

**Unexpected couplings:**
- {module A} ↔ {module B}: {why they turned out to be linked}

**Anti-patterns confirmed:**
- {What not to do here} — {observed consequence}

**Open questions:**
- {Something that was deferred or left unresolved}
```

Omit any section that has nothing meaningful to say. Do not pad with generic observations.

If `openspec/steering/learnings.md` does not exist, create it with this header first:

```markdown
# Project Learnings

> Incremental memory. Appended by sdd-archive after each change cycle.
> Read by sdd-recall before searching the archive.
> Each entry captures non-obvious decisions, couplings, and anti-patterns.

---
```

## Step 6: Summary

```
ARCHIVE COMPLETE: {change-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Archived at:
  openspec/changes/archive/{date}-{change-name}/

Canonical specs updated:
  openspec/specs/{domain}/spec.md ✓

Learnings updated:
  openspec/steering/learnings.md ✓

Active changes remaining: N
```

## Bugs found after archive

If a bug is discovered after archiving:

1. Document it in the archived `tasks.md` under `## Bugs post-archive`
2. Implement the fix and commit
3. Mark `[x]` with the commit message

```markdown
## Bugs post-archive

- [x] **BUG01** `path/file` — short symptom description
  - Found: {context}
  - Fix: {description}
  - Commit: `{commit message}`
```

## Notes

- `openspec/` is local by default — never committed (unless the project opts in)
- The archive is historical context for future changes in the same domain
