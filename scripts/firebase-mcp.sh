#!/usr/bin/env bash
# Start Firebase MCP using the project .npmrc only (avoids invalid tokens in ~/.npmrc).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export NPM_CONFIG_USERCONFIG="$ROOT/.npmrc"
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org
export NPM_CONFIG_ALWAYS_AUTH=false

exec npx --registry=https://registry.npmjs.org -y firebase-tools@latest mcp "$@"
