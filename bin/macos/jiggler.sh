#! /usr/bin/env bash
set -e

declare -i wait_minutes=${1:-3}
declare -a messages=(
    'Accomplishing'
    'Actioning'
    'Actualizing'
    'Architecting'
    'Baking'
    'Beaming'
    'Beboppin'
    'Befuddling'
    'Billowing'
    'Blanching'
    'Bloviating'
    'Boogieing'
    'Boondoggling'
    'Booping'
    'Bootstrapping'
    'Brewing'
    'Burrowing'
    'Calculating'
    'Canoodling'
    'Caramelizing'
    'Cascading'
    'Catapulting'
    'Cerebrating'
    'Channeling'
    'Channelling'
    'Choreographing'
    'Churning'
    'Clauding'
    'Coalescing'
    'Cogitating'
    'Combobulating'
    'Composing'
    'Computing'
    'Concocting'
    'Considering'
    'Contemplating'
    'Cooking'
    'Crafting'
    'Creating'
    'Crunching'
    'Crystallizing'
    'Cultivating'
    'Deciphering'
    'Deliberating'
    'Determining'
    'Dilly-dallying'
    'Discombobulating'
    'Doing'
    'Doodling'
    'Drizzling'
    'Ebbing'
    'Effecting'
    'Elucidating'
    'Embellishing'
    'Enchanting'
    'Envisioning'
    'Evaporating'
    'Fermenting'
    'Fiddle-faddling'
    'Finagling'
    'Flambeing'
    'Flibbertigibbeting'
    'Flowing'
    'Flummoxing'
    'Fluttering'
    'Forging'
    'Forming'
    'Frolicking'
    'Frosting'
    'Gallivanting'
    'Galloping'
    'Garnishing'
    'Generating'
    'Germinating'
    'Gitifying'
    'Grooving'
    'Gusting'
    'Harmonizing'
    'Hashing'
    'Hatching'
    'Herding'
    'Honking'
    'Hullaballooing'
    'Hyperspacing'
    'Ideating'
    'Imagining'
    'Improvising'
    'Incubating'
    'Inferring'
    'Infusing'
    'Ionizing'
    'Jitterbugging'
    'Julienning'
    'Kneading'
    'Leavening'
    'Levitating'
    'Lollygagging'
    'Manifesting'
    'Marinating'
    'Meandering'
    'Metamorphosing'
    'Misting'
    'Moonwalking'
    'Moseying'
    'Mulling'
    'Mustering'
    'Musing'
    'Nebulizing'
    'Nesting'
    'Newspapering'
    'Noodling'
    'Nucleating'
    'Orbiting'
    'Orchestrating'
    'Osmosing'
    'Perambulating'
    'Percolating'
    'Perusing'
    'Philosophising'
    'Photosynthesizing'
    'Pollinating'
    'Pondering'
    'Pontificating'
    'Pouncing'
    'Precipitating'
    'Prestidigitating'
    'Processing'
    'Proofing'
    'Propagating'
    'Puttering'
    'Puzzling'
    'Quantumizing'
    'Razzle-dazzling'
    'Razzmatazzing'
    'Recombobulating'
    'Reticulating'
    'Roosting'
    'Ruminating'
    'Sauteing'
    'Scampering'
    'Schlepping'
    'Scurrying'
    'Seasoning'
    'Shenaniganing'
    'Shimmying'
    'Simmering'
    'Skedaddling'
    'Sketching'
    'Slithering'
    'Smooshing'
    'Sock-hopping'
    'Spelunking'
    'Spinning'
    'Sprouting'
    'Stewing'
    'Sublimating'
    'Swirling'
    'Swooping'
    'Symbioting'
    'Synthesizing'
    'Tempering'
    'Thinking'
    'Thundering'
    'Tinkering'
    'Tomfoolering'
    'Topsy-turvying'
    'Transfiguring'
    'Transmuting'
    'Twisting'
    'Undulating'
    'Unfurling'
    'Unravelling'
    'Vibing'
    'Waddling'
    'Wandering'
    'Warping'
    'Whatchamacalliting'
    'Whirlpooling'
    'Whirring'
    'Whisking'
    'Wibbling'
    'Working'
    'Wrangling'
    'Zesting'
    'Zigzagging'
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
    repeat with char in characters of "$1..."
        keystroke char
        delay 0.13
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
