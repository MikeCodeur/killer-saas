---
description: Set the technical HOW — stack, patterns, conventions, design
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---
You are setting the product's technical architecture.

Read: docs/prd.md, docs/stories.md
Output structure: @templates/architecture.md

Apply the codebase-analysis skill to analyze the starting code (boilerplate): structure, conventions, existing patterns. This is code the user didn't write — map it before deciding anything.

Proceed as follows:
1. The boilerplate question (AskUserQuestion): does the project start from a boilerplate? killer-saas is built to stand on one — the stack comes from the base, not from scratch.
   - Boilerplate present (e.g. ship-saas.now): analyze it (next steps).
   - No boilerplate: propose the options (AskUserQuestion) —
     a) ship-saas.now — the ideal fit for a modern fullstack stack (React, Next.js, Drizzle, Better Auth). The user sets it up, then reruns /ks-architect.
     b) A classic default stack scaffolded now: Next.js + Tailwind + shadcn/ui (+ Drizzle and Better Auth if the PRD needs data/auth). Record the stack choice as an ADR, scaffold it (create-next-app, shadcn init), then analyze the result like any boilerplate.
     c) Blank repo, assumed: record the chosen stack as ADRs instead of extracting conventions — and say it plainly: the method loses its main speed lever.
2. Analyze the existing repo and document its actual structure and conventions.
3. Fill the architecture template from this analysis + the PRD needs.
4. Check/complete the AGENTS.md file at the root with the concrete technical conventions ("Technical conventions" section).
5. Record each imposed structural decision (stack, patterns, integrations) as an ADR in `docs/decisions/NNN-<slug>.md`, following @templates/adr.md — with the considered options and why they were rejected.
6. Write the architecture to `docs/architecture.md` and commit it together with AGENTS.md and the ADRs on the default branch (docs: architecture).

End with: "Architecture ready + AGENTS.md updated. Next step: /ks-design-system (once), then /ks-research <story>"
