-- Return the first iMessage account id. Output: JSON object.
on run argv
	tell application "Messages"
		set iMessageService to missing value
		repeat with acc in accounts
			if (service type of acc) is iMessage then
				set iMessageService to acc
				exit repeat
			end if
		end repeat
		if iMessageService is missing value then
			error "No iMessage account found. Sign in to iMessage in Messages.app."
		end if
		set serviceId to id of iMessageService
	end tell
	return "{\"account_id\":\"" & my jsonEscape(serviceId) & "\"}"
end run

on jsonEscape(s)
	set s to s as text
	set s to my replaceText("\\", "\\\\", s)
	set s to my replaceText("\"", "\\\"", s)
	set s to my replaceText(linefeed, "\\n", s)
	return s
end jsonEscape

on replaceText(findText, replacementText, sourceText)
	set AppleScript's text item delimiters to findText
	set textParts to text items of sourceText
	set AppleScript's text item delimiters to replacementText
	set replacedText to textParts as text
	set AppleScript's text item delimiters to ""
	return replacedText
end replaceText
