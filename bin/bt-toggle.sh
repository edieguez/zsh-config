#! /usr/bin/env bash

# Simple script to turn on/off bluetooth
# returns:
#   0 - bluetooth turned off
#   1 - bluetooth turned on
#   2 - unexpected status

set -e

rfkill_toggle() {
    # Linux systems
    bt_status=$(rfkill list bluetooth | grep -i 'soft' | awk '{print $3}')

    if [ "$bt_status" == "yes" ]; then
        # Turn on bluetooth
        rfkill unblock bluetooth
    elif [ "$bt_status" == "no" ]; then
        # Turn off bluetooth
        rfkill block bluetooth
        exit 0
    fi

    exit 1
}

blueutil_toggle() {
    # MacOS systems
    bt_status=$(blueutil --power)

    if [ "$bt_status" = 0 ]; then
        # Turn on bluetooth
        blueutil --power 1
        exit 0
    elif [ "$bt_status" = 1 ]; then
        # Turn off bluetooth
        blueutil --power 0
        exit 0
    fi

    exit 1
}

if type -p rfkill > /dev/null; then
    rfkill_toggle
elif type -p blueutil > /dev/null; then
    blueutil_toggle
else
    echo "rfkill or blueutil not found"
    exit 1
fi
