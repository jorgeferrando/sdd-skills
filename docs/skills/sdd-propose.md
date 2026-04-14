# /sdd-propose

> Create a proposal documenting the problem, solution, and alternatives.

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
3. Creates `proposal.md`
4. Presents proposal for feedback

## Artifact format

```markdown
# Proposal: {Change Title}

## Problem
{What's wrong or missing}

## Proposed Solution
{High-level approach}

## Alternatives Discarded
{Other approaches and why they were rejected}

## Impact
{Files affected, domains, tests needed}
```

## Next step

- `/sdd-continue` — proceeds to the spec phase
