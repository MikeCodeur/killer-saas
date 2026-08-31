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
- prompt: Review story <id>. The story diff is `git diff <default-branch>...feature/<id>` — judge that diff, and only that diff, against docs/plans/<id>.md, docs/research/<id>.md when it exists, AGENTS.md and the accepted ADRs in docs/decisions/. When docs/design-system.md and docs/designs/<id>/design.md exist, also check conformity to the design system and to the screen's INTENT — not to the mockup HTML line by line; any component, token or color outside the system is drift to classify (major by default, critical if it breaks the product's visual coherence). Run yourself what can hide a defect — the suite, the type check, the production build, and your mutations, using the project's own commands quoted verbatim from AGENTS.local.md (test <Test>, typecheck <Typecheck>, e2e <E2E>, build <Build>); a command given as `—` does not exist here, report it as not run rather than substituting one. Take the linter and any dead-code scan as reported. Judge the test VOLUME too: <Test budget> per story, more only if the plan justified it. And look for a test that names an invariant without exercising it, checking fixtures and mock doubles rather than assertions alone. The review-antihallu skill is preloaded. Fill the checklist from templates/review-checklist.md, classify each issue (critical / major / minor), and end your report with the exact lines "Max severity: <critical|major|minor|none>" and "Ship allowed: <yes|no>".

Wait for the verdict.

### Step 2 — Report
Write the full report to docs/reviews/<id>.md. It MUST end with the exact lines `Max severity: ...` and `Ship allowed: yes` or `Ship allowed: no` — /ks-ship greps that line, and without it the ship stays blocked. A single critical = no.

### Step 3 — Gate (fail-closed)
- Verdict with a CRITICAL → Ship blocked. End with: "Ship blocked (critical). Fix via /ks-execute <id> (fix mode), then rerun /ks-review <id>."
- Otherwise → End with: "Review passed. Next step: /ks-ship <id>"
