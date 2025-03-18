#! /usr/bin/env bash
set -e

run_jiggler() {
osascript <<EOD
-- Step 1: Open Spotlight
tell application "System Events"
    key down command
    keystroke space
    key up command
end tell

delay 1 -- Small pause to ensure Spotlight opens

-- Step 2: Type Lorem Ipsum
tell application "System Events"
    repeat with char in characters of "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt"
        keystroke char
        delay 0.1
    end repeat
end tell

delay 1 -- Pause before closing

-- Step 3: Close Spotlight
tell application "System Events"
    -- Escape key twice
    key code 53
    delay 0.1
    key code 53
end tell
EOD
}

while true; do
    run_jiggler
    echo 'Waiting 3 minutes before next jiggler'
    sleep 180
done
