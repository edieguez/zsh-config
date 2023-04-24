#! /usr/bin/env bash
# Simple advice client for https://api.adviceslip.com

RESPONSE="$(curl --silent https://api.adviceslip.com/advice)"
ID="$(echo $RESPONSE | jq --raw-output '.slip.id')"
ADVICE="$(echo $RESPONSE | jq --raw-output '.slip.advice')"

echo "[$ID] $ADVICE"
