---
description: Chain a story's full cycle — Research → Design → Plan → Execute → Review → Ship — with two blocking human checkpoints (plan validation, ship confirmation)
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

You conduct the cycle; you never do a phase's work inline when a subagent owns it, and you never write code yourself. The two human checkpoints are non-negotiable: plan validation and ship confirmation. A checkpoint is an actual AskUserQuestion call — never a rhetorical sentence in your output. This is a conductor, not an autopilot.

## Phase 0 — Prerequisites (fail-closed)
The orchestrator drives one story's cycle — it never replaces the framing. Check, in order:
1. docs/prd.md exists? Missing → STOP: "No PRD — the pipeline starts with /ks-prd <target>. Nothing to orchestrate yet."
2. docs/stories.md exists? Missing → STOP: "No stories — run /ks-stories first."
3. docs/architecture.md exists? Missing → STOP: "No architecture — run /ks-architect first."
(docs/design-system.md is not required here: Phase 2 fail-closes on it only when the story has UI.)

Then resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. No unambiguous match → list the available stories and stop. Never invent a framing doc or a story to keep going.

## Phase 1 — Research
If docs/research/<id>.md doesn't exist, produce it now following the ks-research contract: codebase-analysis skill on the story's scope, current state of the code, output structured by @templates/research.md. Otherwise reuse the existing file.

## Phase 2 — Design (UI stories only)
If the story has a screen and docs/designs/<id>.md doesn't exist, follow the ks-design contract: fail-closed on docs/design-system.md (missing → stop and point to /ks-design-system), ask who produces the design (agent / Claude Design / Gemini) via AskUserQuestion, output docs/designs/<id>.md + .html anchored to the design system only. A story without UI skips this phase.

## Phase 3 — Plan
If docs/plans/<id>.md doesn't exist, produce it following the ks-plan contract: small verifiable tasks, structured by @templates/plan.md.

CHECKPOINT — mandatory, whether the plan is new or already existed. If the plan's frontmatter already says `validated: yes`, continue. Otherwise present the plan summary (tasks, files touched, test strategy) and ask via AskUserQuestion: "Validate this plan?" — options: Validate / Modify / Stop. An existing plan file does NOT count as validated. On Validate, set `validated: yes` in the plan's frontmatter. Anything else: don't touch the marker, don't continue.

## Phase 4 — Execute
Fail-closed: docs/plans/<id>.md must carry `validated: yes` in its frontmatter — missing means back to the Phase 3 checkpoint. Then delegate to the `implementer` subagent exactly as /ks-execute does: branch feature/<id>, strict TDD, only what the plan specifies; fix mode first if a blocking review exists. Capture its summary.

## Phase 5 — Review
Delegate to the `reviewer` subagent exactly as /ks-review does: fresh context, story diff `git diff <default-branch>...feature/<id>`, test suite run by the reviewer, verdict ending with the exact `Max severity:` and `Ship allowed:` lines. Write the report to docs/reviews/<id>.md.

Gate: verdict `Ship allowed: no` → go back to Phase 4 in fix mode. Maximum 2 fix loops; still blocked after that → stop and report the open findings. Never soften a verdict to move on.

## Phase 6 — Ship
CHECKPOINT — review passed: show the verdict and ask via AskUserQuestion: "Ship now?" — options: Ship / Not now. Only an explicit Ship proceeds; then run /ks-ship's flow: mechanical gate (`grep -q '^Ship allowed: yes' docs/reviews/<id>.md`), tests on the branch, push, PR — then the project's ship strategy (manual, the default: stop at the PR; auto: merge, deploy, confirm live).

End with: "Story <id> shipped. Cycle complete." (auto mode), "PR opened — merging is yours." (manual mode) — or the exact blocking state if stopped (which phase, what's missing).
