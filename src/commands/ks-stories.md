---
description: Break the PRD down into shippable, agentic-ready user stories
---
You are breaking the PRD down into user stories.

Read the PRD: docs/prd.md
Output structure: @templates/stories.md

Apply the agentic-stories skill for the breakdown.

Proceed as follows:
1. Break the need into stories: each one an end-to-end shippable slice, testable. Give each story an id: `s<number>-<short-slug>` (e.g. s01-submit-testimonial) — this id names every pipeline file and the story branch, so keep it short and stable.
2. For each story, write verifiable acceptance criteria (each one must be able to become a test) and the agentic notes useful for execution.
3. Order the stories by dependency: no story may assume work not yet done.
4. Write the result to `docs/stories.md` and commit it on the default branch (docs: stories).

End with: "Stories ready in docs/stories.md. Next step: /ks-architect"
