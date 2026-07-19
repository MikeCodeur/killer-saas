---
description: Open the PR; merge and deploy per the project's ship strategy (manual by default)
argument-hint: <story id or name>
allowed-tools:
  - Read
  - Bash
---
You are shipping a story. Target story: $ARGUMENTS

Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) — the review file docs/reviews/<id>.md must exist for it.

## Step 0 — Gate (fail-closed, mechanical)
Run: `grep -q '^Ship allowed: yes' docs/reviews/<id>.md`
If the file is missing or the command fails, STOP immediately: "Ship blocked — review missing or negative. Run /ks-review <id>." Nothing below runs without a passing gate.

Then proceed:
1. Check out feature/<id>; commit docs/reviews/<id>.md on it if not already committed (the PR must carry its review). Then verify the tests pass. Failing tests → stop.
2. Push the branch and open a clean PR from feature/<id> to the default branch: clear title, structured description (what, why, how to test), readable diff. Include the review verdict (max severity + findings summary) in the PR body.
3. Read the ship strategy from AGENTS.md ("Ship strategy" section). No section, or no explicit `auto` → the mode is manual.

## Step 4 — Merge (per the ship strategy)
- **manual (default): do NOT merge.** End with: "PR opened: <url>. Merging is yours to decide (human review, protected branch, CI). Deployment follows the project's convention after merge."
- **auto**: merge, trigger the deployment, confirm it's live (URL). End with: "Story shipped to production. Cycle complete. Next story: /ks-research <story>"

Never merge in manual mode, even if everything is green — the gate authorizes the ship, the human decides it.
