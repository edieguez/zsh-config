#! /usr/bin/env bash
# https://wallhaven.cc/help/api

if [ -z "$WALLHEAVEN_KEY" ]; then
  echo 'WALLHEAVEN_KEY is not set'
  echo 'Go to https://wallhaven.cc/settings/account and get your API key'
  exit 1
fi

API_URL="https://wallhaven.cc/api/v1/search?apikey=$WALLHEAVEN_KEY"
: ${WALLHEAVEN_DIR:="$HOME/Pictures/wallheaven"}

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
  echo "No wallpapers found for query: $Q"
  exit 1
fi

if [ -d "$WALLHEAVEN_DIR" ]; then
  rm -r "$WALLHEAVEN_DIR"
fi

echo "Found $(echo "$links" | wc -l) wallpapers"

wget --quiet --show-progress --directory-prefix "$WALLHEAVEN_DIR" -i <(echo "$links")
