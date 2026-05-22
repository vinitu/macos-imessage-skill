-- List Message accounts (services). Output: JSON array.
on run argv
	tell application "Messages"
		set accountList to {}
		repeat with acc in accounts
			set accId to id of acc
			set accDesc to description of acc
			set accType to (service type of acc) as text
			set accEnabled to enabled of acc
			set enabledStr to "false"
			if accEnabled then set enabledStr to "true"
			set entry to "{\"id\":\"" & my jsonEscape(accId) & "\",\"description\":\"" & my jsonEscape(accDesc) & "\",\"service_type\":\"" & my jsonEscape(accType) & "\",\"enabled\":" & enabledStr & "}"
			set end of accountList to entry
		end repeat
	end tell
	return "[" & my join(accountList, ",") & "]"
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

on join(lst, delim)
	set AppleScript's text item delimiters to delim
	set out to lst as text
	set AppleScript's text item delimiters to ""
	return out
end join
