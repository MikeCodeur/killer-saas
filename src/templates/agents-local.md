# <project> — settings and conventions

**This file is yours. `install.sh` never overwrites it.**
`AGENTS.md` belongs to the method and is rebuilt on every update — write nothing there.
Every value below is read by the pipeline commands; change any of them at any time.

## Pipeline settings
```
Merge mode:        pr             # local | pr
Target branch:     main
Plan validation:   human          # human | autonomous
Ship confirmation: human          # human | automatic
Design source:     internal       # internal | external
Design skill:      —              # when internal
Design tool:       —              # when external
Test budget:       25             # tests per story
E2E scope:         nominal        # one nominal journey
Issue tracker:     github
Worktree root:     .worktrees/
```

## Project commands
```
Package manager:   —
Test:              —
Typecheck:         —
E2E:               —
Build:             —
```

A command left at `—` is one the agents cannot run: they will say so rather than guess one.

## Project conventions

<< structure, stack, patterns, naming, commit rules — filled by /ks-architect >>
