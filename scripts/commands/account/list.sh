#!/usr/bin/env bash
# Output: JSON array of Message accounts (services).
# Requires: AppleScript backend; Messages.app signed in.
# Example:
#   [
#     {"id":"...","description":"iMessage","service_type":"iMessage","enabled":true}
#   ]
set -euo pipefail

# shellcheck source=scripts/commands/_lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../_lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0")
List Message accounts (services).
EOF
}

main() {
  if [[ $# -gt 0 ]]; then
    usage
    json_fail "unexpected arguments"
  fi
  run_backend account list "$@"
}

main "$@"