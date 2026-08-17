#!/usr/bin/env bash
# Output: JSON array of recent chats.
# Requires: AppleScript backend; Messages.app signed in.
# Example:
#   [
#     {"id":"...","name":"Jane Doe"}
#   ]
set -euo pipefail

# shellcheck source=scripts/commands/_lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../_lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [--limit N]
List recent chats. --limit defaults to 20.
EOF
}

main() {
  local args=("$@")
  local i=0
  while [[ $i -lt ${#args[@]} ]]; do
    case "${args[$i]}" in
      --limit)
        if [[ $((i + 1)) -ge ${#args[@]} ]]; then
          usage
          json_fail "missing value for --limit"
        fi
        i=$((i + 2))
        ;;
      --limit=*)
        i=$((i + 1))
        ;;
      *)
        usage
        json_fail "unknown option: ${args[$i]}"
        ;;
    esac
  done
  run_backend chat list "$@"
}

main "$@"