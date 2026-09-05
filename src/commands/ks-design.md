---
description: Derive a story's screen from the design system. Autonomous path (the agent produces it) or brief path (an external tool produces it and the result comes back). Never freestyles outside the system.
argument-hint: <story id or name> [--agent | --brief [tool name]]
allowed-tools:
  - Read
  - Glob
  - Grep
  - Write
  - AskUserQuestion
  - Bash
---
# ks-design — Story design, anchored to the design system

Target story: $ARGUMENTS

Resolve the story id, then locate its dedicated `.worktrees/<id>` worktree.
Before any read or write, verify that it is on exactly `feature/<id>` and use
that absolute path for the whole command. Missing worktree, wrong branch,
detached HEAD or the repository base directory itself → STOP and run
`/ks-research <id>` to bootstrap the feature workspace. Never switch branches.

## Execution contract (non-negotiable)
You are FORBIDDEN from:
- Producing a design without an existing design system (Step 1).
- Inventing a component, token, color or spacing outside the design system.
- Designing a screen the story doesn't ask for.
- Handing over a mockup you have not rendered and looked at (Step 5).
- Drawing a mockup for a screen the product already ships (Step 4), or measuring anything at all.

## Workflow

Apply the `design-doctrine` skill: it carries the full rules this command applies.

### Step 1 — Prerequisites (fail-closed)
`docs/design-system.md` must exist and be non-empty.
- Missing or empty → STOP: "No design system found in docs/design-system.md. Set it up first via /ks-design-system, then rerun /ks-design." Produce NO design.
- Present → load it. Its tokens and components are the only visual source, whichever path is taken. Read the real values from the code as well (the stylesheet that defines the tokens): the document describes intent, the stylesheet holds the numbers, and the numbers win.

### Step 2 — Read the project's design source (fail-closed)
The path is **fixed once per project**, not decided per story. Read `Design source` from
`AGENTS.local.md`:

- `internal` → the agent produces the mockup itself, directly or through the skill named by `Design skill`.
- `external` → the agent writes the brief and the tool named by `Design tool` produces the screens.

**No `AGENTS.local.md`, or the setting absent, or still `—`: stop.** Return the question to the
caller — "Which design source does this project use? Run /ks-setup, or set `Design source` in
AGENTS.local.md." Do not pick a default: a project silently set to one path produces designs its
owner never chose.

Neither the external tool nor the internal skill is prescribed by the method. Any tool that holds
the design system qualifies — a hosted design tool, an MCP, or a front-end skill such as
`frontend-design`, `impeccable` or another. **All of them are optional: with `Design skill: —`
the agent draws the screen itself, and that is a complete internal path, not a degraded one.**
Only the deliverable and the verification are fixed.

### Step 3 — Read the inputs
Read `docs/stories.md` and isolate the target story's acceptance criteria.

Then read `docs/research/<id>.md`. **Research is the substance of this step, not a footnote.** It already established the real fields, the existing components, the anchor points and the traps. The screen's fields, actions and states are derived from it — not invented here. If research is missing, say so: the design will rest on assumptions rather than on the code.

If the PRD names a target SaaS, its equivalent screen is a layout and UX reference — structure and states only, never visual identity. The design covers this story's screen only.

### Step 4 — New screen, or derived screen?

Answer this first: it decides what the phase produces.

**Derived** — the story composes, extends or restates something the product already ships (a
column on a list, a state on an existing table, one more field on a form). Produce
`docs/designs/<id>/design.md` **only**: the reference screen named, and the deltas — what
appears, changes, disappears, in which states. **No mockup**: the screen already exists, and
drawing it again draws the product twice. It gets verified for real in a browser at the end of
Execute, which is where the defects that stop a feature working are found.

**New** — the product has nothing like it. Produce `design.md` **and exactly one** visual
deliverable, chosen by `Design source`, never both:

- `internal` → `mockup.html`, the screen built exclusively from the design system's tokens and
  components. Extra frames beside it, same folder.
- `external` → `brief.md` (@templates/design-brief.md): every screen with its layout, exact
  fields and actions, every state, out-of-scope stated, and the design-system constraints
  copied in so it is self-contained and pasteable. **That file is the deliverable — not a chat
  message**: it survives the session and travels to the tool. The result comes back as
  `mockup.html` in the same folder, and dropping it there **is** the validation. Nothing came
  back → the phase is unfinished: stop and say so. Never generate in its place, never hand
  over to `/ks-plan`.

**Fidelity: finished.** The design system exists, so there is no direction left to explore —
only a screen to derive. Real tokens, typography, spacing and copy, and every state the screen
has: empty, loading, error, refused-without-leaking, plus any domain state. Light and dark,
desktop and mobile. Never lorem ipsum, never an invented identity. Low fidelity only when a
screen's structure is genuinely open and two or three directions must be compared — say so
explicitly when you use it.

### Step 5 — Render it and look at it (new screens only)

Reading markup is not looking at a screen, and this step **sends you back**: what it finds gets
fixed before handover. It applies to a mockup returned by an external tool exactly as to a
generated one — nothing guarantees the tool honoured the real tokens. A derived screen has no
mockup: skip this step.

- **Open it in a browser**, served over local HTTP — a `file://` URL may be refused.
- **Both themes**, and **both widths**, with no horizontal overflow.

**Measure nothing** (the rule and its reason are in the `design-doctrine` skill). **Look for
what is BROKEN**: horizontal overflow, unreadable text, a control that disappeared, a missing
state, a layout that collapses.

Then report what was checked **and what could not be** — "no browser available" is an
acceptable outcome, silent skipping is not. Beware a browser forcing dark mode: it repaints
light frames dark whatever the page does.

### Step 6 — Gaps
Any need the design system doesn't cover → record it under "Design system gaps" in `design.md`. **Never invent it.** A gap reported is a decision handed to the right person; a gap filled freestyle is drift that the next story inherits.

Timebox: defined enough to unblock the Plan. Finished is not the same as pixel-perfect — cover the states, don't polish forever.

## Where the design lives (hard rule)
Everything lands in the repository, under `docs/designs/<id>/`, and travels with `feature/<id>`.

**The repository is authoritative.** An external tool — including one an agent can write to — is a working surface, never the source of truth. Anything reworked there must be brought back into the repository **before** implementation, or the code and the design diverge without anyone noticing.

## Mockup status (hard rule)
`mockup.html` is a **reference, not code to copy**. In Execute the screen is built with the boilerplate's real components. The mockup communicates intent — layout, states, hierarchy; it never replaces the component system and never gets pasted into production.

**The phase ends when its deliverable exists, and not before** — `design.md` alone for a
derived screen; `design.md` plus the one visual artifact for a new one. On the internal path
the agent validates that artifact visually, rendered, both themes, both widths; on the
external path, the mockup being dropped in the folder is the validation.

End with: "Design ready (docs/designs/<id>/design.md, + mockup.html or brief.md when the screen is new), rendered and checked. Next step: /ks-plan <id>"
