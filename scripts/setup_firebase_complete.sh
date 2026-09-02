#!/usr/bin/env bash
# Full Firebase setup after `firebase login` — fetch config, wire Flutter, deploy rules.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export NPM_CONFIG_USERCONFIG="$ROOT/.npmrc"
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org
export NPM_CONFIG_ALWAYS_AUTH=false
export PATH="$PATH:$HOME/.pub-cache/bin"

FIREBASE=(npx --registry=https://registry.npmjs.org --yes firebase-tools@latest)

echo "==> Checking Firebase authentication..."
if ! "${FIREBASE[@]}" projects:list; then
  echo ""
  echo "Not logged in. Run:"
  echo "  ${FIREBASE[*]} login"
  echo "  ${FIREBASE[*]} login --no-localhost   # headless VM"
  exit 1
fi

PROJECT_ID="${1:-}"
if [[ -z "$PROJECT_ID" ]]; then
  PROJECT_ID="$("${FIREBASE[@]}" projects:list --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
projects = data.get('results', data if isinstance(data, list) else [])
if not projects:
    sys.exit(1)
if len(projects) == 1:
    print(projects[0]['projectId'])
else:
    print(projects[0]['projectId'])
")" || true
fi

if [[ -z "$PROJECT_ID" ]]; then
  echo "Multiple Firebase projects found. Re-run with project id:"
  echo "  ./scripts/setup_firebase_complete.sh YOUR_PROJECT_ID"
  "${FIREBASE[@]}" projects:list
  exit 1
fi

echo "==> Using Firebase project: $PROJECT_ID"

if ! command -v flutterfire >/dev/null 2>&1; then
  dart pub global activate flutterfire_cli
fi

echo "==> Generating FlutterFire config..."
flutterfire configure \
  --project="$PROJECT_ID" \
  --platforms=android,ios \
  --android-package-name=com.sunsafe.sunsafe_checkin \
  --ios-bundle-id=com.sunsafe.sunsafeCheckin \
  --out=lib/firebase_options.dart \
  --yes

echo "==> Linking Firebase project for CLI deploys..."
"${FIREBASE[@]}" use "$PROJECT_ID"

echo "==> Deploying Firestore rules, indexes, and Storage rules..."
"${FIREBASE[@]}" deploy --only firestore:rules,firestore:indexes,storage

echo ""
echo "==> Done. Verify in Firebase Console:"
echo "  - Authentication: Email/Password, Anonymous, Apple Sign-In"
echo "  - Firestore, Storage, Cloud Messaging enabled"
echo ""
echo "Generated:"
echo "  lib/firebase_options.dart"
echo "  android/app/google-services.json"
echo "  ios/Runner/GoogleService-Info.plist"
