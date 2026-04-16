# Specialist: Performance

> Rules to avoid common performance pitfalls without falling into premature optimization.
> These are known traps, not micro-optimizations.
> Read by sdd-apply, sdd-audit, and sdd-verify.

## Data loading

- **MUST** paginate all endpoints and queries that return collections. Never return unbounded lists. Default page size should be explicit (e.g., 20, 50).
- **MUST NOT** load entire tables or collections into memory. Use cursors, streams, or pagination for large datasets.
- **MUST** select only the fields needed. Avoid `SELECT *` in SQL and full-document fetches in NoSQL when only a subset of fields is used.
- **MUST NOT** fetch related data inside a loop (N+1 problem). Use joins, eager loading, or batch queries instead.

## Computation

- **MUST NOT** perform expensive computation (sorting, filtering, aggregation) on the full dataset when the database can do it. Push work to the query layer.
- **MUST NOT** recompute values that don't change between requests. Cache results that are expensive to produce and rarely change.
- **SHOULD** debounce or throttle high-frequency operations (event handlers, search inputs, resize listeners).
- **SHOULD** use lazy evaluation for data that may not be needed. Don't compute the full result if only the first page is requested.

## Network and I/O

- **MUST** parallelize independent I/O operations (API calls, file reads, database queries). Sequential `await` for independent operations wastes time.
- **MUST NOT** make synchronous I/O calls in request handlers or event loops. All I/O must be async.
- **SHOULD** set timeouts on all external HTTP calls. A missing timeout means a stuck dependency can hang the entire service.
- **SHOULD** compress API responses when the payload exceeds 1KB (gzip, brotli).

## Frontend (when applicable)

- **MUST** lazy-load routes, components, or modules that are not needed on initial render.
- **MUST NOT** include large libraries in the main bundle when only a small utility is used. Import the specific function, not the entire library.
- **SHOULD** defer loading of below-the-fold images and non-critical assets.
- **SHOULD** avoid layout shifts by setting explicit dimensions on images and dynamic content.

## Database

- **MUST** add indexes for columns used in WHERE, JOIN, and ORDER BY clauses on tables expected to grow beyond 1000 rows.
- **MUST NOT** run schema migrations that lock large tables during peak traffic. Use non-blocking migration strategies (add column → backfill → add constraint).
- **SHOULD** use connection pooling for database connections. One connection per request does not scale.

## What this specialist does NOT do

- Does NOT micro-optimize (bit shifting, loop unrolling, avoiding object allocation). Those are rarely the bottleneck.
- Does NOT require benchmarks before every decision. These rules prevent **known traps**, not hypothetical slowness.

## How to detect violations

When reviewing code (during sdd-apply or sdd-audit), flag:
1. Endpoints returning collections without pagination parameters
2. Database queries inside loops (N+1)
3. `SELECT *` when only specific fields are used downstream
4. Sequential `await` on independent async operations
5. Synchronous I/O in async contexts
6. Missing timeouts on HTTP clients
7. Full library imports when tree-shakeable alternatives exist

Classify as **Important** — performance pitfalls are technical debt, not immediate blockers. Exception: N+1 queries in hot paths are **Critical**.
