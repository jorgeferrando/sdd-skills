# /sdd-propose

> Analyze input completeness, ask clarifying questions, and create a complete proposal documenting context, problem, solution, scope, risks, and acceptance criteria.

## Usage

```
/sdd-propose "add rate limiting to API"
/sdd-propose TICKET-456
```

Usually run as part of `/sdd-new`. Use standalone when you want to create a proposal without the explore phase.

## Prerequisites

- `openspec/` initialized

## What it does

1. Determines change name (kebab-case)
2. Creates `openspec/changes/{change-name}/` directory
3. Gathers context from explore output and steering files
4. Analyzes which proposal sections can be filled vs. which have gaps
5. Asks clarifying questions until all sections are covered
6. Generates complete `proposal.md`
7. Validates with targeted questions and applies feedback

## Artifact format

```markdown
# Proposal: {Change Title}

## Metadata
## Context
## Problem
## Scope (In scope / Out of scope)
## Proposed Solution
## Alternatives Discarded
## Risks & Mitigations
## Impact
## Dependencies
## Acceptance Criteria
```

## Key behavior

The skill does **not** generate the proposal immediately. It first checks whether the user's input covers all required sections. For any section with insufficient information, it asks specific clarifying questions before writing. This ensures the output is always a complete, substantive proposal — never a template with empty placeholders.

## Next step

- `/sdd-continue` — proceeds to the spec phase
