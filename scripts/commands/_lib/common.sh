#!/usr/bin/env bash

# Shared helpers for macOS iMessage skill public commands.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

json_fail() {
  local message="$1"
  printf '{"success":false,"error":"%s"}\n' "$message"
  exit 1
}

json_ok() {
  local payload="${1:-{}}"
  printf '{"success":true,"data":%s}\n' "$payload"
}

require_arg() {
  local value="${1:-}"
  local label="$2"
  if [[ -z "$value" ]]; then
    json_fail "missing ${label}"
  fi
}

backend_script() {
  local entity="$1"
  local action="$2"
  printf '%s/scripts/applescripts/%s/%s.applescript' "$ROOT_DIR" "$entity" "$action"
}

run_backend() {
  local entity="$1"
  local action="$2"
  shift 2
  local script_path
  script_path="$(backend_script "$entity" "$action")"
  if [[ ! -f "$script_path" ]]; then
    json_fail "backend script not found: ${script_path}"
  fi
  osascript "$script_path" "$@"
}
