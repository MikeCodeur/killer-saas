# <project> — settings and conventions

**This file is yours. `install.sh` never overwrites it, and `/ks-setup` is its only creator.**
`AGENTS.md` belongs to the method and is rebuilt on every update — write nothing there.

Every value below is read by the pipeline commands. One setting per line, `Name: value`, nothing
else on the line: a command reads the value as everything after the colon, trimmed. Change any of
them at any time.

## Pipeline settings

```
Merge mode:        pr
Target branch:     main
Plan validation:   human
Ship confirmation: human
Design source:     internal
Design skill:      —
Design tool:       —
Test budget:       25
E2E scope:         nominal
Issue tracker:     github
Worktree root:     .worktrees/
```

| Setting | Accepted values |
| --- | --- |
| Merge mode | `local` (squash-merged locally, no review platform) · `pr` (a pull request against the target branch) |
| Plan validation | `human` (a checkpoint blocks until you validate) · `autonomous` (the agent validates its own plan) |
| Ship confirmation | `human` (asked before any merge) · `automatic` |
| Design source | `internal` (the agent draws, using `Design skill`) · `external` (a brief goes to `Design tool`) |
| Test budget | tests per story — a plan wanting more says why |
| E2E scope | how far the end-to-end suite goes; `nominal` is one happy path |

## Project commands

```
Package manager:   —
Test:              —
Typecheck:         —
E2E:               —
Build:             —
```

A command left at `—` is one the agents cannot run: they say so rather than guess one.

## Project conventions

<< structure, stack, patterns, naming, commit rules — filled by /ks-architect >>
