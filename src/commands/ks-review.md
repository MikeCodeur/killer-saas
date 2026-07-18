---
description: Get a story reviewed by a fresh-context subagent. Gate before Ship. Never reviews in the context that wrote the code.
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Grep
  - Agent
  - Write
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
Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) against docs/stories.md, then invoke the Agent tool:
- subagent_type: reviewer
- description: Anti-hallucination review of story <id>
- prompt: Review story <id>. The story diff is `git diff <default-branch>...feature/<id>` — judge that diff, and only that diff, against docs/plans/<id>.md and AGENTS.md. Run the test suite yourself; don't trust reported results. The review-antihallu-skill is preloaded. Fill the checklist from templates/review-checklist.md, classify each issue (critical / major / minor), and end your report with the exact lines "Max severity: <critical|major|minor|none>" and "Ship allowed: <yes|no>".

Wait for the verdict.

### Step 2 — Report
Write the full report to docs/reviews/<id>.md. It MUST end with the exact lines `Max severity: ...` and `Ship allowed: yes` or `Ship allowed: no` — /ks-ship greps that line, and without it the ship stays blocked. A single critical = no.

### Step 3 — Gate (fail-closed)
- Verdict with a CRITICAL → Ship blocked. End with: "Ship blocked (critical). Fix via /ks-execute <id> (fix mode), then rerun /ks-review <id>."
- Otherwise → End with: "Review passed. Next step: /ks-ship <id>"
