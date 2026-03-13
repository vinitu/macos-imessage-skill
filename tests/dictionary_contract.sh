#!/usr/bin/env bash
set -euo pipefail

tmp_messages="$(mktemp)"
trap 'rm -f "$tmp_messages"' EXIT

make --no-print-directory dictionary-messages >"$tmp_messages"

has_pattern() {
	local pattern="$1"
	local file="$2"
	if command -v rg >/dev/null 2>&1; then
		rg -q "$pattern" "$file"
	else
		grep -q -- "$pattern" "$file"
	fi
}

has_pattern '<command name="send"' "$tmp_messages"
has_pattern '<class name="account"' "$tmp_messages"
has_pattern '<class name="chat"' "$tmp_messages"
has_pattern '<class name="participant"' "$tmp_messages"
has_pattern '<enumerator name="iMessage"' "$tmp_messages"
has_pattern '<property name="handle"' "$tmp_messages"

printf 'dictionary_contract: ok\n'
