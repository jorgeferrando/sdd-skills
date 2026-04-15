# Proposal: Add health check endpoint

## Metadata
- **Change:** add-health-check
- **Ticket:** N/A
- **Date:** 2026-04-15

## Context

The API has a single root endpoint. Monitoring and orchestration tools (load balancers, Kubernetes, uptime checks) need a dedicated health endpoint to determine if the service is running and ready to serve traffic.

## Problem

There is no way to programmatically check if the API is healthy. The root endpoint (`/`) returns `{ "status": "ok" }` but it is semantically a general-purpose response, not a health signal. Monitoring tools need a conventional `/health` endpoint.

## Scope

**In scope:**
- `GET /health` endpoint returning service status
- Response includes uptime

**Out of scope:**
- Dependency checks (database, external services)
- Authentication
- Metrics or Prometheus format

## Proposed Solution

Add a `GET /health` route that returns `200 OK` with a JSON body containing `status` and `uptime` fields. Implement as a separate route handler file following the project conventions.

## Alternatives Discarded

| Alternative | Reason discarded |
|-------------|-----------------|
| Reuse `GET /` as health check | Mixes concerns — root should describe the API, not its health |
| Return plain text `OK` | Inconsistent with JSON-only API convention |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Endpoint exposes internal info | Low | Low | Only return uptime, no version or env details |

## Impact

- **Files affected:** 2 (1 new route handler, 1 modified index.js)
- **Domains:** api
- **Tests:** 1 new test file for the health endpoint

## Dependencies

- None

## Acceptance Criteria

- [ ] `GET /health` returns `200` with `{ "status": "healthy", "uptime": <number> }`
- [ ] Other endpoints continue working unchanged
- [ ] Test covers happy path
