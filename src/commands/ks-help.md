---
description: Affiche le pipeline killer-saas — l'ordre des phases et la règle unique
disable-model-invocation: true
---
# killer-saas — Pipeline

Règle unique : interdit de coder en direct. Chaque feature passe par le pipeline.

## Une fois par projet
1. /ks-prd <idée>      — cadre le produit (QUOI + POURQUOI)
2. /ks-stories         — découpe en user stories agentic-ready
3. /ks-architect       — stack, conventions, rules (+ design)

## Par story (une feature = un cycle = une branche = une PR)
4. /ks-research <story> — explore le contexte réel (code actuel, API, pièges)
5. /ks-plan <story>     — éclate la story en tâches
6. /ks-execute <story>  — code en TDD (subagent isolé)
7. /ks-review <story>   — review anti-hallucination + gate
8. /ks-ship <story>     — PR, merge, deploy

Bloqué en review sur un critique → retour /ks-execute (fix mode). Sinon → /ks-ship.

Cycle complet d'une story en une commande (checkpoints humains conservés) : /ks-orchestrator <story>
Où en est le projet (avancement par story, prochaine commande) : /ks-status
