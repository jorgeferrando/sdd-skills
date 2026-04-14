# /sdd-steer

> Generate or update steering files. Use when conventions drift or after major refactors.

## Usage

```
/sdd-steer          # Bootstrap: generate all steering files from scratch
/sdd-steer sync     # Detect drift and propose updates
```

## Bootstrap mode

Generates all steering files by:

1. Loading project skills (architecture, code-quality)
2. Exploring the codebase (directory structure, config files, representative files)
3. Reading `MEMORY.md` and existing `openspec/specs/`
4. Generating `product.md`, `tech.md`, `structure.md`, `conventions.md`

Use when `/sdd-init` was not run or steering files need regeneration.

## Sync mode

Compares current conventions against three sources (in priority order):

1. **Project skills** — most reliable source
2. **MEMORY.md** — patterns discovered in previous sessions
3. **Current code** — empirical evidence

Presents proposed changes:

```
DRIFT DETECTED in conventions.md:

ADD (new conventions found):
+ ## Signals
+   - MUST use signal() for reactive state

UPDATE (outdated convention):
~ OLD: MUST NOT use async/await directly
~ NEW: MUST use async/await with asyncio mode

REMOVE (no longer applies):
- MUST support Python 3.9 (min is now 3.13)

Apply these changes? (y/n/select)
```

!!! warning
    Sync mode **does not auto-apply**. It always asks for confirmation.

## Next step

- `/sdd-audit` — verify the codebase against updated conventions
