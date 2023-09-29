#! /usr/bin/env bash
# https://wallhaven.cc/help/api
set -e

banner() {
  if [ -z "$WALLHAVEN_KEY" ]; then
    echo '[01;33m[w] WALLHAVEN_KEY token is not set[0m'
    echo '[01;34m[i] Go to https://wallhaven.cc/settings/account and get your API key[0m'
  fi

  echo '[01;34m[i] API reference: https://wallhaven.cc/help/api[0m'
}

show_summary() {
  echo "[01;34m[i] Downloaded $(ls "$WALLHAVEN_DIR" | wc -l) wallpapers of $total_wallpapers[0m"
}

help() {
  banner
  echo "[01;34m[i] Usage: $(basename $0) query [options][0m"
  echo '[01;34m    Options:[0m'
  echo '[01;34m     -c, --categories  100/101/111*/etc (general/anime/people)[0m'
  echo '[01;34m     -p, --purity      100*/110/111/etc (sfw/sketchy/nsfw)[0m'
  echo '[01;34m     -s, --sorting     date_added*, relevance, random, views, favorites, toplist[0m'
  echo '[01;34m     -t, --top-range   1d, 3d, 1w, 1M*, 3M, 6M, 1y[0m'
  echo '[01;34m     -a, --at-least    At least (default: 1920x1080)[0m'
  echo '[01;34m     -r, --resolutions Resolutions (default: 1920x1080)[0m'
  echo '[01;34m         --ratios      Ratios (default: 16x9)[0m'
  echo '[01;34m         --no-filter   Ignore at-least, resolutions and ratios options[0m'
}

parse_args() {
  if [[ $# -eq 0 ]]; then
    help
    exit 1
  fi

  shift

  while [ $# -ge 1 ]; do
    case "$1" in
      -c|--categories)
          categories="$2"
          shift 2
          ;;
      -p|--purity)
          purity="$2"
          shift 2
          ;;
      -s|--sorting)
          sorting="$2"
          shift 2
          ;;
      -t|--top-range)
          top_range="$2"
          shift 2
          ;;
      -a|--at-least)
          at_least="$2"
          shift 2
          ;;
      -r|--resolutions)
          resolutions="$2"
          shift 2
          ;;
      --ratios)
          ratios="$2"
          shift 2
          ;;
      --no-filter)
          no_filter=true
          shift
          ;;
      *)
          echo "[01;31m[e] Unknown option: $1[0m"
          help
          exit 1
          ;;
    esac
  done
}

set_metadata() {
  if [ "$no_filter" = true ]; then
    metadata=$(curl --silent "$API_URL&q=${Q// /%20}&categories=$CATEGORIES&purity=$PURITY&sorting=$SORTING&top_range=$TOP_RANGE&ai_art_filter=0&page=$1")
  else
    metadata=$(curl --silent "$API_URL&q=${Q// /%20}&categories=$CATEGORIES&purity=$PURITY&sorting=$SORTING&top_range=$TOP_RANGE&atleast=$ATLEAST&resolutions=$RESOLUTIONS&ratios=$RATIOS&page=$1")
  fi
}

download_wallpapers() {
  local links=$(echo $metadata | jq -r '.data[].path')
  wget --quiet --show-progress --directory-prefix "$WALLHAVEN_DIR" -i <(echo "$links")
}

start_crawler() {
  set_metadata $current_page

  declare -i current_page=1
  declare -i total_pages=$(echo $metadata | jq -r '.meta.last_page')
  declare -i total_wallpapers=$(echo $metadata | jq -r '.meta.total')

  if [ $total_wallpapers -eq 0 ]; then
    echo "[01;33m[w] No wallpapers found for query: $Q[0m"
    exit 1
  fi

  echo "[01;34m[i] Found $total_wallpapers wallpapers[0m"

  if [ -d "$WALLHAVEN_DIR" ]; then
    rm -r "$WALLHAVEN_DIR"
  fi

  trap show_summary INT

  while [ $current_page -le $total_pages ]; do
    echo "[01;34m[i] Indexing page $current_page of $total_pages[0m"
    download_wallpapers
    current_page=$((current_page + 1))

    if [ $current_page -le $total_pages ]; then
      set_metadata $current_page
    fi
  done

  show_summary
}

API_URL="https://wallhaven.cc/api/v1/search?apikey=$WALLHAVEN_KEY"
: ${WALLHAVEN_DIR:="$HOME/Pictures/wallhaven"}

parse_args "$@"

# Query parameters
Q="$1"
CATEGORIES="${categories:-111}"
PURITY="${purity:-100}"
SORTING="${sorting:-date_added}"
TOP_RANGE="${top_range:-1M}"
ATLEAST="${at_least:-1920x1080}"
RESOLUTIONS="${resolutions:-1920x1080}"
RATIOS="${ratios:-16x9}"
NO_FILTER="${no_filter:-false}"

banner
start_crawler
