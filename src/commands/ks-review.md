---
description: Get a story reviewed by a fresh-context subagent. Gate before Ship. Never reviews in the context that wrote the code.
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Grep
  - Agent
  - Write
  - Bash
---
# ks-review — Delegated review + gate

Target story: $ARGUMENTS

## Execution contract (non-negotiable)
You MUST complete this command by delegating to the `reviewer` subagent (fresh context). You are FORBIDDEN from:
- Judging the code yourself: you are probably the context that produced it, hence blind to your own hallucinations.
- Modifying source code. Your only write right is the report docs/reviews/<id>.md, nothing else.
- Unblocking the Ship if a critical issue is reported.

If you can't invoke the Agent tool, stop and report the error. Don't improvise.

## Workflow

### Step 1 — Delegate
Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md. Read AGENTS.local.md for the project commands and `Test budget` — missing file → STOP: "No project settings. Run /ks-setup."
Locate `.worktrees/<id>`, verify its branch is exactly `feature/<id>`, and use
that absolute worktree as the reviewer working directory and report location.
Missing worktree, wrong branch, detached HEAD or repository base → STOP; never
switch branches. Then invoke the Agent tool:
- subagent_type: reviewer
- description: Anti-hallucination review of story <id>
- working directory: the absolute dedicated worktree path verified above.
- prompt: Review story <id>. Your agent definition and the preloaded `review-antihallu` skill are your contract — this prompt carries only what is specific to this run. Judge `git diff <default-branch>...feature/<id>`, and only that diff. Fill the checklist from templates/review-checklist.md, and end with the exact lines "Max severity: <critical|major|minor|none>" and "Ship allowed: <yes|no>". Report every finding in this review; never hold one back for a later pass. The project commands and settings are in AGENTS.local.md — quote them verbatim, and one left at `—` is reported as not run, never substituted.

Wait for the verdict. If the Agent call fails, times out, returns no report, or returns a report without both exact verdict lines, write `docs/reviews/<id>.md` yourself with `Review status: blocked`, the concrete failure cause, missing information/evidence, and the exact adaptation required. End it with `Max severity: critical` and `Ship allowed: no` when review completeness is compromised. Do not replace the failure with a vague "review failed" message.

### Step 2 — Report
Write the full report to docs/reviews/<id>.md. It MUST include a `Review status: complete|blocked` line, and, when blocked, the sections `Failure cause`, `Missing`, and `Required adaptation` with concrete details. It MUST end with the exact lines `Max severity: ...` and `Ship allowed: yes` or `Ship allowed: no` — /ks-ship greps that line, and without it the ship stays blocked. A single critical = no. An incomplete review is never a pass.

### Step 3 — Gate (fail-closed)
- Verdict with a CRITICAL → Ship blocked. End with: "Ship blocked (critical). Fix via /ks-execute <id> (fix mode), then rerun /ks-review <id>."
- Otherwise → End with: "Review passed. Next step: /ks-ship <id>"
