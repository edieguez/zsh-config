#! /usr/bin/env bash
# https://wallhaven.cc/help/api

if [ -z "$WALLHAVEN_KEY" ]; then
	echo '[01;33m[w] WALLHAVEN_KEY token is not set[0m'
	echo '[01;34m[i] Go to https://wallhaven.cc/settings/account and get your API key[0m'
fi

echo '[01;34m[i] API reference: https://wallhaven.cc/help/api[0m'

API_URL="https://wallhaven.cc/api/v1/search?apikey=$WALLHAVEN_KEY"
: ${WALLHAVEN_DIR:="$HOME/Pictures/wallhaven"}

# Query parameters
Q="${1:-linux}"
CATEGORIES="${2:-111}"
PURITY="${3:-100}"
SORTING="random"
ATLEAST="1920x1080"
RESOLUTIONS="1920x1080" # Caution: can lead to zero results
RATIOS="16x9"
SEED=$RANDOM

links=$(curl --silent "$API_URL&q=${Q// /%20}&categories=$CATEGORIES&purity=$PURITY&sorting=$SORTING&atleast=$ATLEAST&ratios=$RATIOS&seed=$SEED" | jq -r '.data[].path')

if [ -z "$links" ]; then
	echo "[01;33m[w] No wallpapers found for query: $Q[0m"
	exit 1
fi

if [ -d "$WALLHAVEN_DIR" ]; then
	rm -r "$WALLHAVEN_DIR"
fi

echo "[01;34m[i] Found $(echo "$links" | wc -l) wallpapers[0m"

wget --quiet --show-progress --directory-prefix "$WALLHAVEN_DIR" -i <(echo "$links")
