#!/usr/bin/env bash
#
# Instala los MCP servers globales (scope=user) en Claude Code.
# Idempotente: si ya existen, los reemplaza.
#
# Requisitos:
#   - Claude Code CLI (`claude`) instalado y logueado
#   - Node.js >= 20.19 (para npx)
#   - Chrome stable (para chrome-devtools-mcp)
#   - Vault de Obsidian existente en VAULT_PATH
#   - (opcional) EXA_API_KEY exportada en el entorno — si no está, se salta exa

set -euo pipefail

VAULT_PATH="/Users/denis/Documents/Obsidian Vault"

if ! command -v claude >/dev/null 2>&1; then
  echo "Error: 'claude' CLI no está en el PATH. Instala Claude Code primero." >&2
  exit 1
fi

if [[ ! -d "$VAULT_PATH" ]]; then
  echo "Error: vault de Obsidian no existe en: $VAULT_PATH" >&2
  exit 1
fi

echo "→ Removiendo MCPs previos (si existen)..."
claude mcp remove chrome-devtools --scope user 2>/dev/null || true
claude mcp remove obsidian --scope user 2>/dev/null || true
claude mcp remove playwright --scope user 2>/dev/null || true
claude mcp remove context7 --scope user 2>/dev/null || true
claude mcp remove exa --scope user 2>/dev/null || true

echo "→ Instalando chrome-devtools..."
claude mcp add-json chrome-devtools --scope user \
  '{"type":"stdio","command":"npx","args":["-y","chrome-devtools-mcp@latest"]}'

echo "→ Instalando obsidian (vault: $VAULT_PATH)..."
claude mcp add-json obsidian --scope user \
  "{\"type\":\"stdio\",\"command\":\"npx\",\"args\":[\"@bitbonsai/mcpvault@latest\",\"${VAULT_PATH}\"]}"

echo "→ Instalando playwright..."
claude mcp add-json playwright --scope user \
  '{"type":"stdio","command":"npx","args":["@playwright/mcp@latest"]}'

echo "→ Instalando context7..."
# Sin API key: usa rate-limit básico. Free key en https://context7.com/dashboard
claude mcp add-json context7 --scope user \
  '{"type":"stdio","command":"npx","args":["-y","@upstash/context7-mcp"]}'

if [[ -n "${EXA_API_KEY:-}" ]]; then
  echo "→ Instalando exa (API key detectada en entorno)..."
  claude mcp add-json exa --scope user \
    "{\"type\":\"stdio\",\"command\":\"npx\",\"args\":[\"-y\",\"exa-mcp-server\"],\"env\":{\"EXA_API_KEY\":\"${EXA_API_KEY}\"}}"
else
  echo "⚠ EXA_API_KEY no está en el entorno — exa NO se instaló."
  echo "  Para instalarlo: export EXA_API_KEY='tu-key' && ./scripts/install-mcps.sh"
  echo "  Key gratuita en: https://dashboard.exa.ai/api-keys"
fi

echo ""
echo "✓ MCPs instalados. Verifica con:"
echo "    claude mcp list"
