# macOS iMessage Skill

This repo stores an AI agent skill for Apple Messages.app iMessage integration on macOS.

The public interface is `scripts/commands`.
`scripts/applescripts` stores internal AppleScript backends and dictionary-aligned coverage.

## Installation

```bash
npx skills add vinitu/macos-imessage-skill
```

Or with [skills.sh](https://skills.sh):

```bash
skills.sh add vinitu/macos-imessage-skill
```

The installed global skill directory is usually `~/.agents/skills/macos-imessage`.
`skills check` and `skills update` may refer to the upstream package name `apple-imessage`.

## Prerequisites

- macOS with Messages.app configured and signed in to iMessage
- **Automation** permission for Terminal (for sending and listing)
- **Full Disk Access** for Terminal (for reading history via `scripts/commands/message/history.sh`)
- **jq** for history script output (`brew install jq`)

## Public Interface

Run skill actions with:

```bash
scripts/commands/<entity>/<action>.sh [args...]
```

Output rules:

- Commands return JSON by default unless noted otherwise.
- `--json`, `--plain`, and `--format=plain|json` are not supported.

## Backend Map

- `scripts/commands/account/*` → AppleScript in `scripts/applescripts/account/*`
- `scripts/commands/chat/*` → AppleScript in `scripts/applescripts/chat/*`
- `scripts/commands/message/send.sh` → AppleScript in `scripts/applescripts/message/send.applescript`
- `scripts/commands/message/history.sh` → SQLite query against `~/Library/Messages/chat.db`

`scripts/applescripts` is internal. Do not call it directly from the skill instructions.

## Command Surface

Account:

- `scripts/commands/account/list.sh`
- `scripts/commands/account/default.sh`

Chat:

- `scripts/commands/chat/list.sh`

Message:

- `scripts/commands/message/send.sh`
- `scripts/commands/message/history.sh`

## Examples

```bash
# List Message accounts (services)
scripts/commands/account/list.sh

# Get the first iMessage account id
scripts/commands/account/default.sh

# List recent chats (--limit defaults to 20)
scripts/commands/chat/list.sh
scripts/commands/chat/list.sh --limit=20

# Send a message to a buddy (phone or email) — requires explicit approval
scripts/commands/message/send.sh "+15551234567" "Hello!"
scripts/commands/message/send.sh "email@example.com" "Hi there!"
scripts/commands/message/send.sh "+15551234567" "See attachment" --file /path/to/file.jpg

# Send a message to a chat by id (use chat/list.sh to get chat ids)
scripts/commands/message/send.sh --chat-id "<chat_guid>" "Hello!"
scripts/commands/message/send.sh --chat-id "<chat_guid>" "Caption" --file /path/to/image.jpg

# Read message history (--limit defaults to 50; requires Full Disk Access + jq)
scripts/commands/message/history.sh --chat-id "any;-;+15551234567" --limit 20
scripts/commands/message/history.sh --handle "+15551234567" --limit 50
```

**Never send messages without explicit user approval.**

## JSON Contract

Account object:

- `id`
- `description`
- `service_type`
- `enabled`

Chat object:

- `id`
- `name`

History object:

- `date`
- `is_from_me`
- `text`

Scalar envelopes:

- `account_id`: `{"account_id": "..."}`
- `sent`: `{"sent": true}`

Error envelope (all commands):

- `{"success": false, "error": "..."}`

## Validation

```bash
make compile
make test
```

`make test` runs the dictionary contract, smoke test, and history contract. Smoke checks against Messages.app and expects iMessage to be available. History contract checks error behaviour without Full Disk Access; reading actual history is not tested in CI.

## Known Limits

- Messages.app must be running and signed in to iMessage.
- TCC permissions (Automation) must be granted to the terminal or parent process.
- SMS (green bubble) may require iPhone relay setup in Messages.app.
- Message history requires Full Disk Access.
- On macOS Ventura+, message text may live only in `attributedBody`; `history.sh` decodes it with `python3` when available.

## Safety

- Treat message content, contact handles, and history as private user data.
- Never send messages without explicit user approval.
- Any future write-path test must use a `CodexTest_` prefix in the message text and clean up after itself.