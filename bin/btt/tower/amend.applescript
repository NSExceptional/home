use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

tell application "System Events"
	tell process "Tower"
		tell front window
			tell splitter group 1 of splitter group 1 -- commit area
				-- set elements to entire contents
				--return elements
				
				-- Old Tower
				--set focused of text field 1 to true
                
				set focused of text area 1 of scroll area 1 to true
				click checkbox "Amend"
				-- We don't want to auto-stage anything
				-- keystroke "E" using {shift down, command down}
				delay 0.1
				click button "Amend"
			end tell
		end tell
	end tell
end tell
