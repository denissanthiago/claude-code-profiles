#!/usr/bin/env bash
#
# SessionStart hook — inyecta contexto git breve al iniciar una sesión.
# Safe: solo lee estado, nunca modifica.

set -o pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

echo "=== Git context ==="
BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached)")
echo "Branch: $BRANCH"

echo ""
echo "Últimos 3 commits:"
git log --oneline -3 2>/dev/null || echo "(sin commits)"

UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [[ "$UNCOMMITTED" -gt 0 ]]; then
  echo ""
  echo "⚠ Cambios sin commitear: $UNCOMMITTED archivo(s)"
fi

echo "==================="
exit 0
