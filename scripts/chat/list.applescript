-- List chats. Optional --limit=N (default 20). Output: JSON array.
on run argv
	set limitCount to 20
	repeat with arg in argv
		set argText to arg as text
		if argText starts with "--limit=" then
			set limitCount to (text 9 thru -1 of argText) as integer
		else if argText is "--limit" and (count of argv) > 1 then
			set limitCount to (item 2 of argv) as integer
		end if
	end repeat

	tell application "Messages"
		set chatList to {}
		set chatIndex to 0
		repeat with c in chats
			if chatIndex ≥ limitCount then exit repeat
			set chatId to id of c
			set chatName to name of c
			if chatName is missing value or (chatName as text) is "" or (chatName as text) is "missing value" then
				set chatName to ""
				try
					set participantList to participants of c
					if (count of participantList) ≥ 1 then
						set pName to name of (item 1 of participantList)
						if pName is not missing value then
							set pNameText to pName as text
							if pNameText is not "" and pNameText is not "missing value" then
								set chatName to pNameText
							end if
						end if
					end if
				end try
				if chatName is "" then set chatName to my fallbackNameFromId(chatId)
			else
				set chatName to chatName as text
			end if
			set entry to "{\"id\":\"" & my jsonEscape(chatId) & "\",\"name\":\"" & my jsonEscape(chatName) & "\"}"
			set end of chatList to entry
			set chatIndex to chatIndex + 1
		end repeat
	end tell
	return "[" & my join(chatList, ",") & "]"
end run

on fallbackNameFromId(chatId)
	set AppleScript's text item delimiters to ";"
	set parts to text items of (chatId as text)
	set AppleScript's text item delimiters to ""
	if (count of parts) ≥ 1 then
		return (item (count of parts) of parts) as text
	end if
	return ""
end fallbackNameFromId

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
