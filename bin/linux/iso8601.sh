#! /usr/bin/env bash

if [[ -z "$1" ]]; then
    if [[ -p /dev/stdin ]]; then # Input from a pipe
        read -r iso8601
    else
        # Current date in ISO-8601 format
        iso8601=$(date +"%Y-%m-%dT%H:%M:%S%Z")
    fi
else
    iso8601=$1
fi

echo "Timestamp: $(date --date $iso8601 +%s)"
echo "$(date +"%Y-%m-%dT%H:%M:%S%Z" --date $iso8601)"
echo "$(date --utc +"%Y-%m-%dT%H:%M:%S%Z" --date $iso8601)"
