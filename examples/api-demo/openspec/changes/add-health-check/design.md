# Design: Add health check endpoint

## Metadata
- **Change:** add-health-check
- **Date:** 2026-04-15
- **Status:** approved

## Technical Summary

Add a health check route handler in a new file under `src/routes/`. Modify the main server to import and dispatch to this handler when the path matches `/health`. Record the server start time at boot to calculate uptime.

## Architecture

```
Request GET /health
  → index.js (routing)
    → routes/health.js (handler)
      → Response { status: "healthy", uptime: N }
```

## Files to Create

| File | Type | Purpose |
|------|------|---------|
| `src/routes/health.js` | Route handler | Returns health status + uptime |
| `test/health.test.js` | Test | Validates health endpoint behavior |

## Files to Modify

| File | Change | Reason |
|------|--------|--------|
| `src/index.js` | Import health handler, add route dispatch, record start time | Wire up the new endpoint |

## Scope

- **Total files:** 3
- **Result:** Ideal

## Design Decisions

| Decision | Alternative | Reason |
|---------|------------|--------|
| Separate route file | Inline in index.js | Follows convention: one file per domain in routes/ |
| Pass startTime as parameter | Global variable | Explicit dependency, testable |

## Implementation Notes

- `startTime` is captured once at server boot via `Date.now()`
- Health handler receives `startTime` and computes `Math.floor((Date.now() - startTime) / 1000)`
- The `src/routes/` directory does not exist yet — create it
