#!/usr/bin/env bash
# Contract test for history.sh: exit codes and error output without Full Disk Access.
# Does not require chat.db access; CI can run this. History content is not tested.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HISTORY_SCRIPT="$ROOT_DIR/scripts/history.sh"

# Missing --chat-id and --handle: must exit non-zero
set +e
out="$(bash "$HISTORY_SCRIPT" 2>&1)"
rc=$?
set -e
if [[ $rc -eq 0 ]]; then
	echo "history_contract: expected non-zero exit when no --chat-id/--handle" >&2
	exit 1
fi
echo "$out" | grep -q "Provide --chat-id or --handle" || { echo "history_contract: expected 'Provide --chat-id or --handle' in output" >&2; exit 1; }

# Invalid --limit: must exit non-zero and emit JSON error
set +e
out="$(bash "$HISTORY_SCRIPT" --handle "x" --limit 9999 2>&1)"
rc=$?
set -e
if [[ $rc -eq 0 ]]; then
	echo "history_contract: expected non-zero exit for invalid --limit" >&2
	exit 1
fi
echo "$out" | grep -q '"error"' || { echo "history_contract: expected JSON error for invalid --limit" >&2; exit 1; }
echo "$out" | grep -q "limit" || true

# With valid args: either success (FDA + chat exists) or JSON error (no FDA / no chat).
# We only require: script runs, and if it exits 1, stderr contains JSON "error" or chat.db/FDA message.
err="$(mktemp)"
trap 'rm -f "$err"' EXIT
set +e
bash "$HISTORY_SCRIPT" --handle "nonexistent-handle-12345" --limit 2 2>"$err"
rc=$?
set -e
if [[ $rc -ne 0 ]]; then
	grep -q '"error"' "$err" || grep -q -E "chat\.db|Full Disk Access|Cannot read" "$err" || { echo "history_contract: expected JSON error or chat.db/FDA message when history unavailable" >&2; cat "$err" >&2; exit 1; }
fi

printf 'history_contract: ok\n'
