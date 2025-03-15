#! /usr/bin/env bash

# Simple script to turn on/off bluetooth
# returns:
#   0 - bluetooth turned off
#   1 - bluetooth turned on
#   2 - unexpected status

set -e

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
