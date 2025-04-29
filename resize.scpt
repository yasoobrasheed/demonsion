on run {widthRatio, heightRatio}
    tell application "System Events"
        -- Get all processes
        set processList to every process where background only is false
        
        -- Loop through each process
        repeat with currentProcess in processList
            try
                set processName to name of currentProcess
                set processWindows to windows of currentProcess
                if (count of processWindows) > 0 then
                    repeat with i from 1 to count of processWindows
                        set currentWindow to window i of currentProcess
                        
                        try
                            set windowPosition to position of currentWindow
                            set newX to (item 1 of windowPosition) * widthRatio
                            set newY to (item 2 of windowPosition) * heightRatio

                            set windowSize to size of currentWindow
                            set newWidth to (item 1 of windowSize) * widthRatio
                            set newHeight to (item 2 of windowSize) * heightRatio

                            set position of currentWindow to {newX as integer, newY as integer}
                            set size of currentWindow to {newWidth as integer, newHeight as integer}
                        on error errMsg
                            log "Error getting or resizing window: " & errMsg
                        end try
                    end repeat
                end if
            on error errMsg
                log "Error accessing process " & processName & ": " & errMsg
            end try
        end repeat
    end tell
end run