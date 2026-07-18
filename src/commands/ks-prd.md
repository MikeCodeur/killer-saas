---
description: Frame the kill — target SaaS, kill mode, perimeter, the WHAT and the WHY
argument-hint: <target SaaS or product idea>
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---
You are framing a killer-saas project. Subject: $ARGUMENTS

Use this template as the output structure:
@templates/prd.md

killer-saas builds products by replicating an existing SaaS — the target is the spec. Before anything else, lock the kill frame.

Proceed as follows:
1. The kill preamble — ask me, one question at a time:
   - Target: which SaaS are we killing? (name, URL). If $ARGUMENTS names it, confirm it.
   - Kill mode: internal replacement (stop paying, own the data, fit our workflow) or competing product (sell it)? The whole scope depends on this answer.
   - Why: what does the target cost, what does it do badly for us, what do we not need from it?
   - Perimeter: we never clone the whole SaaS. Which core loop delivers the real value for OUR case — the 20% that matters? And what stays explicitly out (the graveyard: enterprise features, edge-case admin, integrations nobody uses)?
   - Complexity: score each replicated feature 1-5 (scale in the template). A 4-5 must earn its place — the default home of heavy features is the graveyard.
   - The angle: what do we do differently or better, beyond parity?
2. Then the classic frame: need, target users, constraints, success criteria. Success = parity on the perimeter + the angle, measurable.
3. Fill each section of the template with my answers. Fill nothing you haven't validated with me.
4. Write the result to `docs/prd.md` and commit it on the default branch (docs: prd).

End with: "PRD ready in docs/prd.md. Next step: /ks-stories"
