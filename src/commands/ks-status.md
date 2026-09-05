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

1. Settings: does AGENTS.local.md exist? Missing → the next step is /ks-setup, and nothing else can run. Present → show `Merge mode`, `Plan validation`, `Design source`, `Story track` and `Flow threshold` on one line.
   Framing: do docs/prd.md, docs/stories.md, docs/architecture.md, docs/design-system.md exist? A missing one is the next step. Also grep '^Stories ready:' docs/reviews/stories.md → yes / no / none, and show it on the framing line (a `no` or a missing review means the breakdown hasn't passed /ks-stories-review).
2. Stories: list the ids from docs/stories.md. For each id derive:
   - complexity: the story's score (from docs/stories.md) — show it next to the id.
   - research: docs/research/<id>.md exists?
   - design: docs/designs/<id>/design.md exists? (UI stories only — otherwise n/a)
   - plan: docs/plans/<id>.md — missing / draft (no `validated: yes` in the frontmatter) / validated, plus ticked vs total task checkboxes (x/y). A plan whose frontmatter says `track: flow` carries its research inside it: show the story as `flow`, and read its research column as n/a rather than missing.
   - verification: docs/verif/<id>.md exists? — shown only for a story past execution.
   - review: grep '^Ship allowed:' docs/reviews/<id>.md → yes / no / none.
   - ship state: branch merged into the target branch → shipped; else an open PR exists → "PR open — merge pending"; else —.
   - blocked: a story whose Dependencies (docs/stories.md) aren't all shipped is blocked — its next command is "blocked by <ids>", never a pipeline step.
3. Start with a one-line summary: X shipped / Y in flight / Z not started. Then print a compact table: story (complexity) | research | design | plan | review | ship | next. The next command follows the pipeline: research → design (UI) → plan → validate the plan (rerun /ks-plan) → execute → review (a `no` verdict → /ks-execute fix mode) → ship — or "merge pending" while the PR awaits a human merge. One exception at the start: for a story not yet begun, whose complexity is at or below `Flow threshold` and whose `Story track` is not `full`, the next command is `/ks-flow <id>` rather than `/ks-research <id>`. Keep shipped stories to one line each.
4. Decisions: if docs/decisions/ exists, mention the ADR count and the latest one.

If AGENTS.local.md doesn't exist, the project hasn't been set up: point to /ks-setup. If it exists but docs/ doesn't, point to /ks-prd.

End with the single most useful next command for this project, e.g.: "Next: /ks-plan s02-...".
