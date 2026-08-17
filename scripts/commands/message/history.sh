#!/usr/bin/env bash
# Read message history for a chat from Messages SQLite DB.
# Requires: Full Disk Access for Terminal (or caller) and jq.
# Usage: history.sh --chat-id "any;-;+15551234567" [--limit N]
#        history.sh --handle "+15551234567" [--limit N]
# Output: JSON array of { "date", "is_from_me", "text" }. date is ISO 8601 local.

set -euo pipefail

# shellcheck source=scripts/commands/_lib/common.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../_lib/common.sh"

MESSAGES_DB="${HOME}/Library/Messages/chat.db"
CHAT_ID=""
HANDLE=""
LIMIT=50

while [[ $# -gt 0 ]]; do
	case "$1" in
		--chat-id)
			CHAT_ID="${2:-}"
			[[ -z "$CHAT_ID" ]] && json_fail "missing value for --chat-id"
			shift 2
			;;
		--handle)
			HANDLE="${2:-}"
			[[ -z "$HANDLE" ]] && json_fail "missing value for --handle"
			shift 2
			;;
		--limit)
			LIMIT="${2:-}"
			[[ -z "$LIMIT" ]] && json_fail "missing value for --limit"
			if ! [[ "$LIMIT" =~ ^[0-9]+$ ]] || [[ "$LIMIT" -lt 1 ]] || [[ "$LIMIT" -gt 500 ]]; then
				json_fail "--limit must be 1..500"
			fi
			shift 2
			;;
		*)
			json_fail "unknown option: $1"
			;;
	esac
done

if [[ -z "$CHAT_ID" && -z "$HANDLE" ]]; then
	json_fail "Provide --chat-id or --handle."
fi

if [[ -z "$HANDLE" ]]; then
	if [[ "$CHAT_ID" == *";-;"* ]]; then
		HANDLE="${CHAT_ID#*;-;}"
	else
		HANDLE="$CHAT_ID"
	fi
fi

if [[ ! -r "$MESSAGES_DB" ]]; then
	json_fail "Cannot read $MESSAGES_DB. Grant Full Disk Access to Terminal (System Settings → Privacy & Security → Full Disk Access)."
fi

if ! command -v jq &>/dev/null; then
	json_fail "jq is required for JSON output. Install with: brew install jq"
fi

# Escape single quote for SQL: ' -> ''
HANDLE_ESC="${HANDLE//\'/\'\'}"

# message.date: nanoseconds since 2001-01-01 on newer macOS; seconds on older. 978307200 = unix epoch of 2001-01-01.
# On Ventura+, text is often only in attributedBody; we select both and decode ab when text is empty.
out=$(sqlite3 -readonly "$MESSAGES_DB" <<SQL
.mode json
SELECT
  datetime(
    CAST(
      CASE WHEN CAST(m.date AS REAL) > 1000000000000000000 THEN (m.date / 1000000000.0) + 978307200 ELSE m.date + 978307200 END
      AS INTEGER
    ),
    'unixepoch', 'localtime'
  ) AS date,
  m.is_from_me AS is_from_me,
  COALESCE(m.text, '') AS text,
  HEX(m.attributedBody) AS ab
FROM message m
JOIN chat_message_join cmj ON cmj.message_id = m.ROWID
JOIN chat_handle_join chj ON chj.chat_id = cmj.chat_id
JOIN handle h ON h.ROWID = chj.handle_id
WHERE h.id = '${HANDLE_ESC}'
ORDER BY m.date ASC
LIMIT ${LIMIT};
SQL
)
# When text is empty, try to extract from attributedBody (Ventura+). Requires python3.
if command -v python3 &>/dev/null; then
	echo "$out" | jq -s '.' | python3 -c "
import json, sys, re, binascii
def extract_text_from_ab(hex_str):
    if not hex_str or hex_str == '': return ''
    try:
        raw = binascii.unhexlify(hex_str)
        s = raw.decode('utf-8', errors='replace')
        # Longest run of printable-ish chars (message text is usually in there)
        candidates = re.findall(r'[\x20-\x7e\u00a0-\u024f\u0400-\u04ff]{4,}', s)
        if not candidates: return ''
        best = max(candidates, key=len)
        if len(best) > 2000: best = best[:2000]
        if ' ' in best or len(best) >= 10: return best.strip()
    except Exception:
        pass
    return ''

data = json.load(sys.stdin)
for row in data:
    if isinstance(row, dict):
        ab = row.pop('ab', None)
        if (row.get('text') or '').strip() == '' and ab:
            row['text'] = extract_text_from_ab(ab) or ''
print(json.dumps(data, ensure_ascii=False))
"
else
	echo "$out" | jq -s 'map(del(.ab))'
fi