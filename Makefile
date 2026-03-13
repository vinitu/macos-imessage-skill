.PHONY: dictionary-messages compile check test test-dictionary test-smoke

dictionary-messages:
	@sdef /System/Applications/Messages.app

compile:
	@set -euo pipefail; \
	find scripts -name '*.applescript' -print | while IFS= read -r file; do \
		osacompile -o /tmp/$$(echo "$$file" | tr '/' '_' | sed 's/\.applescript$$/.scpt/') "$$file"; \
	done

check:
	@osascript -e 'tell application "Messages" to get id of (first account whose service type is iMessage)' >/dev/null || { echo "check: Messages.app or iMessage account not available"; exit 1; }
	@echo "Messages.app iMessage account is available"

test: test-dictionary test-smoke test-history-contract

test-dictionary:
	@bash tests/dictionary_contract.sh

test-smoke:
	@bash tests/smoke_imessage.sh

test-history-contract:
	@bash tests/history_contract.sh
