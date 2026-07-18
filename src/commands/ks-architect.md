---
description: Set the technical HOW — stack, patterns, conventions, design
---
You are setting the product's technical architecture.

Read: docs/prd.md, docs/stories.md
Output structure: @templates/architecture.md

Apply the codebase-analysis-skill to analyze the starting code (boilerplate): structure, conventions, existing patterns. This is code the user didn't write — map it before deciding anything.

Proceed as follows:
1. Analyze the existing repo and document its actual structure and conventions.
2. Fill the architecture template from this analysis + the PRD needs.
3. Check/complete the AGENTS.md file at the root with the concrete technical conventions ("Technical conventions" section).
4. Write the architecture to `docs/architecture.md`.

End with: "Architecture ready + AGENTS.md updated. Next step: /ks-research <story>"
