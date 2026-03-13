-- Send a text message and/or file to a buddy (handle) or to a chat (by id).
-- Usage:
--   send.applescript <to_handle> <message_text>              -- to buddy
--   send.applescript <to_handle> <message_text> --file <path>
--   send.applescript --chat-id <chat_id> <message_text>
--   send.applescript --chat-id <chat_id> <message_text> --file <path>
--   send.applescript --chat-id <chat_id> --file <path> [message_text]
on run argv
	if (count of argv) < 1 then
		error "Usage: send.applescript <to_handle> <text> | send.applescript --chat-id <id> <text> [--file <path>]"
	end if

	set toHandle to ""
	set chatId to ""
	set messageText to ""
	set filePath to ""

	-- Parse --chat-id and --file
	set i to 1
	repeat while i ≤ (count of argv)
		set argText to (item i of argv) as text
		if argText is "--chat-id" then
			if i ≥ (count of argv) then error "Missing value for --chat-id"
			set chatId to (item (i + 1) of argv) as text
			set i to i + 2
		else if argText is "--file" then
			if i ≥ (count of argv) then error "Missing value for --file"
			set filePath to (item (i + 1) of argv) as text
			set i to i + 2
		else if argText does not start with "--" then
			if toHandle is "" and chatId is "" then
				set toHandle to argText
			else if messageText is "" then
				set messageText to argText
			end if
			set i to i + 1
		else
			set i to i + 1
		end if
	end repeat

	-- Require either buddy or chat, and at least text or file
	if toHandle is "" and chatId is "" then
		error "Provide either <to_handle> or --chat-id <id>"
	end if
	if messageText is "" and filePath is "" then
		error "Provide message text and/or --file <path>"
	end if

	tell application "Messages"
		if chatId is not "" then
			-- Send to chat by id
			set targetChat to first chat whose id is chatId
			if messageText is not "" then
				send messageText to targetChat
			end if
			if filePath is not "" then
				send (POSIX file filePath) to targetChat
			end if
		else
			-- Send to buddy (participant) by handle
			set iMessageAccount to missing value
			repeat with acc in accounts
				if (service type of acc) is iMessage then
					set iMessageAccount to acc
					exit repeat
				end if
			end repeat
			if iMessageAccount is missing value then
				error "No iMessage account found. Sign in to iMessage in Messages.app."
			end if
			try
				set targetBuddy to buddy toHandle of iMessageAccount
			on error errMsg
				error "Participant not found for handle: " & toHandle & ". Start a conversation from Messages.app first. " & errMsg
			end try
			send "" to targetBuddy
			if messageText is not "" then
				send messageText to targetBuddy
			end if
			if filePath is not "" then
				send (POSIX file filePath) to targetBuddy
			end if
		end if
	end tell

	return "sent"
end run
