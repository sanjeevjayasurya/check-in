#!/usr/bin/env bash
# Configure SunSafe Check-In with your Firebase project via FlutterFire CLI.
#
# Prerequisites:
#   1. firebase login          (or firebase login --no-localhost on headless VMs)
#   2. Create a Firebase project at https://console.firebase.google.com
#
# Usage:
#   ./scripts/configure_firebase.sh
#   ./scripts/configure_firebase.sh --project my-firebase-project-id

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export NPM_CONFIG_USERCONFIG="$ROOT/.npmrc"
export NPM_CONFIG_REGISTRY=https://registry.npmjs.org
export NPM_CONFIG_ALWAYS_AUTH=false
export PATH="$PATH:$HOME/.pub-cache/bin"

if ! command -v flutterfire >/dev/null 2>&1; then
  echo "Activating FlutterFire CLI..."
  dart pub global activate flutterfire_cli
fi

FIREBASE_CMD=(npx --registry=https://registry.npmjs.org --yes firebase-tools@latest)

if ! "${FIREBASE_CMD[@]}" projects:list >/dev/null 2>&1; then
  echo ""
  echo "Not logged in to Firebase."
  echo "Run one of:"
  echo "  ${FIREBASE_CMD[*]} login"
  echo "  ${FIREBASE_CMD[*]} login --no-localhost    # headless / cloud VM"
  echo ""
  exit 1
fi

echo "Configuring Flutter app (Android + iOS)..."
flutterfire configure \
  --platforms=android,ios \
  --android-package-name=com.sunsafe.sunsafe_checkin \
  --ios-bundle-id=com.sunsafe.sunsafeCheckin \
  --out=lib/firebase_options.dart \
  --yes \
  "$@"

echo ""
echo "Done. Generated:"
echo "  - lib/firebase_options.dart"
echo "  - android/app/google-services.json"
echo "  - ios/Runner/GoogleService-Info.plist"
echo ""
echo "Next: enable Auth, Firestore, Storage, and FCM in Firebase Console, then deploy rules:"
echo "  ${FIREBASE_CMD[*]} deploy --only firestore:rules,firestore:indexes,storage"
