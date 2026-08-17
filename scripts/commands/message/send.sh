#!/usr/bin/env bash
# Output: JSON {"sent": true} on success; JSON error on failure.
# Requires: AppleScript backend; Messages.app signed in to iMessage.
# Never send messages without explicit user approval.
# Example:
#   scripts/commands/message/send.sh "+15551234567" "Hello!"
#   scripts/commands/message/send.sh --chat-id "<chat_id>" "Hello!"
#   scripts/commands/message/send.sh "+15551234567" "See attachment" --file /path/to/file.jpg
set -euo pipefail

# shellcheck source=scripts/commands/_lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../_lib/common.sh"

usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") <to_handle> <text> [--file <path>]
       $(basename "$0") --chat-id <chat_id> <text> [--file <path>]
Send an iMessage/SMS to a buddy (phone/email) or to a chat by id.
At least a <to_handle> or --chat-id is required, plus message text and/or --file.
EOF
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
    json_fail "missing arguments"
  fi
  # The AppleScript backend parses --chat-id, --file, and positional args and
  # performs full validation (handle/chat-id presence, text/file presence).
  run_backend message send "$@" >/dev/null
  printf '{"sent":true}\n'
}

main "$@"