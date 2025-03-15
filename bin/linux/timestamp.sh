#! /usr/bin/env bash

if [[ -z "$1" ]]; then
    if [[ -p /dev/stdin ]]; then # Input from a pipe
        read -r timestamp
    else
        # Current timestamp
        timestamp=$(date +%s)
    fi
else
    timestamp=$1
fi

echo "Timestamp: $timestamp"
echo "$(date --date @$timestamp)"
echo "$(date --utc --date @$timestamp)"
