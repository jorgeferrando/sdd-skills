---
name: sdd-verify
description: SDD Verify - Final validation before PR. Run tests, quality checks, and self-review checklist. Usage - /sdd-verify or /sdd-verify {change-name}.
model_hint: sonnet
requires: ["openspec/changes/{change}/tasks.md"]
produces: []
---

# SDD Verify

> Final validation before creating the PR. Tests + quality checks + self-review.

**Output style:** terse. Report pass/fail per check. No prose, no repeated info.

## Usage

```
/sdd-verify                # Verify active change
/sdd-verify {change-name}  # Verify specific change
```

## Prerequisites

- `/sdd-apply` completed (all tasks in tasks.md marked `[x]`)

## Step 1: Identify changed files

```bash
git diff --name-only master..HEAD    # or the base branch this change targets
```

Keep this list: Steps 2 and 3 must be scoped to these files, not to the whole project.

## Step 2: Run tests

Check `openspec/steering/tech.md` for the project's test command. Run it **scoped to the files from Step 1**, not the whole suite — a full run costs minutes (in `web`, six ~10 min shards) and the CI already does it after the Step 8 push:
```bash
# Use whatever your project uses, narrowed to the changed paths:
pytest tests/path/to/changed
npm test -- src/path/to/changed
go test ./pkg/changed/...
```

All of those tests must pass before proceeding. If no test command is configured in `tech.md` and no test runner is detected, skip this step and note it in the final report as `Tests: SKIPPED (no test runner configured)`.

## Step 3: Quality checks

Check `openspec/steering/tech.md` for configured linters/formatters. Run them on changed files:
```bash
# Examples:
ruff check src/
eslint src/
golangci-lint run
```

Fix any issues, re-run, and commit the fix atomically. If no linter is configured in `tech.md` and none is detected in the project, skip this step and note it in the final report as `Quality: SKIPPED (no linter configured)`. Do not install new tools during verify.

## Step 4: Self-review

Run the `code-review` skill in its **autorevisión** mode over the branch diff. That skill owns
the general review: it carries the finding filter, the exact file/line locations, and the
proposed fix as code. Do not restate its criteria here and do not run a second, parallel
checklist over the same diff — one review, one set of findings. If no `code-review` skill is
installed, report the general review as `SKIPPED (no code-review skill)` and continue with the
three checks below — this skill does not own general code review and will not improvise one.

Then check the three items below, which `code-review` cannot check because they are contrasted
against the SDD artifacts (`tasks.md`, `spec.md`, `design.md`) rather than against the code.
Items 1 and 3 are **non-negotiable (SDD baseline)** — a violation blocks "READY FOR PR" the same
as a failing test, regardless of what `conventions.md` says.

### 1. TDD followed (non-negotiable unless tagged `(no-TDD: ...)` in tasks.md)
- [ ] Each implementation task in `tasks.md` without a `(no-TDD: ...)` tag has a
      corresponding test that was written before (or alongside) the implementation
- [ ] `(no-TDD: ...)` tags, where present, have a genuine reason (config/docs/generated
      code/spike) — not just "skipped for speed"
- [ ] No test was retrofitted to match implementation bugs (i.e. tests assert the spec's
      expected behavior, not merely current output)

### 2. Spec compliance
- [ ] All spec cases covered
- [ ] Input/output contracts match
- [ ] Business rules implemented
- [ ] Error messages match spec

### 3. YAGNI / KISS (non-negotiable — same ladder as the `ponytail` skill)
- [ ] No speculative parameters, config knobs, or extension points beyond what
      `design.md`/`proposal.md` required
- [ ] No abstraction (interface, factory, generic layer) without a corresponding
      justification in `design.md`'s Design Decisions table
- [ ] Simplest implementation that satisfies the acceptance criteria — if a simpler
      version was rejected, that decision is documented, not silently absent

## Step 5: Smoke test (for UI/TUI projects)

If the project has a UI, run it manually and verify the changed behavior end-to-end.

If a bug is found during smoke test:
1. Document it as `BUGxx` in `tasks.md` before fixing
2. Fix and commit atomically
3. Re-run smoke test until it passes

## Step 6: Convention audit (if available)

If `openspec/steering/conventions.md` exists, run `sdd-audit` on the files changed in this branch, **limited to the rules written in `conventions.md`**. General code quality was already covered by `code-review` in Step 4; this step only answers "does it break a documented project convention". Include the audit result in the final report.

If audit finds critical violations, fix them before proceeding (same flow as Step 3: fix, commit, re-run).

## Step 7: Final report

```
VERIFY REPORT: {change-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests:    N/N PASS (changed files; full suite runs in CI)
Quality:  PASS
Self-review: N findings, M fixed (code-review, autorevisión)
Spec compliance: ✓
TDD baseline: ✓ (or: N exceptions, all tagged with reason)
YAGNI/KISS baseline: ✓
Audit:   ✓ (N rules checked, 0 violations)

Status: READY FOR PR
```

## Step 8: Create PR

Create the pull request for the change:

```bash
git push -u origin {branch-name}
```

Then create the PR **as a draft** (`gh pr create --draft`), same as `task-workflow` Paso 7: the
first push is what proves CI green on the real branch, and it is not up for review until it is.
Use `proposal.md` context for the PR title and body:
- **Title:** short summary from the proposal
- **Body:** Problem, Proposed Solution, and Acceptance Criteria sections from `proposal.md`.
  Link any issue tracker ticket as a full URL, never as a bare key.

Show the PR URL to the user for review.

## Next Step

PR created and reviewed → `/sdd-archive` to close the change.
