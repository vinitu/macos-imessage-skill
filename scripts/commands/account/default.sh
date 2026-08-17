#!/usr/bin/env bash
# Output: JSON object with the first iMessage account id.
# Requires: AppleScript backend; Messages.app signed in to iMessage.
# Example:
#   {"account_id":"..."}
set -euo pipefail

# shellcheck source=scripts/commands/_lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../_lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0")
Return the first iMessage account id as {"account_id": "..."}.
EOF
}

main() {
  if [[ $# -gt 0 ]]; then
    usage
    json_fail "unexpected arguments"
  fi
  run_backend account default "$@"
}

main "$@"