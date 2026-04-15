# Specialist: Test-Driven Development

> Enforces the TDD cycle: Red → Green → Refactor.
> Affects sdd-tasks (task ordering), sdd-apply (implementation flow), and sdd-audit (verification).

## The TDD cycle

Every implementation task follows this sequence:

1. **Red** — Write a test that describes the expected behavior. Run it. It MUST fail.
2. **Green** — Write the minimum code to make the test pass. No more.
3. **Refactor** — Clean up the code while keeping tests green.

This is not optional when this specialist is active. It is the law.

## Task ordering (affects sdd-tasks)

- **MUST** create test tasks BEFORE their corresponding implementation tasks. For each file to create or modify, the task list must follow this pattern:

  ```
  - [ ] **T01** Create `test/rate-limit.test.js` — test: returns 429 when limit exceeded
  - [ ] **T02** Create `src/middleware/rate-limit.js` — implement rate limit middleware (make T01 pass)
  - [ ] **T03** Create `test/rate-limit-config.test.js` — test: reads limit from config
  - [ ] **T04** Modify `src/middleware/rate-limit.js` — add configurable limits (make T03 pass)
  ```

- **MUST NOT** create a task that writes implementation code without a preceding test task for the same behavior.
- **MUST** keep test and implementation tasks as adjacent pairs. Do not batch all tests first and all code second — interleave them by behavior.

## Implementation flow (affects sdd-apply)

- **MUST** run the test BEFORE writing implementation code to confirm it fails (Red). If the test passes before implementation, the test is not testing new behavior — rewrite it.
- **MUST** write only enough code to make the failing test pass (Green). Do not add behavior that is not covered by a failing test.
- **MUST** run all tests after each implementation to verify no regressions.
- **MUST NOT** write code "that will be tested later." Every line of production code exists because a test demanded it.
- **SHOULD** commit the Red test and the Green implementation as a single atomic commit. The commit message should reference both: `[change] Add rate limit middleware with tests`.

## What counts as "the test"

- **MUST** test behavior through the public API of the unit, not internal methods.
- **MUST** write the test at the appropriate level:
  - New function/method → unit test
  - New endpoint/route → integration test
  - New user-facing workflow → acceptance test (if test infrastructure exists)
- **MUST NOT** write tests that simply assert the implementation exists (e.g., `assert typeof rateLimit === 'function'`). The test must verify BEHAVIOR.

## Exceptions — when TDD is not required

- **MAY** skip TDD for trivial structural changes that have no logic: adding a type export, renaming a constant, updating a config value.
- **MAY** skip TDD for generated code (migrations, schema files) where the generator's tests cover correctness.
- **MUST** still write TDD for any change that includes conditional logic, even if it seems simple.

## Refactoring phase

- **SHOULD** refactor after each Green phase if the implementation has obvious duplication or unclear naming.
- **MUST** keep tests green during refactoring. If a refactor breaks a test, the refactor is wrong, not the test.
- **MUST NOT** add new behavior during refactoring. New behavior requires a new Red test first.

## How to detect violations

When reviewing code (during sdd-apply or sdd-audit), flag:
1. Implementation code committed without a corresponding test in the same or preceding commit
2. Tests that pass on the first run without any implementation changes (test does not test new behavior)
3. Task ordering where implementation precedes its test
4. Tests that verify implementation details (mock call counts, internal method names) instead of behavior
5. Large implementation changes with a single test that only covers the happy path

Classify as **Critical** — TDD violations undermine the entire methodology. Code without a preceding failing test must be rewritten using the TDD cycle.

## Effect on other specialists

When active alongside other specialists:
- **testing** specialist rules still apply (proper doubles, no redundancy)
- **anti-overengineering** rules still apply (do not over-abstract in the Green phase — write the minimum)
- TDD naturally prevents over-engineering: you cannot write code that no test demands
