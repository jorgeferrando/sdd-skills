# Specialist: Readability

> Rules for code that is easy to read, understand, and maintain.
> Read by sdd-apply, sdd-audit, and sdd-verify.

## Naming

- **MUST** use names that reveal intent. A reader should understand what a variable holds or what a function does without reading the implementation. `remainingRetries` not `r`. `fetchUserByEmail` not `getUser`.
- **MUST NOT** abbreviate unless the abbreviation is universally understood in the domain (`id`, `url`, `http`, `db`, `api`). `cfg`, `mgr`, `srv`, `btn`, `usr` are not acceptable.
- **MUST NOT** use single-letter variables except for trivial loop indices (`i`, `j`) and well-established math/lambda conventions (`x => x.name`).
- **MUST** name booleans as questions: `isActive`, `hasPermission`, `canRetry`. Not `active`, `permission`, `retry`.
- **MUST** name functions as actions: `calculateTotal`, `sendNotification`, `validateInput`. Not `total`, `notification`, `input`.
- **SHOULD** avoid negative booleans: prefer `isEnabled` over `isNotDisabled`. Negating a negative is hard to read.

## Functions

- **MUST** keep functions focused on a single task. If the function name needs "and" (`fetchAndTransformAndSave`), it is doing too much.
- **MUST** keep parameter count at 3 or fewer. More than 3 parameters signals the function needs an options object or is doing too much.
- **SHOULD** return early for error conditions instead of nesting. Guard clauses at the top, happy path at the bottom.
- **SHOULD** avoid flag parameters (`process(data, true)`). A boolean parameter means the function does two different things — split it.

## Conditionals

- **MUST** extract complex conditionals into named variables or functions. `if (user.age >= 18 && user.hasConsent && !user.isBanned)` becomes `if (canPurchase(user))`.
- **MUST NOT** use nested ternaries. One level is acceptable: `const label = isActive ? 'on' : 'off'`. Two levels is not.
- **SHOULD** prefer positive conditions. `if (isValid)` is easier to read than `if (!isInvalid)`.

## Comments

- **MUST NOT** write comments that restate the code. `// increment counter` above `counter++` is noise.
- **MUST** write comments only when the code cannot explain the **why**. Business rules, workarounds for known bugs, and non-obvious performance decisions deserve comments.
- **SHOULD** use the code itself as documentation: descriptive names, clear structure, and small functions reduce the need for comments.

## Structure

- **MUST** keep nesting depth at 3 levels or fewer. Deeply nested code is hard to follow — extract inner blocks into named functions.
- **SHOULD** group related code together. Variables should be declared close to where they are used, not all at the top.
- **SHOULD** order functions in a file by call hierarchy: public/exported functions first, then the private helpers they call. A reader starts at the top and drills down.

## How to detect violations

When reviewing code (during sdd-apply or sdd-audit), flag:
1. Variables named with single letters or abbreviations not in the accepted list
2. Functions with more than 3 parameters
3. Boolean variables that don't read as questions
4. Comments that restate the code
5. Nesting deeper than 3 levels
6. Conditionals with more than 2 clauses not extracted to a named function

Classify as **Important** — readability violations are technical debt, not blockers.
