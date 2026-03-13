#!/usr/bin/env bash
# Smoke test for iMessage skill: account list, default account, chat list. No sending.
# Skips with exit 0 only when Messages/iMessage is not available or Automation not granted.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! osascript -e 'tell application "Messages" to get id of (first account whose service type is iMessage)' >/dev/null 2>&1; then
	echo "smoke_imessage: Messages.app or iMessage not available (sign in or grant Automation)."
	exit 0
fi

out="$(osascript "$ROOT_DIR/scripts/account/list.applescript" 2>&1)" || true
if echo "$out" | grep -q "AppleEvent handler failed\|not authorized"; then
	echo "smoke_imessage: Automation not granted for Messages."
	exit 0
fi
echo "$out" | grep -q '"id"' || { echo "smoke_imessage: account list failed." >&2; exit 1; }

osascript "$ROOT_DIR/scripts/account/default.applescript" | grep -q '"account_id"' || { echo "smoke_imessage: default account failed." >&2; exit 1; }

osascript "$ROOT_DIR/scripts/chat/list.applescript" --limit=3 | grep -q '\[' || { echo "smoke_imessage: chat list failed." >&2; exit 1; }

echo "smoke_imessage: ok"
