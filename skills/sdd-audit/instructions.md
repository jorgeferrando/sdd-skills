---
name: sdd-audit
description: SDD Audit - Analyzes the codebase against conventions.md, project-rules.md, tech.md and structure.md, producing a classified report with correction prompts. Use whenever the user asks to review a PR, review code, review this branch/diff, or check code before merging — even without the exact "/sdd-audit" command — so review stays consistent with this project's conventions instead of a generic review. Usage - /sdd-audit, /sdd-audit src/path/, or /sdd-audit PR-123.
model_hint: sonnet
requires: ["openspec/steering/conventions.md"]
produces: []
---

# SDD Audit

> Detects architecture violations before PR review.
> Analyzes modified files against conventions in `openspec/steering/conventions.md`
> and implementation rules in `openspec/steering/project-rules.md`.

**This is the default skill for any PR/code review request in this project.** When the
user asks to "review this PR", "check this code before merging", "look over my changes",
or similar — in chat, not just via `/sdd-audit` — use this skill instead of a generic,
convention-agnostic review. A generic review misses this project's specific rules and
peculiarities; this one is anchored to them.

**Output style:** terse. One line per violation: `[C01] file:line — description`. Tables for summary. No prose.

## Usage

```
/sdd-audit                  # Analyze files modified in current branch
/sdd-audit src/components/  # Analyze a specific directory or file
/sdd-audit PR-123           # Analyze a specific GitHub PR by number
/sdd-audit https://github.com/{org}/{repo}/pull/123
"review this PR"            # Natural language — same as /sdd-audit
```

## Prerequisites

- `openspec/steering/conventions.md` must exist
- If missing: run `/sdd-steer` (existing project) or `/sdd-init` (new project) first

## Step 1: Verify prerequisites

```bash
ls openspec/steering/conventions.md
```

If missing:
```
⚠️  openspec/steering/conventions.md not found.

Run /sdd-init to set up your project context first.
Without a conventions baseline, audit has no reference.
```
**STOP** — do not continue without conventions.md.

## Step 2: Load ruleset

Read steering files as a unified ruleset:

1. Read `openspec/steering/conventions.md` (required)
2. If `openspec/steering/project-rules.md` exists → read it too
3. **Project peculiarities**: read `openspec/steering/tech.md` and `openspec/steering/structure.md`
   if they exist — not as extra rules, but as context so findings respect this project's
   actual stack, layering, and known technical constraints (e.g. don't flag a pattern as
   wrong if `structure.md` documents it as the intended layering for this codebase).
4. **Monorepo check**: if `openspec/steering/projects.md` exists, this is a monorepo with
   multiple sub-projects — `conventions.md` above holds only cross-cutting rules. Read
   `projects.md` now to get the path-prefix → sub-project → conventions-source table; the
   actual per-file ruleset is resolved per sub-project in Step 3 once scope is known. Do
   NOT apply `conventions.md` rules meant for one stack (e.g. PHP `final class`) to files
   in another sub-project (e.g. React components) — this is exactly what `projects.md`
   prevents.
5. **Selective specialist loading**: load only `conventions-*.md` files relevant to the files in scope:
   - Specialists with `applies_to: all` in their manifest → always load
   - `conventions-testing.md` / `conventions-tdd.md` → only when scope includes test files
   - `conventions-security.md` → only when scope includes auth, API, or input handling files
   - `conventions-refactoring.md` → only when scope includes modified (not newly-added) files,
     or the user explicitly asks to detect code smells / suggest a refactor — new files being
     built to spec are not refactor candidates yet
   - Other specialists → load only when scope files match the specialist's domain
   - Skip irrelevant specialists to reduce context size

All loaded rules are treated equally regardless of source file.

**SDD baseline (always checked, independent of conventions.md content):** in addition to
the project's own rules, always check YAGNI and KISS as implicit `MUST` rules:
- **YAGNI violation** → speculative parameters/config/extension points not required by
  the spec or task in scope
- **KISS violation** → an abstraction (interface, factory, generic layer) present without
  a documented justification in the corresponding `design.md`, where one exists
Report these under Critical like any other MUST violation, tagged `[source: SDD baseline]`
— this holds even for projects whose `conventions.md` doesn't mention them explicitly.

**Note:** Rules in `project-rules.md` that duplicate linter coverage (e.g. quote style
already enforced by ruff/eslint) should NOT generate audit violations — the audit is
semantic, not syntactic.

## Step 3: Determine analysis scope

**No argument:**
```bash
git diff --name-only $(git merge-base HEAD main 2>/dev/null || echo "HEAD~10") HEAD
```
Use files modified since the branch diverged from base.

