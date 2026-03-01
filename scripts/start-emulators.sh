#!/usr/bin/env bash
set -euo pipefail

# Start Firebase emulators with environment from .env.local (if present).
# Usage: ./scripts/start-emulators.sh [--only auth,firestore,storage,functions]

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
ENV_FILE="$ROOT_DIR/.env.local"

echo "Working dir: $ROOT_DIR"

if [ -f "$ENV_FILE" ]; then
  echo "Loading environment from $ENV_FILE"
  # Export all KEY=VALUE lines from .env.local
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo ".env.local not found — continuing with current environment"
fi

# Allow overriding emulator list via args, otherwise default set
if [ "$#" -gt 0 ]; then
  EXTRA_ARGS="$@"
else
  EXTRA_ARGS=(--only auth,firestore,storage,functions)
fi

# Check firebase CLI availability
if ! command -v firebase >/dev/null 2>&1; then
  echo "Error: firebase CLI not found. Install it with 'npm install -g firebase-tools' or 'brew install firebase-cli'." >&2
  exit 127
fi

echo "Starting Firebase emulators: ${EXTRA_ARGS[*]}"
cd "$ROOT_DIR"
exec firebase emulators:start ${EXTRA_ARGS[@]}
