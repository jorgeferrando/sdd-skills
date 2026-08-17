# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-08-17

Bug flow becomes a first-class citizen, and GitHub Copilot now installs via its native plugin marketplace.

### Added

- **`sdd-bug`** — bug-specific entry point that validates an 8-item evidence gate (current behavior, expected behavior, reproduction, evidence source, impact, affected scope, root cause status, regression guard) before drafting a proposal. Emits `Bug intake incomplete` with a single focused clarification question when evidence is missing, and never invents answers to close gaps. Supports an explicit `draft what you have` escape hatch that ships open questions as blockers.
- **`sdd-diagnose`** — evidence-first diagnosis workflow for bugs, regressions, incidents, alerts, and performance issues. Produces `diagnosis.md` with five required sections (symptom statement, evidence inventory, expected-behavior baseline, narrowed scope, diagnosis statement with `confirmed | most likely | unresolved` confidence). Blocks progression to spec/design/code until diagnosis is complete. Called standalone or escalated from `sdd-bug` when root cause is unknown and repro is non-deterministic.
- **GitHub Copilot native plugin install** — `install-skills.sh --copilot` now offers `copilot plugin marketplace add jorgeferrando/sdd-skills` + `copilot plugin install sdd-skills@sdd-skills` as the primary path. New `.github/plugin/marketplace.json` (byte-identical to `.claude-plugin/marketplace.json`) exposes the shared Copilot/Claude plugin schema. Legacy file-copy install remains available as fallback.
- **Marketplace-drift check** in `validate-skills.sh` — CI now fails if `.claude-plugin/marketplace.json` and `.github/plugin/marketplace.json` diverge. Workflow `validate.yml` triggers on `.github/plugin/**` too.
- Docs pages `docs/skills/sdd-bug.md` and `docs/skills/sdd-diagnose.md`. MkDocs nav gains a "Bug Flow" section.

### Changed

- `install-skills.sh`: `ALL_SKILLS` now enumerates all 20 skills (previously 16 — `sdd-agent`, `sdd-recall`, `sdd-bug`, `sdd-diagnose` were missing from the interactive picker even when installed).
- `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json`: description and count updated (16 → 20 skills).
- `CLAUDE.md`, `sdd-context.md`, `README.md`: skill catalog, model-hint table, and workflow graph updated to reflect the bug flow branch.

[1.1.0]: https://github.com/jorgeferrando/sdd-skills/releases/tag/v1.1.0

## [1.0.0] - 2026-04-15

First stable release. 16 skills covering the full SDD lifecycle.

### Added

- **16 skills**: init, discover, new, explore, propose, spec, design, tasks, apply, verify, archive, ff, continue, steer, audit, docs
- **Multi-tool installer** (`install-skills.sh`): Claude Code, Cursor, Codex, GitHub Copilot
- **SkillKit support**: compatible with `npx skillkit install` for 45+ AI agents
- **Claude plugin distribution** (`.claude-plugin/`)
- **MkDocs documentation site** with skill reference, concepts, and getting-started guide
- **Agent-based execution** for design, apply, and verify phases
- **Environment scanner** (`sdd-env-scan.sh`) for automated stack detection
- **CI validation** (`validate-skills.sh` + GitHub Actions workflow)
- **Project roadmap** with calendarized tiers through July 2026
- LLM-agnostic instructions — works with any AI coding assistant
- Interactive context file installation with merge/append/skip options

[1.0.0]: https://github.com/jorgeferrando/sdd-skills/releases/tag/v1.0.0
