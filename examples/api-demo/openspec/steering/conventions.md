# Conventions: api-demo

> Rules that cause PR review failures. RFC 2119 levels: MUST / MUST NOT / SHOULD / MAY.

## Bootstrap decisions
- Architecture: simple layered — single-purpose demo, no ceremony needed
- Testing: tests-after — small scope, fast iteration
- Commit format: `[change-name] Description` — SDD default

## HTTP responses
- **MUST** return JSON with `Content-Type: application/json`
- **MUST** use standard HTTP status codes (200, 404, 500)
- **MUST NOT** return HTML from API endpoints

## Code style
- **MUST** use ES module imports (`import`, not `require`)
- **SHOULD** keep route handlers in separate files under `src/routes/`

## Testing
- **MUST** test happy path and error cases for each endpoint
- **SHOULD** use `node --test` (built-in, no dependencies)
