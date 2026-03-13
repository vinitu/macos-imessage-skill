# macOS iMessage Skill

This repo stores a skill for iMessage integration on macOS via **Messages.app AppleScript** (no external CLI for send/list). History is read from the Messages SQLite DB (requires Full Disk Access and jq).

## Installation

Install with `skills.sh`:

```bash
skills.sh add vinitu/macos-imessage-skill
```

If you use the npm installer instead:

```bash
npx skills add vinitu/macos-imessage-skill
```

## Scope

- List Message accounts (services) and get the default iMessage account.
- List chats (id, name).
- Send an iMessage to a buddy (phone/email) or to a chat by id; optional file attachment (`--file`).
- **Read message history** for a chat (from the Messages SQLite DB; requires Full Disk Access and jq).

## Prerequisites

- macOS with Messages.app configured and signed in to iMessage
- **Automation** permission for Terminal (for sending)
- **Full Disk Access** for Terminal (for reading history via `scripts/history.sh`)
- **jq** for history script output (`brew install jq`)

## Command Surface

Run AppleScript entrypoints with `osascript`:

```bash
# List accounts (services); output JSON
osascript scripts/account/list.applescript

# Default iMessage account id; output JSON
osascript scripts/account/default.applescript

# List chats; output JSON, optional --limit=N
osascript scripts/chat/list.applescript --limit=10

# Send a message (requires Automation permission)
osascript scripts/send.applescript "+15551234567" "Hello!"
osascript scripts/send.applescript --chat-id "<chat_id>" "Hello!"
osascript scripts/send.applescript "+15551234567" "Caption" --file /path/to/file.jpg

# Read message history (requires Full Disk Access + jq)
bash scripts/history.sh --chat-id "any;-;+48574096810" --limit 20
bash scripts/history.sh --handle "+48574096810" --limit 50
```

For full usage and best practices, see `SKILL.md`.

## Repo Layout

- `AGENTS.md` — repo rules for agents.
- `SKILL.md` — full skill and command reference.
- `Makefile` — `make dictionary-messages`, `make compile`, `make check`, `make test`.
- `scripts/account/` — account (service) AppleScripts.
- `scripts/chat/` — chat list AppleScript.
- `scripts/send.applescript` — send message to a buddy handle.
- `scripts/history.sh` — read message history from chat.db (Full Disk Access + jq).
- `tests/` — dictionary contract, smoke test, history contract (error behaviour; history content is not tested in CI).

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" error | Grant Automation permission to Terminal (or your app) for Messages |
| "No iMessage account found" | Sign in to iMessage in Messages.app |
| "Participant not found" | Start a conversation with that number/email in Messages.app first, then retry |
| "Cannot read chat.db" / authorization denied | Grant Full Disk Access to Terminal for the history script |
