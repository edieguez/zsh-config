#! /usr/bin/env bash
set -e

declare -i wait_minutes=${1:-3}
declare -a messages=(
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    "Res ipsa loquitur tabula in naufragio."
    "Ave Maria, gratia plena, Dominus tecum, benedicta tu in mulieribus."
    "Pater noster, qui es in caelis, sanctificetur nomen tuum."
    "Estuans interius, ira vehementi, estuans interius, ira vehementi."
)

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
    repeat with char in characters of "$1"
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
    echo "Jiggler will run every $wait_minutes minutes"

    message=${messages[$RANDOM % ${#messages[@]}]}
    echo "Running jiggler with message: $message"

    run_jiggler "$message"

    echo "Waiting $wait_minutes minutes before next jiggler"

    sleep $((wait_minutes * 60))
done
