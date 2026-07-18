---
name: agentic-stories
description: Breaks a need or a PRD down into user stories an agent can execute. Use during the Stories phase of the killer-saas pipeline.
---
# Agentic-ready story breakdown

An agentic-ready story is an end-to-end shippable slice an agent can implement without ambiguity.

Principles:
- One story = one shippable piece of value, not a technical layer. Avoid "create the table", prefer "submit a testimonial".
- Verifiable acceptance criteria: each one must be able to become a test. "The form works" is not a criterion; "submitting a valid form shows a confirmation and persists the entry" is.
- Agentic notes: the files involved, the constraints, the known traps — the context a human would infer but an agent must read.
- Explicit dependencies: order the stories so that none assumes work not yet done.
- Size: implementable in one Research → Design → Plan → Execute → Review → Ship cycle. If the plan would exceed roughly ten tasks, the story is too big: split it.
- Complexity score: rate each story 1-5 (same scale as the PRD perimeter). A 4 must call out its risk in the agentic notes; a 5 never stays one story — split it before it reaches /ks-plan.
- Target as spec (killer-saas): when the PRD names a target SaaS, point each story to the target's equivalent flow or screen in the agentic notes — the reference implementation already runs in production. Never turn anything from the PRD's graveyard (explicitly not replicated) into a story.
- Id: every story gets `s<number>-<short-slug>` (e.g. s01-submit-testimonial), reused verbatim in every pipeline file and in the branch name.

Example — bad vs good:
- Bad: "s01 — Set up the database". A technical layer: no user value, nothing testable end to end, unshippable alone.
- Good: "s01-submit-testimonial — As a visitor I want to submit a testimonial so that the owner can review it." Criteria: a valid submission is persisted and confirmed; an invalid one shows field errors and persists nothing. The table gets created because this story needs it — as a task inside the story, not as a story.

<< IP Mike: target granularity, good/bad story examples, exact criteria format. >>
