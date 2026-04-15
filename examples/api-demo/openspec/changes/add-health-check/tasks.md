# Tasks: Add health check endpoint

## Metadata
- **Change:** add-health-check
- **Ticket:** N/A
- **Branch:** add-health-check
- **Date:** 2026-04-15

## Implementation Tasks

- [x] **T01** Create `src/routes/health.js` — health check route handler
  - Commit: `[add-health-check] Add health route handler`

- [x] **T02** Modify `src/index.js` — import health handler, add route dispatch, record start time
  - Commit: `[add-health-check] Wire up health endpoint in server`
  - Depends on: T01

- [x] **T03** Create `test/health.test.js` — test health endpoint
  - Commit: `[add-health-check] Add health endpoint tests`
  - Depends on: T01, T02

## Quality Gate

- [x] **QG** Run tests and quality checks
  - `node --test`
