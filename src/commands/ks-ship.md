---
description: Open the PR, merge, deploy to production
argument-hint: <story id or name>
allowed-tools: Bash
---
You are shipping a story. Target story: $ARGUMENTS

Resolve $ARGUMENTS to the story id (`s<number>-<slug>`) — the review file docs/reviews/<id>.md must exist for it.

## Step 0 — Gate (fail-closed, mechanical)
Run: `grep -q '^Ship allowed: yes' docs/reviews/<id>.md`
If the file is missing or the command fails, STOP immediately: "Ship blocked — review missing or negative. Run /ks-review <id>." Nothing below runs without a passing gate.

Then proceed:
1. Check out feature/<id>; commit docs/reviews/<id>.md on it if not already committed (the PR must carry its review). Then verify the tests pass. Failing tests → stop.
2. Push the branch and open a clean PR from feature/<id> to the default branch: clear title, structured description (what, why, how to test), readable diff.
3. Merge.
4. Trigger the deployment.
5. Confirm it's live (URL).

End with: "Story shipped to production. Cycle complete. Next story: /ks-research <story>"
