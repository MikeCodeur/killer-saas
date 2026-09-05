---
description: Capture and structure the global design system into docs/design-system.md. Doesn't generate visuals — it records them.
argument-hint: (optional) source of the visual direction
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - Bash
  - AskUserQuestion
---
# ks-design-system — Global design system capture

This command does NOT design. The visuals (direction, mockups, tokens) are produced elsewhere — by an external design tool, by an internal design skill, or by the agent during story designs. Here, you capture and structure them into a doc agents can consume.

## Execution contract (non-negotiable)
You are FORBIDDEN from:
- Inventing a visual identity from nothing.
- Producing a generic default design system (random colors, imaginary components).

If no visual direction is provided AND the boilerplate has no existing system → STOP, ask for the source: tokens, mockups or a description, from whichever tool produced them.

Apply the `design-doctrine` skill: it carries the full rules this command applies.

## Workflow

### Step 1 — Gather the sources
1. The boilerplate's existing system: apply the codebase-analysis skill to inventory the components and tokens already there (theme, component library, etc.).
2. The visual direction provided by the user: $ARGUMENTS, or ask for it if missing.

### Step 2 — Structure
Fill the structure: @templates/design-system.md
- Tokens (colors, typography, spacing, radius)
- Inventory of available components (name + usage)
- Imposed UI patterns (forms, states, feedback)
- Do / Don't

### Step 3 — Measure the contrasts, once, here
**This is the only phase that measures anything.** Render the tokens against each other —
every text/surface pair the system can produce, light and dark — and **measure** the ratios
rather than judging them by eye: a pair at 4.2:1 and one at 4.8:1 look identical, and only one
passes. Failing pairs are fixes to the tokens, never per-story exceptions.

Done here on a system that does not move between stories, it holds for every screen that
system can build — which is why no later phase repeats it. Beware a browser forcing dark mode:
it repaints light frames dark whatever the page does.

### Step 4 — Write
Write docs/design-system.md and commit it on the default branch (docs: design system). It is the project's single visual reference, read by /ks-design at every story.

## Before you finish — check the project's design source

`/ks-design` reads `Design source` from `AGENTS.local.md` (`internal` or `external`, plus
`Design skill` / `Design tool`). It is set by `/ks-setup`. If it is still unset here, say so:
every story will stop and ask until it is.

End with: "Design system captured in docs/design-system.md. Story screens will build on it via /ks-design <story>."
