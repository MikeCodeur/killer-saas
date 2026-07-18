---
name: codebase-analysis
description: Analyzes existing code you didn't write — structure, conventions, patterns. Use during the Architecture and Research phases of the killer-saas pipeline, and for boilerplate onboarding.
---
# Codebase analysis

Goal: understand inherited code before touching it, and extract the conventions to follow.

Sequence — breadth first, then one deep cut:
1. Map the structure: folders, entry points, layers, build and config files.
2. Follow ONE representative feature end to end (route → handler → data access → UI): that walk exposes the real conventions faster than any doc.
3. Spot the recurring patterns: naming, organization, error handling, data access, tests.
4. Identify the implicit conventions: what the code always does the same way is law, even if written nowhere.
5. Locate the anchor points: where a new feature plugs in.
6. Report in an actionable form — conventions as rules ("server actions live in src/actions, one file per domain"), not observations ("there are some actions"). This is what feeds AGENTS.md and the architecture doc.

Rules:
- Verify, don't assume: name a file, a function or a signature only after opening it.
- Don't propose rewrites. The boilerplate is imposed: conform to it.

<< IP Mike: code archaeology method, real boilerplate conventions. >>
