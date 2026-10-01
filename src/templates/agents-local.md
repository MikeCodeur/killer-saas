# <project> — settings and conventions

**This file is yours. `install.sh` never overwrites it, and `/ks-setup` is its only creator.**
`AGENTS.md` belongs to the method and is rebuilt on every update — write nothing there.

Every value below is read by the pipeline commands. One setting per line, `Name: value`, nothing
else on the line: a command reads the value as everything after the colon, trimmed. Change any of
them at any time.

**After changing anything here, rerun `install.sh`** — it reassembles `AGENTS.md` from the method's
rules plus this file, and `AGENTS.md` is what an agent loads automatically. Settings are also read
straight from here, so those take effect immediately; the conventions at the bottom only reach an
agent through `AGENTS.md`, and stay stale until you reinstall.

## Pipeline settings

```
Merge mode:        pr
Target branch:     main
Plan validation:   human
Ship confirmation: human
Story track:       auto
Flow threshold:    2
Design source:     internal
Design skill:      —
Design tool:       —
Test budget:       25
Verification mode: record
Full suite:        execute-end
E2E stage:         ship
E2E scope:         story
E2E smoke:         —
E2E browsers:      —
Build stage:       ship-if-route
Issue tracker:     github
Worktree root:     .worktrees/
Sandbox port base: 3000
Sandbox URL vars:  —
Sandbox schema:    —
Sandbox reset:     —
```

| Setting | Accepted values |
| --- | --- |
| Merge mode | `local` (squash-merged locally, no review platform) · `pr` (a pull request against the target branch) |
| Plan validation | `human` (a checkpoint blocks until you validate) · `autonomous` (the agent validates its own plan) |
| Ship confirmation | `human` (asked before any merge) · `automatic` |
| Design source | `internal` (the agent draws, using `Design skill`) · `external` (a brief goes to `Design tool`) |
| Story track | `auto` (the story's complexity picks the lane) · `full` (always the six-phase pipeline) · `flow` (always `/ks-flow`) |
| Flow threshold | complexity at or below which `auto` picks `/ks-flow` |
| Test budget | tests per story — a plan wanting more says why |
| Verification mode | `record` (the implementer records what it ran; the reviewer checks the record instead of re-running) · `rerun` (the reviewer runs everything itself) |
| Full suite | when the whole unit suite runs: `execute-end` · `ship` · `both` |
| E2E stage | when the end-to-end suite runs: `execute-end` · `ship` · `ci` · `—` |
| E2E scope | what the ship's single run covers: `story` (the spec files the story's diff adds or changes, plus `E2E smoke`; an older `nominal` reads as `story`) · `full` (the whole suite — normally CI's job) |
| E2E smoke | the few spec files every ship also runs, comma-separated — sign-in and the core loop, nothing more. `—` means none |
| E2E browsers | browsers for the story cycle, e.g. `chromium`; `—` means the project's own default. Ship always runs them all |
| Sandbox port base | a story's port is this plus its number (`s04` → 3004) — see the `story-sandbox` skill |
| Sandbox URL vars | the environment variables that carry the app's own URL and must all point at the story's port, comma-separated |
| Sandbox schema | paths whose change means a schema change, so the story gets its own database, comma-separated |
| Sandbox reset | the command that resets and seeds the local database |
| Build stage | when the production build runs: `ship-if-route` (only when a route or manifest moved) · `ship` · `review` · `ci` · `—` |

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