**With path argument:**
Use files at the provided path.

**With a PR reference** (`PR-123`, `#123`, or a GitHub PR URL):
```bash
gh pr diff 123 --name-only
```
Use the PR's changed files, not the local working tree — this covers reviewing someone
else's PR that isn't checked out locally. If `gh` fails (no access, wrong repo), fall back
to asking the user to check out the branch locally.

**Natural-language "review this PR" with no explicit reference:**
If a PR is associated with the current branch, resolve it first:
```bash
gh pr view --json number,url 2>/dev/null
```
If found, use its diff (same as the PR-reference case above). If not found, fall back to
the no-argument case (diff since branch diverged from base).

**Monorepo ruleset resolution** (only when `projects.md` exists, from Step 2):
For each file in scope, match its path against the `projects.md` prefix table (longest
prefix wins) to determine its sub-project. Group files by sub-project, then for each
group load that sub-project's conventions source (its `AGENTS.md`/`docs/conventions.md`/
etc., as recorded in `projects.md`) as the ruleset for those files only, merged with the
cross-cutting rules from root `conventions.md`. A file in `adiona/` is audited against
`adiona/docs/conventions.md` + root cross-cutting rules — never against
`frontend_next/AGENTS.md`.

Show scope before analyzing:
```
Analyzing: 4 modified files since main
  src/components/UserCard.tsx
  src/services/user.service.ts
  tests/user.service.spec.ts
  ...
Ruleset: conventions.md (12 rules) + project-rules.md (8 rules) = 20 rules
```

In monorepo mode, show the per-sub-project breakdown instead:
```
Analyzing: 6 modified files since main
  frontend_next/components/Card.tsx        → frontend_next (frontend_next/AGENTS.md)
  adiona/src/TravelOps/Booking.php         → adiona (adiona/docs/conventions.md)
  ...
Ruleset: root cross-cutting (4 rules) + frontend_next (9 rules) + adiona (14 rules)
```

If scope > 20 files: ask user if they want to limit the analysis.

## Step 4: Analyze each file

For each file in scope:
1. Read the file
2. Check each MUST/MUST NOT rule from the relevant area — in monorepo mode, use the
   ruleset resolved for that file's sub-project (Step 3), not the full merged set
3. Note violations with approximate line and concrete description

Classification:
- **Critical**: violates `MUST` or `MUST NOT` — typically flagged in PR review
- **Important**: violates `SHOULD` — accumulating technical debt
- **Minor**: violates `MAY` — stylistic or preference

Source of each violation (conventions.md vs project-rules.md vs sub-project doc) is shown for context.

## Step 5: Generate report

```
## Audit Report — {project} — {date}
Scope: {N files analyzed} | Rules checked: {N} (conventions: {N} + project-rules: {N})

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Critical (blocks PR review)

- [C01] `{path/file.ts}:{approx line}` — {concrete description of violation}
  - Rule: {area} — MUST {rule} [{source: conventions.md}]
  - Fix: {what to change exactly}

- [C02] `{path/file.ts}:{approx line}` — {description}
  - Rule: {area} — MUST NOT {rule} [{source: project-rules.md}]
  - Fix: {what to change}

### Important (technical debt)

- [I01] `{path/file.ts}:{approx line}` — {description}
  - Rule: {area} — SHOULD {rule} [{source}]
  - Fix: {what to change}

### Minor

- [M01] `{path/file.ts}:{approx line}` — {description}
  - Rule: {area} — MAY {rule} [{source}]
  - Fix: {what to change}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Summary

| Level | Count |
|-------|-------|
| Critical | {N} |
| Important | {N} |
| Minor | {N} |
| Total | {N} |

## SDD Actions

{Only if there are criticals or importants:}

To fix critical violations:
/sdd-new "fix: {grouped description — one line max}"

{If multiple areas of technical debt:}
For {area} debt:
/sdd-new "refactor: {description}"
```

If no violations:
```
✓ No violations found — conventions upheld.
  {N files analyzed}, {N rules checked}
```

## Step 6: Final recommendation

If criticals found:
```
⚠️  {N} critical violations found.
Fix before creating the PR — these are typically flagged in code review.
```

If only important/minor:
```
ℹ️  {N} non-critical issues. Can be deferred by documenting them in tasks.md.
```

---

## Notes

- Audit is **semantic**, not syntactic — complements linters (ruff, eslint, PHPStan), does not replace them.
- Audit does NOT modify code — only reports and suggests prompts.
- `/sdd-new` prompts group violations by domain, not one prompt per violation.
- In `/sdd-verify`: if `conventions.md` exists, run this audit on change files as an additional step (SHOULD, not MUST).
