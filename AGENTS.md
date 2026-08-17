# Repo Guide

This repo stores the macOS iMessage skill for iMessage/SMS integration via Messages.app AppleScript.

Installed global skill directory: `~/.agents/skills/macos-imessage`.
`skills check` and `skills update` may refer to this skill by upstream package name `apple-imessage` from `vinitu/macos-imessage-skill`.

## Where to start

- Read this file, then `SKILL.md` for the full command list and usage.
- Run all commands from the **repo root**: `./scripts/commands/<entity>/<action>.sh` or `scripts/commands/...`.
- Do not call `scripts/applescripts` directly; use only `scripts/commands`.

## Public interface and internal backend

- `scripts/commands/` is the only public command surface. Run commands from the repo root with paths like `scripts/commands/<entity>/<action>.sh`.
- `scripts/applescripts/` is the internal backend. Do not call AppleScript files directly from skill instructions.
- Only commands listed in `SKILL.md` are public. Other scripts may exist for internal use or legacy cleanup.

## Goal

- Keep AppleScript coverage accurate to the Messages.app dictionary.
- Keep the public `scripts/commands` interface accurate to the implemented behavior.
- Prefer runnable examples over long prose.
- Treat message data as real user data — never send messages without explicit user approval.

## Source of truth

- `make dictionary-messages` / `make dictionary-standard`
- Live checks with `osascript`
- Raw dictionary commands live only in this file and in the `Makefile`.

## Repo layout

- **SKILL.md** — main skill workflow and full command list; update when command coverage changes.
- **README.md** — repo overview for humans.
- **scripts/commands/** — public shell interface (run from repo root).
- **scripts/applescripts/account|chat|message/** — internal AppleScript entrypoints (invoked via `osascript` by the command scripts).
- **scripts/commands/message/history.sh** — reads message history from `~/Library/Messages/chat.db` (requires Full Disk Access and `jq`).
- **tests/** — dictionary contract, smoke test, and history contract test.

## Backends

- **account**, **chat**: AppleScript only (`osascript` + `scripts/applescripts/<entity>/*.applescript`). Output is always JSON.
- **message/send**: AppleScript only (`scripts/applescripts/message/send.applescript`). Output is JSON `{"sent": true}`.
- **message/history**: SQLite query against `~/Library/Messages/chat.db`. Output is a JSON array. Requires Full Disk Access and `jq`.

## Pitfalls / Env limits

- **Messages.app TCC (Automation)**: sending and listing require Automation permission for the calling terminal (System Settings → Privacy & Security → Automation). Without it, `osascript` fails with "not authorized" or "AppleEvent handler failed".
- **Full Disk Access**: reading `~/Library/Messages/chat.db` requires Full Disk Access for the calling terminal (System Settings → Privacy & Security → Full Disk Access). Without it, `history.sh` exits non-zero with a JSON error.
- **iMessage sign-in**: send and account listing require Messages.app to be signed in to iMessage. SMS (green bubble) may require iPhone relay.
- **`jq`**: required for `history.sh` JSON output (`brew install jq`).
- ** Ventura+ text storage**: message text may live only in `attributedBody`; `history.sh` decodes it with `python3` when available, otherwise the `ab` field is dropped.

## Do not

- Call `scripts/applescripts` from skill instructions; use only `scripts/commands`.
- Claim support for a feature unless it is in the app dictionary or verified with `osascript`.
- Add scripts or docs for the dictionary commands `login` or `logout`; this skill uses only `send` and read-only access (accounts, chats, participants).
- Send, delete, move, or export messages without explicit user approval.
- Leave temporary data: use the `CodexTest_` prefix for any future write-path test artifacts and always clean up.

## Safety rules

- Treat message content, contact handles, and history as private user data. Do not log or store them in diffs, commits, or test output.
- Never send a message without explicit user approval.
- Any future test that exercises the send path must use a `CodexTest_` prefix in the message text and clean up after itself.
- Read operations (account list, chat list, history) are safe by default; writes (send) require explicit approval.

## Editing rules

- Keep docs in simple English.
- Update **SKILL.md** when command coverage changes.
- Keep **SKILL.md** and **README.md** about the public `scripts/commands` interface, not internal backends.
- Test commands before documenting them.

## Validation

- After AppleScript or command changes: `make compile` then `make test`.
- Useful targets: `dictionary-messages`, `dictionary-standard`, `compile`, `test`.
- `make test` runs the dictionary contract, smoke test, and history contract. Smoke skips if Messages/iMessage is not available. History contract checks error behaviour without Full Disk Access; reading actual history is not tested in CI.
- When changing shell scripts, run `shellcheck` on `scripts/` and `tests/` if available (CI runs it on macOS).