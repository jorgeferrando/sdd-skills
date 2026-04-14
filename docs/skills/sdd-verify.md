# /sdd-verify

> Final validation before creating a PR. Tests, quality checks, and self-review.

## Usage

```
/sdd-verify                # Verify active change
/sdd-verify {change-name}
```

## Prerequisites

- All tasks in `tasks.md` marked `[x]`

## What it checks

### 1. Tests

Runs the full test suite for the project:

```bash
# Whatever your project uses:
pytest
npm test
go test ./...
```

All tests **must pass** before proceeding.

### 2. Linters and formatters

Runs lint/format on changed files. Fixes issues, re-runs, commits atomically if needed.

### 3. Self-review checklist

| Check | Criteria |
|-------|----------|
| Test coverage | Tests exist for new functions, edge cases, error paths |
| Input validation | Validated at system boundaries |
| Method size | < 50 lines, < 3 nesting levels |
| No hardcoded values | Uses constants or enums |
| No duplication | DRY within reason |
| Type hints | Complete and correct |
| Null safety | Null/None checks in place |
| Spec compliance | Implementation matches the behavior spec |

### 4. Smoke test (UI projects)

For TUI/UI projects, runs the application and verifies the golden path manually. Documents any issues found as `BUGxx` in `tasks.md`.

## Output

```
VERIFY REPORT: {change-name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests:          PASS (42 passed)
Lint:           PASS
Self-review:    PASS (8/8 checks)
Spec compliance: PASS

Status: READY FOR PR
```

## Next step

- `/sdd-archive` — close the cycle, merge specs, create PR
