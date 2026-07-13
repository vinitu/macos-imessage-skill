# Repo Guide

This repo stores the macOS iMessage skill for iMessage/SMS integration via Messages.app AppleScript.

## Public interface and internal backend

- `scripts/commands/` is the only public command surface. Run commands from the repo root with paths like `scripts/commands/<entity>/<action>.sh`.
- `scripts/applescripts/` is the internal backend. Do not call AppleScript files directly from skill instructions.
- Only commands listed in `SKILL.md` are public. Other scripts may exist for internal use or legacy cleanup.

## Goal

- Keep AppleScript coverage accurate to the Messages.app dictionary.
- Prefer runnable examples over long prose.
- Treat message data as real user data — never send messages without explicit user approval.

## Source Of Truth

- `make dictionary-messages`
- Live checks with `osascript`

## Repo Layout

- `SKILL.md` is the main skill workflow.
- `README.md` is the repo overview for humans.
- `scripts/applescripts/account/`, `scripts/applescripts/chat/`, and `scripts/send.applescript` are the AppleScript entrypoints.
- `scripts/history.sh` reads message history from `~/Library/Messages/chat.db` (requires Full Disk Access and jq).
- `tests/` holds the dictionary contract, smoke test, and history contract test.

## Validation

- Run `make test` (dictionary contract + smoke + history contract). Smoke skips if Messages/iMessage not available. History contract checks error behaviour without Full Disk Access; reading actual history is not tested in CI.
- Run `make compile` after AppleScript edits.
- When changing shell scripts, run `shellcheck scripts/*.sh tests/*.sh` if available (CI runs it on macOS).

## Editing Rules

- Keep docs in simple English.
- Update `SKILL.md` when command coverage changes.
- Do not claim support for a feature unless it is in the dictionary or verified with `osascript`.
- Do not add scripts or docs for the dictionary commands `login` or `logout`; this skill uses only `send` and read-only access (accounts, chats, participants).
- Test commands before documenting them.
