---
name: stories-review
description: Reviews a user-story breakdown against the PRD perimeter — coverage gaps, graveyard leaks, technical-layer stories, untestable criteria, dependency order. Preloaded in the stories-reviewer subagent.
---
# Story breakdown review

A breakdown looks fine until you check it against the perimeter it came from. This review hunts the gap between what the PRD promised and what the stories actually deliver.

Why it runs here: a defect in `docs/stories.md` costs a markdown edit now, and contaminates research, design, plan, code, review and ship for every story derived from it later.

## Checks, in order

1. **Perimeter coverage** — every feature in the PRD's "Replicated (core loop)" table must be delivered by at least one story. Walk the table, not the stories: it is the only way to see what is *missing*. A silently dropped feature is invisible until ship.
2. **Graveyard leak** — nothing from "Explicitly NOT replicated" comes back as a story. That list exists to kill scope creep; a leak defeats the PRD.
3. **Technical layers disguised as stories** — "set up the database", "create the API layer". No end-to-end user value, nothing testable, unshippable alone. The table gets created *inside* the story that needs it.
4. **Untestable acceptance criteria** — each criterion must be able to become a test. "The form works" is not a criterion; "submitting a valid form shows a confirmation and persists the entry" is.
5. **Dependency order** — no cycle, no forward reference (a story assuming work scheduled after it). The order must be executable top to bottom.
6. **Complexity** — a 5 never stays one story: it must already be split. A 4 must state its risk in the agentic notes.
7. **Ids** — `s<number>-<slug>`, unique, short, stable. They name every pipeline file and the story branch, so a malformed or duplicated id breaks the whole cycle.
8. **Overlap** — two stories claiming the same slice, or one story bundling two unrelated values.

## Severity scale

- **critical** — the product would be incomplete or out of scope: an uncovered perimeter feature, a graveyard leak, an impossible dependency order.
- **major** — a real defect in one story: technical layer, untestable criteria, an unsplit 5, duplicated id, two stories overlapping.
- **minor** — wording, id style, a missing agentic note, a 4 whose risk isn't spelled out.

## What this review is NOT

Not an implementation review. How a story will be built belongs to `/ks-research` and `/ks-plan`. Judge the breakdown, not the future code — and never rewrite the stories: report, the human fixes.
