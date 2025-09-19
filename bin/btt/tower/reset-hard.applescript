tell application "System Events"
	tell process "Tower"
		-- Alternate approach which requires somehow copying the revision:
		-- click menu item "Reset HEAD to Revision…" of menu "Working Copy" of menu bar 1
		
        -- Find the history table
		set splitGroup to splitter group 1 of splitter group 1 of window 1
		set history to table 1 of scroll area 1 of splitGroup
		
        -- Right-click the selected revision
		tell history to perform action "AXShowMenu"
		set ctxMenu to menu 1 of history
        
        -- Find and click "Reset HEAD"
		set reset to (first menu item whose title starts with "Reset HEAD") of ctxMenu
        tell reset to perform action "AXPress"
        delay 0.333
        
        -- Uncheck "Keep Changes" in the sheet
        set resetSheet to sheet 1 of window 1
		click (first checkbox whose title is "Keep Changes") of resetSheet
		-- click (first button whose title is "Reset") of resetSheet
	end tell
	-- We should have to manually confirm this
	-- key code 36
end tell
