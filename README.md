# macOS iMessage Skill

This repo stores a skill for iMessage/SMS integration on macOS via the [`imsg`](https://github.com/letta-ai/imsg) CLI tool.

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

- List recent chats and view message history.
- Send iMessages and SMS to phone numbers or existing chats.
- Attach files to outgoing messages.
- Watch chats for new incoming messages.

## Prerequisites

- macOS 14+ with Messages.app configured
- [`imsg`](https://github.com/letta-ai/imsg) CLI built from source (Swift)
- Full Disk Access and Automation permissions granted
- (Optional) SMS Relay enabled on iPhone for green-bubble messages

## How To Use

```bash
# List recent chats
imsg chats --limit 10

# View chat history
imsg history --chat-id <id> --limit 20

# Send a message
imsg send --to "+15555555555" --text "Hello!"

# Watch for new messages
imsg watch --chat-id <id> --debounce 250ms
```

For the full command set and arguments, see `SKILL.md`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "not authorized" error | Grant Automation permission to terminal |
| Can't read messages | Grant Full Disk Access to terminal |
| SMS not sending | Enable Text Message Forwarding on iPhone |
| Message stuck sending | Check Messages.app is signed in and working |
