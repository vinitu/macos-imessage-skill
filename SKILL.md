---
name: macos-imessage
description: Send and read iMessages from macOS via Messages.app AppleScript. Use for texting contacts, scheduling services, or message workflows. Triggers on texting, messaging, iMessage, or contacting someone via text.
---

# macOS iMessage Integration (AppleScript)

Send iMessages and list accounts/chats using **Messages.app AppleScript** on macOS. No external CLI for send/list; history is read from the Messages SQLite database.

## Main Rule

Use only `scripts/commands`.
Do not call `scripts/applescripts` directly.

## Requirements

- macOS with Messages.app configured and signed in to iMessage
- Automation access for your terminal app
- Full Disk Access for Terminal (for reading message history)
- `jq`

## Public Interface

Run commands from `scripts/commands`:

- `scripts/commands/account/list.sh`
- `scripts/commands/account/default.sh`
- `scripts/commands/chat/list.sh`
- `scripts/commands/message/send.sh`
- `scripts/commands/message/history.sh`

## Output Rules

- `account/list.sh` and `chat/list.sh` return JSON arrays.
- `account/default.sh` returns JSON object.
- `message/send.sh` returns JSON object `{"sent": true}` on success.
- `message/history.sh` returns JSON array.
- `--json`, `--plain`, and `--format=plain|json` are not supported.

## Commands

### List accounts (services)

```bash
scripts/commands/account/list.sh
```

Output: JSON array of `{ "id", "description", "service_type", "enabled" }`.

### Default iMessage account

```bash
scripts/commands/account/default.sh
```

Output: JSON object `{ "account_id": "..." }`.

### List chats

```bash
scripts/commands/chat/list.sh
scripts/commands/chat/list.sh --limit=20
```

Output: JSON array of `{ "id", "name" }`. `--limit` defaults to 20.

### Send a message

**To a buddy (phone or email):**

```bash
scripts/commands/message/send.sh "+15551234567" "Hello!"
scripts/commands/message/send.sh "email@example.com" "Hi there!"
scripts/commands/message/send.sh "+15551234567" "See attachment" --file /path/to/file.jpg
```

**To a chat by id** (use `scripts/commands/chat/list.sh` to get chat ids):

```bash
scripts/commands/message/send.sh --chat-id "<chat_guid>" "Hello!"
scripts/commands/message/send.sh --chat-id "<chat_guid>" "Caption" --file /path/to/image.jpg
```

**Never send messages without explicit user approval.**

### Read message history

History is read from the Messages SQLite database (`~/Library/Messages/chat.db`). Requires **Full Disk Access** and **jq**.

```bash
scripts/commands/message/history.sh --chat-id "any;-;+15551234567" --limit 20
scripts/commands/message/history.sh --handle "+15551234567" --limit 50
```

Output: JSON array of `{ "date", "is_from_me", "text" }`. `date` is ISO 8601 local; `is_from_me` is 1 (you sent) or 0 (received). `--limit` defaults to 50.

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

## Safety Boundaries

- Never send messages without explicit user approval.
- Protect user privacy: do not log or store message content or contact handles.
- Treat message history as private user data.
- Any future test that exercises the send path must use a `CodexTest_` prefix in the message text and clean up after itself.
