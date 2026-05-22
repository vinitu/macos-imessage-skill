.PHONY: dictionary dictionary-messages dictionary-standard compile check test test-dictionary test-smoke test-history-contract

dictionary:
	@printf '### Messages.app\n'
	@sdef /System/Applications/Messages.app
	@printf '\n### CocoaStandard.sdef\n'
	@cat /System/Library/ScriptingDefinitions/CocoaStandard.sdef

dictionary-messages:
	@sdef /System/Applications/Messages.app

dictionary-standard:
	@cat /System/Library/ScriptingDefinitions/CocoaStandard.sdef

compile:
	@set -euo pipefail; \
	find scripts/applescripts -name '*.applescript' -print | while IFS= read -r file; do \
		osacompile -o /tmp/$$(echo "$$file" | tr '/' '_' | sed 's/\.applescript$$/.scpt/') "$$file" || exit 1; \
	done; \
	find scripts/tests scripts/commands -name '*.sh' -print | while IFS= read -r file; do \
		bash -n "$$file" || exit 1; \
	done

check:
	@osascript -e 'tell application "Messages" to get id of (first account whose service type is iMessage)' >/dev/null || { echo "check: Messages.app or iMessage account not available"; exit 1; }
	@echo "Messages.app iMessage account is available"

test: test-dictionary test-smoke test-history-contract

test-dictionary:
	@bash scripts/tests/dictionary_contract.sh

test-smoke:
	@bash scripts/tests/smoke_imessage.sh

test-history-contract:
	@bash scripts/tests/history_contract.sh
