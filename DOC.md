# killer-saas — Method documentation

A complete agentic pipeline to kill a SaaS with Claude Code: pick a target, cut the 20% that matters, rebuild it on your boilerplate, ship it to production.
One method = a suite of commands. One principle = no direct coding.

## Philosophy

Three rules, enforced by the tooling — not by discipline:

1. **No direct coding.** No code is written outside the pipeline. `/ks-execute` doesn't have the Write/Edit/Bash tools: the main context *cannot* code, it delegates to the `implementer` subagent. The rule lives in the tooling, not in good intentions.
2. **The context that writes never reviews itself.** An agent is blind to its own hallucinations. The review runs in a fresh-context, read-only subagent (`reviewer`).
3. **Fail-closed.** No plan → no execution. A critical issue in review → no ship. Every gate blocks by default; nothing gets forced through.

## The pipeline

Four framing steps, once per product. Then one cycle per story — one story = one branch (`feature/<id>`) = one PR. Every story has an id (`s<number>-<short-slug>`, e.g. `s01-submit-testimonial`) that names every pipeline file and the branch.

    PRD → User Stories → Architecture → Design System
    then, per story:
    Research → Design → Plan → Execute → Review → Ship

| Step | Command | Role | Output |
| --- | --- | --- | --- |
| PRD | `/ks-prd <target>` | The kill frame: target SaaS, kill mode, perimeter — the WHAT and the WHY | `docs/prd.md` |
| Stories | `/ks-stories` | Breakdown into shippable, agentic-ready slices | `docs/stories.md` |
| Architecture | `/ks-architect` | The HOW: stack, conventions, patterns | `docs/architecture.md` + `AGENTS.md` |
| Design System | `/ks-design-system` | Captures tokens, components, UI patterns — records, never draws | `docs/design-system.md` |
| Research | `/ks-research <story>` | The real state of the code within the story's scope | `docs/research/<story>.md` |
| Design | `/ks-design <story>` | The story's screen, anchored to the design system (agent or Claude Design / Gemini) | `docs/designs/<story>.md` + `.html` |
| Plan | `/ks-plan <story>` | Sequenced, small, verifiable tasks | `docs/plans/<story>.md` |
| Execute | `/ks-execute <story>` | TDD implementation by the `implementer` subagent | code + tests + commits |
| Review | `/ks-review <story>` | Anti-hallucination review by the `reviewer` subagent | `docs/reviews/<story>.md` |
| Ship | `/ks-ship <story>` | PR; merge + deploy per ship strategy (manual by default) | PR opened / feature in production |

### Framing (once per product)

**/ks-prd** — frames the kill by interviewing the user, starting with the killer-saas preamble: which target SaaS, kill mode (internal replacement vs competing product), why kill it, and the perimeter — the 20% core loop that delivers the value, each replicated feature scored for complexity (1-5, heavy features default to the graveyard), the graveyard of explicitly dropped features, and the angle beyond parity. Then the classic frame: need, users, constraints, success criteria (parity on the perimeter + the angle). Nothing is filled without validation. The WHAT and the WHY, never the HOW.

**/ks-stories** — breaks the PRD into agentic-ready user stories (`agentic-stories` skill): each story is an end-to-end shippable slice, with acceptance criteria that can become tests, agentic notes (files involved, traps) — the context a human would infer but an agent must read — and a complexity score (1-5, PRD scale): a 4 flags its risk, a 5 is split before planning.

**/ks-architect** — starts by asking whether the project stands on a boilerplate; if none, it proposes: start from ship-saas.now (the ideal fit for a modern fullstack React / Next.js / Drizzle / Better Auth stack), or scaffold a classic default — Next.js + Tailwind + shadcn/ui — recorded as an ADR and then analyzed like any boilerplate. Then analyzes the starting code (`codebase-analysis` skill): actual structure, conventions and patterns of the boilerplate. Fills the architecture doc and injects the concrete conventions into `AGENTS.md`. The boilerplate is imposed: conform to it, don't rewrite it.

