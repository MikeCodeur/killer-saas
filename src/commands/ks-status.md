---
description: Show the project's pipeline state — framing docs, per-story progress, next command
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---
# ks-status — Where the project stands

Derive the state from the files — never guess. Bash is for read-only git queries here.

1. Framing: do docs/prd.md, docs/stories.md, docs/architecture.md exist? A missing one is the next step.
2. Stories: list the ids from docs/stories.md. For each id:
   - research: docs/research/<id>.md exists?
   - plan: docs/plans/<id>.md exists? If yes, count ticked vs total task checkboxes (progress x/y).
   - review: grep '^Ship allowed:' docs/reviews/<id>.md → yes / no / none.
   - shipped: is branch feature/<id> merged into the default branch?
3. Print a compact table: story | research | plan (x/y tasks) | review | shipped | next command for that story.
4. Decisions: if docs/decisions/ exists, mention the ADR count and the latest one.

If docs/ doesn't exist at all, the project hasn't started: point to /ks-prd.

End with the single most useful next command for this project, e.g.: "Next: /ks-plan s02-...".
