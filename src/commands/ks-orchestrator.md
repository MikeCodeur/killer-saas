---
description: Run a story's full cycle — Research → Design → Plan → Execute → Review → Ship — with human checkpoints
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - AskUserQuestion
  - Agent
  - Bash
---
# ks-orchestrator — One story, full cycle, checkpoints kept

Target story: $ARGUMENTS

You conduct the cycle; you never do a phase's work inline when a subagent owns it, and you never write code yourself. The two human checkpoints are non-negotiable: plan validation and ship confirmation. This is a conductor, not an autopilot.

Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. No unambiguous match → list the available stories and stop.

## Phase 1 — Research
If docs/research/<id>.md doesn't exist, produce it now following the ks-research contract: codebase-analysis skill on the story's scope, current state of the code, output structured by @templates/research.md. Otherwise reuse the existing file.

## Phase 2 — Design (UI stories only)
If the story has a screen and docs/designs/<id>.md doesn't exist, follow the ks-design contract: fail-closed on docs/design-system.md (missing → stop and point to /ks-design-system), ask who produces the design (agent / Claude Design / Gemini) via AskUserQuestion, output docs/designs/<id>.md + .html anchored to the design system only. A story without UI skips this phase.

## Phase 3 — Plan
If docs/plans/<id>.md doesn't exist, produce it following the ks-plan contract: small verifiable tasks, structured by @templates/plan.md.

CHECKPOINT — show the plan summary (tasks, files touched, test strategy) and STOP. Ask the user to validate. Do not continue without an explicit yes.

## Phase 4 — Execute
Delegate to the `implementer` subagent exactly as /ks-execute does: branch feature/<id>, strict TDD, only what the plan specifies; fix mode first if a blocking review exists. Capture its summary.

## Phase 5 — Review
Delegate to the `reviewer` subagent exactly as /ks-review does: fresh context, story diff `git diff <default-branch>...feature/<id>`, test suite run by the reviewer, verdict ending with the exact `Max severity:` and `Ship allowed:` lines. Write the report to docs/reviews/<id>.md.

Gate: verdict `Ship allowed: no` → go back to Phase 4 in fix mode. Maximum 2 fix loops; still blocked after that → stop and report the open findings. Never soften a verdict to move on.

## Phase 6 — Ship
CHECKPOINT — review passed: show the verdict and ask the user to confirm the ship. On an explicit yes, proceed as /ks-ship: mechanical gate (`grep -q '^Ship allowed: yes' docs/reviews/<id>.md`), tests on the branch, push, PR, merge, deploy, confirm live.

End with: "Story <id> shipped. Cycle complete." — or the exact blocking state if stopped (which phase, what's missing).
