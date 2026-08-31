---
description: Affiche le pipeline killer-saas — l'ordre des phases et la règle unique
disable-model-invocation: true
---
# killer-saas — Pipeline

Règle unique : interdit de coder en direct. Chaque feature passe par le pipeline.

## Une fois par projet
0. /ks-setup             — réglages du projet (AGENTS.local.md) : merge, validation, design, commandes
1. /ks-prd <cible>       — cadre le kill : SaaS cible, périmètre, QUOI + POURQUOI
2. /ks-stories           — découpe en user stories agentic-ready
3. /ks-stories-review    — relit le découpage vs le périmètre du PRD (contexte vierge)
4. /ks-architect         — stack, conventions, rules
5. /ks-design-system     — capture le design system global (tokens, composants)

## Par story (une feature = un cycle = une branche = une PR)
6. /ks-research <story>  — explore le contexte réel (code actuel, API, pièges)
7. /ks-design <story>    — décline l'écran depuis le design system (si UI)
8. /ks-plan <story>      — éclate la story en tâches
9. /ks-execute <story>   — implémente la story (subagent isolé)
10. /ks-review <story>   — review anti-hallucination + gate
11. /ks-ship <story>     — ship selon Merge mode / Ship confirmation (cf. AGENTS.local.md)

Bloqué en review sur un critique → retour /ks-execute (fix mode). Sinon → /ks-ship.

## Orchestrateur
/ks-orchestrator <story> — enchaîne les 6 temps du cycle en une commande.
Il ne remplace rien : mêmes contrats, mêmes subagents, mêmes gates que les
commandes unitaires. Il s'arrête sur 2 questions bloquantes : valider le plan
(écrit dans le fichier plan), confirmer le ship. Cycle routinier → orchestrateur ;
besoin de piloter ou inspecter une phase → commandes unitaires.

Où en est le projet (avancement par story, prochaine commande) : /ks-status
