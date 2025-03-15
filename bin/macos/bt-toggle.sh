#! /usr/bin/env bash

# Simple script to turn on/off bluetooth
# returns:
#   0 - bluetooth turned off
#   1 - bluetooth turned on
#   2 - unexpected status

set -e

bt_status=$(blueutil --power)

if [ "$bt_status" = 0 ]; then
  # Turn on bluetooth
  blueutil --power 1
  exit 1
elif [ "$bt_status" = 1 ]; then
  # Turn off bluetooth
  blueutil --power 0
fi
