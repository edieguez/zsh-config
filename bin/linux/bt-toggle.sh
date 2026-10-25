#! /usr/bin/env bash

# Simple script to turn on/off bluetooth
# returns:
#   0 - bluetooth turned off
#   1 - bluetooth turned on
#   2 - unexpected status

set -e

bt_status=$(rfkill list bluetooth | grep -i 'soft' | awk '{print $3}')

if [ "$bt_status" == "yes" ]; then
  rfkill unblock bluetooth
  exit 1
elif [ "$bt_status" == "no" ]; then
  rfkill block bluetooth
  exit 0
else
  exit 2
fi
