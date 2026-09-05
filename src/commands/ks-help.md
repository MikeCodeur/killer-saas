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
Seul un critique bloque : un majeur reste tracé dans le rapport et se corrige au cycle
suivant, un mineur est du style. Ni l'un ni l'autre ne relance une boucle.

## Voie courte — petites stories
/ks-flow <story>         — le même cycle en 3 contextes au lieu de 6 : recherche et plan
fusionnés en une passe, puis le subagent implementer, puis le reviewer en contexte vierge,
puis le ship. Rien n'est relâché — worktree, plan validé, preuve par neutralisation, gate.
Pour une complexité ≤ `Flow threshold`. Migration, écran vraiment nouveau, autorisation,
contrat d'API ou dépendance ajoutée → escalade vers le pipeline complet, même en cours de route.

## Orchestrateur
/ks-orchestrator <story> — enchaîne les 6 temps du cycle en une commande. Avec
`Story track: auto`, il choisit lui-même entre /ks-flow et le pipeline complet selon la
complexité de la story.
Il ne remplace rien : mêmes contrats, mêmes subagents, mêmes gates que les
commandes unitaires. Il s'arrête sur 2 questions bloquantes : valider le plan
(écrit dans le fichier plan), confirmer le ship. Cycle routinier → orchestrateur ;
besoin de piloter ou inspecter une phase → commandes unitaires.

Où en est le projet (avancement par story, prochaine commande) : /ks-status
