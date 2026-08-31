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
0. AGENTS.local.md exists? Missing → STOP: "This project has no settings. Run /ks-setup." Read `Plan validation`, `Design source`, `Merge mode`, `Ship confirmation` and the project commands from it: every checkpoint below is governed by them.
1. docs/prd.md exists? Missing → STOP: "No PRD — the pipeline starts with /ks-prd <target>. Nothing to orchestrate yet."
2. docs/stories.md exists? Missing → STOP: "No stories — run /ks-stories first."
3. docs/architecture.md exists? Missing → STOP: "No architecture — run /ks-architect first."
4. docs/reviews/stories.md says `Stories ready: yes`? If missing or negative, warn (don't stop): the breakdown hasn't passed /ks-stories-review.
(docs/design-system.md is not required here: Phase 2 fail-closes on it only when the story has UI.)

Then resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. No unambiguous match → list the available stories and stop. Never invent a framing doc or a story to keep going.

Invoke the `worktree-manager` subagent with the resolved id and repository base
directory. Continue only after it returns the absolute `.worktrees/<id>` path,
confirms branch `feature/<id>` and a clean status. Every phase below, every
subagent and both checkpoints operate on files in that worktree. Never create
or checkout the feature branch in the repository base directory.

## Phase 1 — Research
If docs/research/<id>.md doesn't exist, produce it now following the ks-research contract: codebase-analysis skill on the story's scope, current state of the code, output structured by @templates/research.md. Otherwise reuse the existing file.

## Phase 2 — Design (UI stories only)
If the story has a screen and docs/designs/<id>/ lacks either design.md or mockup.html, follow the ks-design contract: fail-closed on docs/design-system.md (missing → stop and point to /ks-design-system), then read `Design source:` from AGENTS.md — internal (the agent produces the mockup) or external (the agent writes the brief and the result comes back). Unset and nobody to answer this turn → STOP and return the question; never pick a default. Produce a finished screen anchored to the design system only, then render it and look at it. Output docs/designs/<id>/design.md + mockup.html — both, always: a design.md without its mockup is an interrupted phase, not a finished one. A story without UI skips this phase.

## Phase 3 — Plan
If docs/plans/<id>.md doesn't exist, produce it following the ks-plan contract: small verifiable tasks, structured by @templates/plan.md.

CHECKPOINT — per `Plan validation`. If the plan's frontmatter already says `validated: yes`, continue. Otherwise, `human`: present the plan summary (tasks, files touched, test strategy) and ask via AskUserQuestion: "Validate this plan?" — options: Validate / Modify / Stop; only Validate sets `validated: yes`, anything else stops. `autonomous`: re-read the plan against the story's acceptance criteria, set `validated: yes` yourself, and say plainly that nobody else looked at it. An existing plan file never counts as validated on its own.

## Phase 4 — Execute
Fail-closed: docs/plans/<id>.md must carry `validated: yes` in its frontmatter — missing means back to the Phase 3 checkpoint. Then delegate to the `implementer` subagent exactly as /ks-execute does, with the verified absolute worktree as its working directory: no red-first ceremony and no invariant mutations, focused suite per task and the full suite plus the end-to-end once at the end, the type check after the last edit, no branch switching, only what the plan specifies; fix mode first if a blocking review exists. Capture its summary.

## Phase 5 — Review
Delegate to the `reviewer` subagent exactly as /ks-review does: fresh context, story diff `git diff <default-branch>...feature/<id>`, test suite run by the reviewer, verdict ending with the exact `Max severity:` and `Ship allowed:` lines. Write the report to docs/reviews/<id>.md.

Gate: verdict `Ship allowed: no` → go back to Phase 4 in fix mode. Maximum 2 fix loops; still blocked after that → stop and report the open findings. Never soften a verdict to move on.

## Phase 6 — Ship
CHECKPOINT — per `Ship confirmation`. `human`: show the verdict and ask via AskUserQuestion: "Ship now?" — options: Ship / Not now; only an explicit Ship proceeds. `automatic`: proceed. Then run /ks-ship's flow: mechanical gate (`grep -q '^Ship allowed: yes' docs/reviews/<id>.md`), tests on the branch, then `Merge mode` — `pr`: push and open the PR (stopping there unless confirmation is `automatic`); `local`: squash into the target branch. Clean up only once the merge is proven.

End with: "Story <id> shipped. Cycle complete." when the merge is proven, "PR opened — merging is yours." when it stops at the PR — or the exact blocking state if stopped (which phase, what's missing).
