---
name: design-doctrine
description: How a story's screen is derived from the design system — what a new screen owes, what a derived one does not, and why nothing is measured outside the design-system phase. Loaded by /ks-design and /ks-design-system.
---
# Design doctrine

These rules decide what the design phase produces and what it checks. They live in a skill
because only the design commands act on them; implementation and review need one line, not
this page.

Read `Design source` from `AGENTS.local.md` — a project decision, never a per-story one.

- `internal`: the agent produces the mockup, directly or through the skill named by `Design skill`.
- `external`: the agent writes a brief, the tool named by `Design tool` produces the screens, and
  the mockup is dropped back into `docs/designs/<id>/`. Dropping it **is** the validation.

The global design system lives in `docs/design-system.md` (components + tokens, anchored to the boilerplate). Each story's design lives in its own folder, `docs/designs/<id>/` — `design.md`, `mockup.html`, `brief.md` when an external tool produced it, and any extra frames beside them.
- A story's design can be produced by the agent itself, by an internal design skill, or by an external tool that holds the design system and whose result is brought back. Either way it builds on the design system, and the pipeline prescribes neither the tool nor the skill.
- **The repository is authoritative.** An external design tool — including one an agent can write to — is a working surface, never the source of truth. Anything reworked there is brought back into `docs/designs/<id>/` before implementation, or the code and the design diverge unnoticed.
- **A new screen gets one visual artifact; a derived screen gets none.** The product has nothing
  like it → `design.md` plus **exactly one** deliverable chosen by `Design source`: `mockup.html`
  on the internal path, `brief.md` and the mockup it brings back on the external one — never both.
  The story composes, extends or restates a screen that already ships → `design.md` listing the
  deltas, and no mockup: drawing an existing screen draws the product twice, and the real screen
  gets opened in a browser at the end of Execute, which is where the defects that stop a feature
  working are actually found.
- A mockup is never handed over unrendered: it is opened in a browser and checked in both themes
  and at both widths. "Could not verify" is an acceptable report; skipping in silence is not.
- **Nothing is measured outside `/ks-design-system`.** No contrast ratios, no font sizes, no
  rendered widths, no positions, no `Δx` — not at design, not at implementation, not at review, and
  never as a test assertion. The tokens carry those decisions and the design-system phase measured
  them once, on a system that does not move between stories; remeasuring re-litigates it instead of
  using it. Everywhere downstream, look for what is BROKEN — horizontal overflow, unreadable text,
  a control that disappeared, a missing state, a layout that collapses.
- Inventing a component or token outside the design system is forbidden. Compose with what exists.
- The HTML mockup is a reference, not code: the implementation uses the boilerplate's real components.
- A need the system doesn't cover = a "design system gap" to report, never to fill freestyle.
- Stories without UI skip `/ks-design`.
