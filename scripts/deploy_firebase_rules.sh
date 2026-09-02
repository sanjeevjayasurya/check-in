#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

npx --yes firebase-tools@latest deploy --only firestore:rules,firestore:indexes,storage "$@"
