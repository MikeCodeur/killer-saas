#!/usr/bin/env bash
set -euo pipefail

# killer-saas installer
#
# Usage :
#   ./install.sh              Scope projet (défaut) : ./.claude + ./templates + AGENTS.md/CLAUDE.md
#   ./install.sh --global     Scope global : tooling dans ~/.claude, payload caché dans ~/.claude/killer-saas
#   ./install.sh init         Pose templates + rules dans le projet courant (pour les installs globales)
#
# curl -fsSL https://raw.githubusercontent.com/MikeCodeur/killer-saas/main/install.sh | bash

REPO="https://github.com/MikeCodeur/killer-saas.git"

# --- Résolution du payload (src/) : fichiers locaux, sinon clone (cas curl|bash) ---
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
if [ -n "${SELF_DIR:-}" ] && [ -d "$SELF_DIR/src" ]; then
  SRC="$SELF_DIR/src"
else
  TMP="$(mktemp -d)"
  echo "→ Récupération de killer-saas…"
  git clone --depth 1 "$REPO" "$TMP" >/dev/null 2>&1
  SRC="$TMP/src"
fi

CACHE="$HOME/.claude/killer-saas"

copy_tooling() {
  local dest="$1"
  mkdir -p "$dest/commands" "$dest/skills" "$dest/agents"
  cp -R "$SRC/commands/." "$dest/commands/"
  cp -R "$SRC/skills/."   "$dest/skills/"
  cp -R "$SRC/agents/."   "$dest/agents/"
}

drop_project_payload() {
  local payload="$1"   # dossier contenant templates/ + AGENTS.md
  mkdir -p ./templates
  cp -R "$payload/templates/." ./templates/
  if [ -f ./AGENTS.md ]; then
    echo "⚠  ./AGENTS.md existe déjà — non écrasé. Fusionne les rules killer-saas à la main si besoin."
  else
    cp "$payload/AGENTS.md" ./AGENTS.md
  fi
  # CLAUDE.md doit importer AGENTS.md (pour que Claude Code charge les rules)
  if [ -f ./CLAUDE.md ]; then
    grep -qxF '@AGENTS.md' ./CLAUDE.md || printf '\n@AGENTS.md\n' >> ./CLAUDE.md
  else
    printf '@AGENTS.md\n' > ./CLAUDE.md
  fi
}

case "${1:-}" in
  ""|--project)
    copy_tooling "./.claude"
    drop_project_payload "$SRC"
    echo "✅ killer-saas installé (scope projet). Commandes : /ks-prd … /ks-ship"
    ;;

  -g|--global)
    copy_tooling "$HOME/.claude"
    mkdir -p "$CACHE"
    cp -R "$SRC/templates" "$CACHE/"
    cp "$SRC/AGENTS.md" "$CACHE/"
    cp "${BASH_SOURCE[0]:-$0}" "$CACHE/install.sh" 2>/dev/null || true
    echo "✅ Tooling killer-saas installé (global). Commandes dispo dans tous tes repos."
    echo "→ Dans chaque projet : ~/.claude/killer-saas/install.sh init"
    ;;

  init)
    if [ -d "$SRC/templates" ]; then
      drop_project_payload "$SRC"
    else
      drop_project_payload "$CACHE"
    fi
    echo "✅ templates + rules ajoutés à $(pwd)"
    ;;

  *)
    echo "Option inconnue : $1" >&2
    echo "Usage : ./install.sh [--global | init]" >&2
    exit 1
    ;;
esac
