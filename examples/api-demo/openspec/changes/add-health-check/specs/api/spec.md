# Spec: API — Add health check endpoint

## Metadata
- **Domain:** api
- **Change:** add-health-check
- **Date:** 2026-04-15
- **Status:** approved

## Expected Behavior

### Main Case

**Given** the API server is running
**When** a client sends `GET /health`
**Then** the server responds with:
- Status: `200 OK`
- Content-Type: `application/json`
- Body: `{ "status": "healthy", "uptime": <seconds since start> }`

### Alternative Cases

| Scenario | Condition | Result |
|----------|-----------|--------|
| Server just started | Uptime < 1 second | Returns `uptime: 0` (integer, floored) |

### Errors

| Error | When | Response |
|-------|------|----------|
| Method not allowed | `POST /health` | `405` with `{ "error": "method not allowed" }` |

## Business Rules

- **BR-01:** The health endpoint MUST NOT require authentication
- **BR-02:** Uptime MUST be an integer (seconds, floored)

## Decisions Made

| Decision | Alternative discarded | Reason |
|---------|-----------------------|--------|
| Return integer seconds for uptime | Milliseconds or ISO duration | Simplicity — seconds are universally understood |
| Include only status + uptime | Add version, commit hash | Minimize info exposure for a demo project |