**/ks-design-system** — captures the global design system into `docs/design-system.md`: tokens, available components (inventoried from the boilerplate), imposed UI patterns, do/don't. It records and structures — it never invents visuals: the direction comes from the user (Claude Design / Gemini output) or from the boilerplate's existing system. Fail-closed: no source, no design system. Like `AGENTS.md` and the ADRs, it's a transverse asset: set once, read at every story.

### Cycle (per story)

**/ks-research** — explores the story's real scope before any planning: files involved in their current state, verified APIs and functions (exact name, signature, location), traps and dependencies. Framing docs go stale as soon as story 2 ships; research anchors the plan in today's code, not day one's. It is anti-hallucination applied upstream: the review detects, the research prevents.

**/ks-design** — derives the story's screen from the design system. Fail-closed: no `docs/design-system.md`, no design. Two paths, user's choice: the **agent** generates it (structured `.md` + low-fi HTML mockup using only the system's tokens), or the user produces it in **Claude Design / Gemini** — the agent first writes a self-contained brief (`docs/designs/<id>-brief.md`: screens, exact fields, states, design-system constraints copied in), the user pastes it into the external tool, and the agent captures the result into the same output files. Needs the system doesn't cover become "design system gaps" — recorded, never invented. The mockup is a reference, never pasted into production: Execute builds the screen with the boilerplate's real components. Stories without UI skip this step.

**/ks-plan** — breaks the story into ordered tasks, each one small and verifiable, based on the research. Anticipates touched files and the test strategy. Never produces code. The plan is validated by the user before execution.

**/ks-execute** — delegates the implementation to the `implementer` subagent, which works on the story branch `feature/<id>` (strict TDD: failing test → minimal code → refactor, one commit per task). Fail-closed: no plan in `docs/plans/<id>.md` — or a plan without `validated: yes` — no execution. The main context has neither Write, nor Edit, nor Bash — it can't code even if it "wanted" to. If a previous review blocked the story, it runs in **fix mode**: the review findings are fed to the implementer and fixed first.

**/ks-review** — delegates the review to the `reviewer` subagent: fresh context, read-only, opus model. The reviewer judges the story diff (`git diff <default-branch>...feature/<id>`), runs the test suite itself, and verifies every API/import in the diff actually exists. When the story has a design, it also checks conformity to the design system and to the screen's intent — off-system components or tokens are drift (major by default). Each issue classified critical / major / minor. The report ends with two machine-parsable lines: `Max severity: ...` and `Ship allowed: yes|no`.

**/ks-ship** — starts with the mechanical gate: `grep '^Ship allowed: yes' docs/reviews/<id>.md` — no file or a `no` verdict stops everything. Then verifies tests on the branch, pushes, opens a clean PR with the review verdict in its body — and follows the project's **ship strategy** (AGENTS.md): `manual`, the default, stops there — merging stays a human decision; `auto` merges, deploys and confirms it's live. After a PROVEN merge — `git merge-base --is-ancestor`, never a promise — and only then, it deletes the story branch, local and remote: the content is in the default branch, the audit trail in the merged PR. In manual mode: merge on GitHub, then rerun `/ks-ship <id>` to confirm the deployment and clean up.

### Utilities

**/ks-orchestrator <story>** — the conductor. It chains one story's full cycle (Research → Design → Plan → Execute → Review → Ship) in a single command so you don't drive six commands by hand. What it does NOT do: replace the method. Each phase follows the exact contract of its standalone command, code and review stay delegated to the same subagents, and it stops on two blocking questions (real AskUserQuestion calls, not sentences): **validate the plan** — recorded as `validated: yes` in the plan's frontmatter, an existing file never counts as validated — and **confirm the ship**. The review gate loops back to fix mode at most twice, then stops with the open findings. Use it when the cycle is routine; use the individual commands when you want to inspect or steer a phase. It cannot validate a plan or ship in your place — and it is fail-closed on framing: no PRD, stories or architecture → it stops and points to the missing step instead of improvising.

**/ks-help** — prints the pipeline map: the phases in order, the single rule, the per-story cycle. Written in French — it's the user-facing cheat sheet for the community. User-invoked only (`disable-model-invocation: true`).

**/ks-status** — derives the project's state from the files: framing docs, and per story — complexity, research, design, plan (draft or validated), checkbox progress (x/y), review verdict, PR/merge state, dependency blocks — then prints the next useful command per story and for the project. Nothing is stored: the files are the state.

## Data & storage

Everything the pipeline produces is markdown under `docs/`, versioned by git. No database, no state file, no external tracker.

| Data | Lives in |
| --- | --- |
| PRD, stories, architecture | `docs/prd.md`, `docs/stories.md`, `docs/architecture.md` |
| Research, plan, review (per story) | `docs/research/<id>.md`, `docs/plans/<id>.md`, `docs/reviews/<id>.md` |
| Tasks + progress | checkboxes inside `docs/plans/<id>.md`, ticked commit by commit |
| Decisions | `docs/decisions/NNN-<slug>.md` — MADR-style ADRs: context, options rejected and why, consequences. Immutable, superseded not edited |
| Design | `docs/design-system.md` (global, transverse) ; `docs/designs/<id>.md` + `.html` per story — the mockup is a reference, never production code |
| Pipeline state | derived — file existence + `Ship allowed:` verdict + git. Never stored, so never stale |

Lifecycle: framing docs are committed on the default branch at the end of their phase. Story docs travel with the story — the implementer's first commit on `feature/<id>` brings the research, the design and the plan, each task commit ticks its checkbox, `/ks-ship` commits the review. Every PR therefore carries its own research, design, plan and review: the audit trail is the PR itself. Structural decisions get an ADR in `docs/decisions/`: framing ADRs commit on the default branch, story ADRs travel with their PR.

## Tooling anatomy

Five building blocks:

| Block | Location | Role |
| --- | --- | --- |
| Commands | `.claude/commands/ks-*.md` | The process — each pipeline step is a command |
| Skills | `.claude/skills/` | The know-how — reusable, auto-invocable |
| Agents | `.claude/agents/` | Isolated execution — separate contexts, restricted tools |
| Templates | `templates/` | The deliverables' structure — every doc has an imposed skeleton |
| Rules | `AGENTS.md` (+ `CLAUDE.md` → `@AGENTS.md`) | The law of the repo — pipeline, conventions, DoD, gate |

### The subagents

- **implementer** (sonnet model, `tdd-skill` preloaded) — implements the plan, task by task, in TDD. Touches neither the architecture nor the rules, adds nothing out of scope.
- **reviewer** (opus model, `review-antihallu` skill preloaded, read-only) — fresh eyes on code it didn't write. Judges, doesn't fix. A single critical = ship refused.

The model asymmetry is deliberate: implementation is framed by a validated plan (sonnet is enough); the review is the last safety net (opus).

### The skills

- `agentic-stories` — breakdown into agent-executable stories (Stories phase)
- `codebase-analysis` — code archaeology: structure, conventions, patterns (Architecture and Research phases)
- `tdd-skill` — test-first discipline (preloaded in `implementer`)
- `review-antihallu` — hallucination detection in generated code (preloaded in `reviewer`)

## The gate

The review returns a verdict written to `docs/reviews/<id>.md`, ending with the exact lines `Max severity: ...` and `Ship allowed: yes|no`. The gate is mechanical, not declarative: `/ks-ship` greps that line and refuses to run without a `yes` — the verdict file is the key, not anyone's judgment call.

- **Critical** → `Ship allowed: no` → ship blocked. Fix via `/ks-execute` (fix mode: the findings are fixed first), then a new `/ks-review`. No exceptions.
- Major / minor → ship allowed, issues to address in a next cycle.

Upstream, plan validation works the same way: the checkpoint is a blocking question whose answer is written into the plan file (`validated: yes`), and Execute — standalone or orchestrated — refuses to run without it. A plan file that merely exists is not a validated plan.

## Definition of Done (per feature)

- Single PR, structured description, readable diff
- Passing tests on business logic
- No regression on existing code
- Review passed (no open critical issue)
- Deployed to production

## Install

The installer always targets the directory you run it from — your project's root, not this repo. Get it either via the one-liner (it fetches the repo by itself) or by cloning this repo somewhere and calling its `install.sh` from your project.

| Mode | From your project's root | Effect |
| --- | --- | --- |
| Project (default) | `curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh \| bash` — or `<clone>/install.sh` | `.claude/` + `templates/` + `AGENTS.md`/`CLAUDE.md` in the current project |
| Global | `<clone>/install.sh --global` | Tooling in `~/.claude` (commands everywhere), payload in `~/.claude/killer-saas` |
| Per project, after global | `~/.claude/killer-saas/install.sh init` | Drops templates + rules in the current project |
| Update | `<clone>/install.sh update` — or the one-liner with `-s -- update` | Cleanly replaces the method's tooling (manifest-tracked, no ghosts, your own commands untouched), refreshes unmodified templates (modified ones are warned about, never overwritten — add `--force` to overwrite them too), stamps `.claude/.ks-version`. `AGENTS.md` is never touched |

`CLAUDE.md` is not shipped: the installer creates it (or appends to it) with `@AGENTS.md`, so Claude Code loads the rules.

## Multi-tool support (Claude Code / Codex / Gemini)

One canonical source (`src/`, Claude-shaped, the richest target), one installer, per-tool emission — no forked copies. `./install.sh --target claude|codex|all`, project or global scope, drives a per-tool adapter; the Codex transform runs through a zero-dependency Node build (`bin/ks-build.mjs`). What ports and what degrades:

| Building block | Claude Code | Codex | Gemini CLI (planned) |
| --- | --- | --- | --- |
| Rules (`AGENTS.md`) | native (+`CLAUDE.md` import) | **native** | `GEMINI.md` shim importing it |
| Skills (`SKILL.md`) | native | **native** (same open standard) | inlined (no skills mechanism) |
| Templates | copied | copied | copied |
| Commands (`ks-*`) | `.claude/commands/*.md` | emitted as `.codex/skills/*` | `.gemini/commands/*.toml` |
| File/grep gates (`validated:`, `Ship allowed:`) | ✅ | ✅ | ✅ |
| "No direct coding" via tool permissions | ✅ mechanical | ~ agent sandbox (coarser) | ✗ prose-only |
| Subagent model routing (sonnet/opus) | ✅ | note only | note only |
| `AskUserQuestion` checkpoints | ✅ structured | prose | prose |

**The honest line:** the file-based gates (a story needs a `validated: yes` plan before code, a `Ship allowed: yes` review before merge) port to every tool because they are shell-on-markdown, not tool permissions. The permission/isolation guarantees are Claude-mechanical and degrade elsewhere. Rather than pretend otherwise, killer-saas moves enforcement into the **repo**:

### Repo-level enforcement (`--hooks`)

Opt-in git hooks (installed via `core.hooksPath`, reversible) enforce the gates in git, identically for every tool:

- **pre-commit** — no code on `feature/<id>` without `docs/plans/<id>.md` → `validated: yes` (docs-only commits pass).
- **pre-push** — no default-branch push when a merged story lacks `docs/reviews/<id>.md` → `Ship allowed: yes`.

So "no code without a validated plan" and "no ship without a passed review" hold on Claude, Codex and Gemini alike — enforcement lives in the repo, not the harness. For PR merges on the platform, the same `ks-gate ship-allowed <id>` check belongs in CI / branch protection.

## v0 status

The structure is public, the valuable content is private. The `<< IP Mike >>` zones (boilerplate conventions, story granularity, anti-hallucination heuristics, severity thresholds) are intentionally empty in this version: they receive the proprietary content outside this repo.


