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
  echo '[01;34m     -c, --categories  Categories (default: 111)[0m'
  echo '[01;34m     -p, --purity      Purity (default: 100)[0m'
  echo '[01;34m     -t, --top-range   Top range (default: 1)[0m'
  echo '[01;34m     -a, --at-least    At least (default: 1920x1080)[0m'
  echo '[01;34m     -r, --resolutions Resolutions (default: 1920x1080)[0m'
  echo '[01;34m         --ratios      Ratios (default: 16x9)[0m'
}

parse_args() {
  if [[ $# -eq 0 ]]; then
    help
    exit 1
  fi

  shift

  while [ $# -ge 2 ]; do
    case "$1" in
      -c|--categories)
          categories="$2"
          ;;
      -p|--purity)
          purity="$2"
          ;;
      -t|--top-range)
          top_range="$2"
          ;;
      -a|--at-least)
          at_least="$2"
          ;;
      -r|--resolutions)
          resolutions="$2"
          ;;
      --ratios)
          ratios="$2"
          ;;
      *)
          echo "[01;31m[e] Unknown option: $1[0m"
          help
          exit 1
          ;;
    esac

    shift 2
  done
}

set_metadata() {
  metadata=$(curl --silent "$API_URL&q=${Q// /%20}&categories=$CATEGORIES&purity=$PURITY&sorting=date_added&atleast=$ATLEAST&resolutions=$RESOLUTIONS&ratios=$RATIOS&page=$1")
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
ATLEAST="${at_least:-1920x1080}"
RESOLUTIONS="${resolutions:-1920x1080}"
RATIOS="${ratios:-16x9}"

banner
start_crawler
