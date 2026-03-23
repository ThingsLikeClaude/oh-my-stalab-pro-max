# oh-my-stalab-pro-max: Autonomous Full-Cycle Development Pipeline

## Prerequisites

This project requires two global installations:

1. **oh-my-stalab Harness** — Global base at `~/.claude/` (agents, commands, hooks, skills, rules)
2. **bkit plugin** — Install via `claude plugin add bkit` from [bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code)

## /oms-pro-max

Entry point for the full-cycle pipeline. Run:

```
/oms-pro-max "feature description"
```

### Phase Flow

| Phase | Mode | Description |
|-------|------|-------------|
| 0 | Interactive | Deep Interview — requirement discovery |
| 1 | Interactive | PRD Core — key features and user stories |
| 2 | Interactive | PRD Detail — scenarios, flows, edge cases |
| 3 | Interactive | Plan — 3 alternatives, user picks one |
| 4 | Autonomous | Design — architecture document |
| 5 | Autonomous | Test — TDD RED (failing tests first) |
| 6 | Autonomous | Implement — code to pass all tests |
| 7 | Autonomous | Verify — 5 parallel checks (Ralph loop) |
| 8 | Autonomous | Improve — auto-fix failures (Ralph loop) |

Phase 0-3: User deeply involved (review, feedback, selection).
Phase 4-8: Fully autonomous. Ralph loop repeats Phase 7↔8 up to 10 times.

## Tier System

| Tier | Model | Role |
|------|-------|------|
| THOROUGH | opus | Planning, design, architecture, verification judgment |
| STANDARD | sonnet | Implementation, testing, fixing |
| LOW | haiku | Exploration, quick search |

## Agent Dependencies (Global)

These agents must exist in `~/.claude/agents/` (from oh-my-stalab Harness):

- `code-architect` — Phase 3, 4, 6
- `tdd-guide` — Phase 5
- `code-reviewer` — Phase 7
- `build-error-resolver` — Phase 8
- `code-simplifier` — Phase 8

## bkit Integration

These bkit agents are used in the Ralph loop:

- `bkit:gap-detector` — Phase 7 design-implementation gap analysis
- `bkit:pdca-iterator` — Phase 8 auto-improvement when match rate < 90%
- `bkit:report-generator` — Final completion report

## .pipeline/ Directory

Auto-created by `/oms-pro-max`. Contains all artifacts:

```
.pipeline/
├── state.json          # Current phase, iteration count, results
├── interviews/         # Phase 0 output
├── prd/                # Phase 1-2 output
├── plans/              # Phase 3 output
├── design/             # Phase 4 output
├── reports/            # Phase 7-8 verification reports
├── memory/             # Learning data (persists across runs)
│   └── learnings.json  # Success/failure patterns
└── logs/               # Execution logs
```

## Learning System

Every execution records success/failure patterns to `.pipeline/memory/learnings.json`.
Next execution loads these patterns and injects them into relevant phases:

- Phase 4 (Design): Avoids past `design_gap` patterns
- Phase 5 (Test): Creates defensive tests for past `test_failure` patterns
- Phase 6 (Implement): Avoids past `type_error` patterns
- Phase 8 (Improve): Applies past fix patterns first

## Rules

- All responses in Korean (see rules/response-language.md)
- `.pipeline/` is gitignored except `memory/` (learnings persist)
- Never skip Phase 0-3 interactive review
- Phase 4+ runs autonomously — do not pause for user confirmation
- Ralph loop max 10 iterations — if still failing, generate failure report and stop
