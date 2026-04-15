# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
