---
description: Derive a story's screen from the design system. Agent path (generates) or external path (Claude Design / Gemini). Never freestyles outside the system.
argument-hint: <story id or name> [--agent | --claude-design | --gemini]
allowed-tools:
  - Read
  - Glob
  - Write
  - AskUserQuestion
---
# ks-design — Story design, anchored to the design system

Target story: $ARGUMENTS

## Execution contract (non-negotiable)
You are FORBIDDEN from:
- Producing a design without an existing design system (see Step 1).
- Inventing a component, token, color or spacing outside the design system.
- Designing a screen the story doesn't ask for.

## Workflow

### Step 1 — Prerequisites (fail-closed)
Check that docs/design-system.md exists AND is non-empty.
- Missing or empty → STOP. Reply: "No design system found in docs/design-system.md. Set it up first via /ks-design-system, then rerun /ks-design." Produce NO design.
- Present → load it. Its tokens and components are your only visual source, whichever path is chosen.

### Step 2 — Tool choice
If the user didn't specify the path in $ARGUMENTS, ask (AskUserQuestion): "Who produces this story's design?"
- Agent (I generate it now)
- Claude Design (you produce it there and bring back the result)
- Gemini (same)

### Step 3 — Read the story
Read docs/stories.md, resolve the target story id (`s<number>-<slug>`) and isolate its acceptance criteria. Read docs/research/<id>.md if it exists — its anchor points tell you which pages and layouts the screen plugs into. The design covers this screen only.

### Step 4 — Produce, per the chosen path

**AGENT path** — you generate:
- docs/designs/<id>.md (structure: @templates/design-screen.md)
- docs/designs/<id>.html — a static HTML mockup of the screen, using EXCLUSIVELY the design system's tokens (colors, typography, spacing). Low fidelity. Goal: communicate layout + states, not be production code.

**EXTERNAL path (Claude Design / Gemini)** — the user produces the screen there and brings back the result (exported HTML, screenshot, or description). You:
- record/normalize the mockup into docs/designs/<id>.html
- write docs/designs/<id>.md (structure: @templates/design-screen.md) describing the screen and pointing to the HTML.
If the user brought nothing back → wait. Don't generate in their place, unless they explicitly switch to the Agent path.

### Step 5 — Gaps
Any need the design system doesn't cover → record it under "Design system gaps" in the .md. DON'T invent it.

Timebox: defined enough to unblock the Plan, not pixel-perfect.

## Mockup status (hard rule)
docs/designs/<id>.html is a REFERENCE, not code to copy. In Execute, the screen is built with the boilerplate's real components. The mockup communicates intent (layout, states); it doesn't replace the component system and never gets pasted into production.

End with: "Design ready (docs/designs/<id>.md + .html). Next step: /ks-plan <id>"
