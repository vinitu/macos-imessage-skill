---
name: macos-imessage
description: Send and read iMessages from macOS via Messages.app AppleScript. Use for texting contacts, scheduling services, or message workflows. Triggers on texting, messaging, iMessage, or contacting someone via text.
---

# macOS iMessage Integration (AppleScript)

Send iMessages and list accounts/chats using **Messages.app AppleScript** on macOS. No external CLI for send/list; history is read from the Messages SQLite database.

## Setup

### 1. Sign in to iMessage

Open Messages.app and sign in with your Apple ID (Messages → Settings → iMessage).

### 2. Grant Permissions

- **Automation**: System Settings → Privacy & Security → Automation → allow your terminal to control Messages (required for sending).
- **Full Disk Access**: System Settings → Privacy & Security → Full Disk Access → add Terminal (required for reading message history from the Messages database).

## Commands

### List accounts (services)

```bash
osascript scripts/account/list.applescript
```

Output: JSON array of `{ "id", "description", "service_type", "enabled" }`.

### Default iMessage account

```bash
osascript scripts/account/default.applescript
```

Output: JSON object `{ "account_id": "..." }`.

### List chats

```bash
osascript scripts/chat/list.applescript
osascript scripts/chat/list.applescript --limit=20
```

Output: JSON array of `{ "id", "name" }`. `--limit` defaults to 20.

### Send a message

**To a buddy (phone or email):**

```bash
osascript scripts/send.applescript "+15551234567" "Hello!"
osascript scripts/send.applescript "email@example.com" "Hi there!"
osascript scripts/send.applescript "+15551234567" "See attachment" --file /path/to/file.jpg
```

**To a chat by id** (use `scripts/chat/list.applescript` to get chat ids):

```bash
osascript scripts/send.applescript --chat-id "<chat_guid>" "Hello!"
osascript scripts/send.applescript --chat-id "<chat_guid>" "Caption" --file /path/to/image.jpg
```

- Buddy form: first argument = handle (E.164 phone or email), second = message text. Optional `--file <path>` to attach a file.
- Chat form: `--chat-id <id>` then message text, optional `--file <path>`.
- The recipient must already exist as a buddy (start a conversation in Messages.app first if needed). Some systems require an initial empty message; the script sends "" then your text.

**Never send messages without explicit user approval.**

### Read message history

History is read from the Messages SQLite database (`~/Library/Messages/chat.db`). Requires **Full Disk Access** and **jq** (e.g. `brew install jq`).

```bash
bash scripts/history.sh --chat-id "any;-;+15551234567" --limit 20
bash scripts/history.sh --handle "+15551234567" --limit 50
```

Output: JSON array of `{ "date", "is_from_me", "text" }`. `date` is ISO 8601 local; `is_from_me` is 1 (you sent) or 0 (received). `--limit` defaults to 50.

On macOS Ventura and later, some messages may store text in a different format; the script returns the `text` column when present and tries to decode `attributedBody` when text is empty. CI tests only that the script fails with a clear error when Full Disk Access is not granted; it does not test reading real history.

## Best Practices

### Phone number format

- Use E.164: e.g. `+15551234567` for US.
- Include country code for international.

### Message etiquette for agents

- Be concise and natural.
- Avoid early morning or late night messages.
- If following up, reference the previous context.

## Limitations

- **Watch**: No stream for new messages; use history with a limit. The Messages dictionary does not expose message content or a watch stream.
- **SMS**: Sending is via iMessage account; SMS (green bubble) may require the same buddy and iPhone relay setup in Messages.app.
- **History**: Read from the local SQLite DB; on Ventura+ some newer messages may have empty `text` (stored in another column; script tries to decode when possible).

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" | Grant Automation permission for Messages |
| "No iMessage account found" | Sign in to iMessage in Messages.app |
| "Participant not found" | Start a conversation with that handle in Messages.app first |
| "Cannot read chat.db" / "authorization denied" | Grant Full Disk Access to Terminal for the history script |

## Technical notes

- Uses only the public Messages.app scripting dictionary (sdef).
- Requires Messages.app to be installed and signed in.
- Run `make dictionary-messages` to dump the current dictionary.
- This skill does **not** expose or use the dictionary commands `login` or `logout`; only `send` and the read-only classes (accounts, chats, participants) are used.
