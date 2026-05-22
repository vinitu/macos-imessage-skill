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

## Prerequisites

- macOS with Messages.app configured and signed in to iMessage
- **Automation** permission for Terminal (for sending)
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
- `scripts/commands/message/*` → AppleScript in `scripts/applescripts/message/*` (send) or SQLite query (history)

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
- `sent` (plain text from send command, not JSON)

## Validation

```bash
make compile
make test
```

`make test` runs live checks against Messages.app and expects iMessage to be available.

## Known Limits

- Messages.app must be running and signed in to iMessage.
- TCC permissions (Automation) must be granted to the terminal or parent process.
- SMS (green bubble) may require iPhone relay setup in Messages.app.
- Message history requires Full Disk Access.
