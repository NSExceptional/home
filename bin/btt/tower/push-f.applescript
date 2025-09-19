tell application "System Events"
	--tell application "Tower" to activate
	--keystroke "U" using {shift down, command down}
	tell process "Tower"
		keystroke "U" using {shift down, command down}
		set pushSheet to sheet 1 of window 1
		set options to UI element 8 of pushSheet
		click options
		click (first checkbox whose title is "Force Push") of pushSheet
		-- click (first button whose title is "Push HEAD") of pushSheet
	end tell
	-- We should have to manually confirm this
	-- key code 36
end tell
