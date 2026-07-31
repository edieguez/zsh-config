#! /usr/bin/env bash
# Wallhaven API v1 client — https://wallhaven.cc/help/api
set -euo pipefail

API_BASE='https://wallhaven.cc/api/v1'
: "${WALLHAVEN_DIR:="$HOME/Pictures/wallhaven"}"
: "${WALLHAVEN_KEY:=}"

# --- display -----------------------------------------------------------------

if [[ -t 2 ]]; then IS_TTY=true; else IS_TTY=false; fi

if [[ "$IS_TTY" == true && -z "${NO_COLOR:-}" ]]; then
  C_BLUE=$'\033[01;34m' C_YELLOW=$'\033[01;33m' C_RED=$'\033[01;31m'
  C_GREEN=$'\033[01;32m' C_CYAN=$'\033[01;36m' C_MAGENTA=$'\033[01;35m'
  C_BOLD=$'\033[01m' C_DIM=$'\033[02m' C_RESET=$'\033[0m'
else
  C_BLUE='' C_YELLOW='' C_RED='' C_GREEN='' C_CYAN='' C_MAGENTA=''
  C_BOLD='' C_DIM='' C_RESET=''
fi

info()  { printf '%sℹ️  %s%s\n' "$C_BLUE" "$*" "$C_RESET" >&2; }
warn()  { printf '%s⚠️  %s%s\n' "$C_YELLOW" "$*" "$C_RESET" >&2; }
ok()    { printf '%s✅ %s%s\n' "$C_GREEN" "$*" "$C_RESET" >&2; }
error() { printf '%s❌ %s%s\n' "$C_RED" "$*" "$C_RESET" >&2; }
die()   { error "$*"; exit 1; }

heading()  { printf '%s%s%s%s\n' "$C_BOLD" "$C_CYAN" "$*" "$C_RESET"; }

# Reads "key<TAB>value" lines on stdin and prints them as an aligned, colored-label list
print_kv_stream() {
  local key value
  while IFS=$'\t' read -r key value; do
    printf '  %s%s%-14s%s %s\n' "$C_BOLD" "$C_MAGENTA" "$key" "$C_RESET" "$value"
  done
}

# color_swatch <hex> — a small true-color block followed by the hex code
color_swatch() {
  local hex=${1#'#'} r g b
  if [[ "$IS_TTY" == true ]]; then
    r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
    printf '\033[48;2;%d;%d;%dm  \033[0m %s#%s%s' "$r" "$g" "$b" "$C_DIM" "$hex" "$C_RESET"
  else
    printf '#%s' "$hex"
  fi
}

help() {
  cat <<EOF
$(heading '🌄 Wallhaven API v1 client') — https://wallhaven.cc/help/api

$(heading 'Usage:')
  $(basename "$0") <command> [options]
  $(basename "$0") [query] [options]          (implicit 'search')

$(heading 'Commands:')
  search [query] [options]   Search wallpapers and download the results
  wall <id> [-d]             Show wallpaper info; -d/--download to save it
  tag <id>                   Show tag info
  collections [user] [id]    List collections, or download collection <id>
  settings                   Show your account settings (requires API key)

$(heading 'Search options:')
  -c, --categories <bits>    100/101/111*/etc (general/anime/people)
  -p, --purity <bits>        100*/110/111/etc (sfw/sketchy/nsfw; nsfw needs API key)
  -s, --sorting <mode>       date_added*, relevance, random, views, favorites, toplist, hot
  -o, --order <dir>          desc*, asc
  -t, --top-range <range>    1d, 3d, 1w, 1M*, 3M, 6M, 1y (used with --sorting toplist)
  -a, --at-least <res>       Minimum resolution (default: 1920x1080)
  -r, --resolutions <list>   Exact resolutions, comma-separated (default: 1920x1080)
      --ratios <list>        Aspect ratios, comma-separated (default: 16x9)
      --colors <hex>         Dominant color, e.g. 660000 (see the site's palette)
      --seed <seed>          Seed for random sorting ([a-zA-Z0-9]{6})
      --ai-art               Include AI-generated art (filtered out by default)
      --no-filter            Ignore at-least, resolutions and ratios
      --page <n>             Start page (default: 1)
      --pages <n>            Maximum number of pages to fetch (24 wallpapers/page)
  -d, --dir <path>           Download directory (default: \$WALLHAVEN_DIR)
      --clean                Delete the download directory first (asks confirmation)

$(heading 'Collections options:')
  -p, --purity <bits>        Purity filter when downloading a collection
  -d, --dir <path>           Download directory

$(heading 'Query syntax:')
  tagname          fuzzy search for a tag/keyword
  -tagname         exclude a tag/keyword
  +tag1 +tag2      must have both tags
  @username        uploads by a user
  id:123           exact tag search (cannot be combined)
  type:png         file type (png or jpg)
  like:94x38z      wallpapers with similar tags

$(heading 'Environment:')
  WALLHAVEN_KEY    API key (https://wallhaven.cc/settings/account)
  WALLHAVEN_DIR    Download directory (default: ~/Pictures/wallhaven)

$(heading 'Examples:')
  $(basename "$0") "landscape" -s toplist -t 1w
  $(basename "$0") search "+nature -city" --colors 336600 --pages 2
  $(basename "$0") wall 94x38z --download
  $(basename "$0") collections someuser 15 -d ~/Pictures/collection
EOF
}

key_hint() {
  if [[ -z "$WALLHAVEN_KEY" ]]; then
    warn 'WALLHAVEN_KEY is not set — NSFW results and account features are unavailable'
    info 'Get your API key at https://wallhaven.cc/settings/account'
  fi
}

# --- API ---------------------------------------------------------------------

require_cmd() {
  command -v "$1" > /dev/null 2>&1 || die "Missing required command: $1"
}

# Call as: require_value "$@" — fails when the option in $1 has no value in $2
require_value() {
  [[ $# -ge 2 ]] || die "Option $1 requires a value"
}

require_key() {
  [[ -n "$WALLHAVEN_KEY" ]] || die 'This command requires WALLHAVEN_KEY (https://wallhaven.cc/settings/account)'
}

# api_get <path> [--data-urlencode key=value ...] — prints the response body
api_get() {
  local path=$1
  shift
  local attempt response http_code body
  local auth=()
  [[ -n "$WALLHAVEN_KEY" ]] && auth=(--header "X-API-Key: $WALLHAVEN_KEY")

  for attempt in 1 2 3; do
    if ! response=$(curl --silent --get --write-out $'\n%{http_code}' \
      ${auth[@]+"${auth[@]}"} "$@" "$API_BASE$path"); then
      die "Network error while calling $API_BASE$path"
    fi

    http_code=${response##*$'\n'}
    body=${response%$'\n'*}

    case "$http_code" in
    200)
      printf '%s' "$body"
      return 0
      ;;
    401)
      die 'Unauthorized: invalid API key, or NSFW content requested without one'
      ;;
    429)
      warn "Rate limited (45 requests/min) — waiting 15s (attempt $attempt/3)"
      sleep 15
      ;;
    *)
      die "API error: HTTP $http_code for $path"
      ;;
    esac
  done

  die 'Still rate limited after 3 attempts, giving up'
}

# --- downloading -------------------------------------------------------------

count_files() {
  find "$1" -type f ! -name '*.part' 2> /dev/null | wc -l | tr -d ' '
}

summary() {
  local dir=$1 before=$2 total=$3
  local now
  now=$(count_files "$dir")
  ok "Downloaded $((now - before)) new wallpapers to $dir ($now files, $total matched)"
}

file_size() {
  stat -f%z "$1" 2> /dev/null || stat -c%s "$1" 2> /dev/null || echo 0
}

human_size() {
  awk -v b="$1" 'BEGIN {
    if (b >= 1048576) printf "%.1f MiB", b / 1048576
    else printf "%.0f KiB", b / 1024
  }'
}

human_time() {
  awk -v s="$1" 'BEGIN {
    if (s < 0) s = 0
    if (s >= 60) printf "%dm%02ds", s / 60, s % 60
    else printf "%ds", s
  }'
}

# render_overall_bar <done> <total> <page> <page_total>
# <page_total> of 0 or 1 hides the page indicator (single-page runs).
render_overall_bar() {
  local done=$1 total=$2 page=$3 page_total=$4 width=40
  awk -v d="$done" -v t="$total" -v p="$page" -v pt="$page_total" -v w="$width" \
    -v bold="$C_BOLD" -v cyan="$C_CYAN" -v dim="$C_DIM" \
    -v yellow="$C_YELLOW" -v green="$C_GREEN" -v reset="$C_RESET" 'BEGIN {
    pct = (t > 0) ? int(d * 100 / t) : 0
    filled = int(w * pct / 100)
    if (filled > w) filled = w
    bar = ""
    for (i = 0; i < filled; i++) bar = bar "█"
    empty = ""
    for (i = 0; i < w - filled; i++) empty = empty "░"
    barcolor = (pct >= 100) ? green : (pct >= 40) ? cyan : yellow
    page_s = (pt + 0 > 1) ? sprintf("  %sPage %d/%d%s", dim, p, pt, reset) : ""
    printf "%s%sOverall%s  [%s%s%s%s%s%s] %s%3d%%%s (%d/%d)%s", \
      bold, cyan, reset, barcolor, bar, reset, dim, empty, reset, bold, pct, reset, d, t, page_s
  }'
}

# render_file_bar <done_bytes> <total_bytes> <elapsed_seconds>
render_file_bar() {
  local done=$1 total=$2 elapsed=$3 width=40
  awk -v d="$done" -v t="$total" -v e="$elapsed" -v w="$width" \
    -v bold="$C_BOLD" -v blue="$C_BLUE" -v dim="$C_DIM" \
    -v yellow="$C_YELLOW" -v green="$C_GREEN" -v reset="$C_RESET" 'BEGIN {
    pct = (t > 0) ? int(d * 100 / t) : 0
    speed = (e > 0) ? d / e : 0
    eta = (speed > 0 && t > d) ? int((t - d) / speed) : 0
    filled = int(w * pct / 100)
    if (filled > w) filled = w
    bar = ""
    for (i = 0; i < filled; i++) bar = bar "█"
    empty = ""
    for (i = 0; i < w - filled; i++) empty = empty "░"
    barcolor = (pct >= 100) ? green : (pct >= 40) ? blue : yellow
    speed_s = (speed >= 1048576) ? sprintf("%.1f MiB/s", speed / 1048576) : sprintf("%.0f KiB/s", speed / 1024)
    printf "%s%sFile   %s  [%s%s%s%s%s%s] %s%3d%%%s  %s%s%s  eta %ds", \
      bold, blue, reset, barcolor, bar, reset, dim, empty, reset, bold, pct, reset, dim, speed_s, reset, eta
  }'
}

# progress_draw_block <overall_bar_line> <file_info_line> <file_bar_line>
# Redraws a single persistent 3-line block in place: the overall progress bar,
# the current file's info, and the current file's progress bar. Only ever one
# block on screen for the whole run — never one per file.
progress_draw_block() {
  [[ "$IS_TTY" == true ]] || return 0
  if [[ "${PROGRESS_DRAWN:-false}" == true ]]; then
    printf '\033[3A\033[0J' >&2
  fi
  printf '%s\n%s\n%s\n' "$1" "$2" "$3" >&2
  PROGRESS_DRAWN=true
}

progress_clear_block() {
  if [[ "$IS_TTY" == true && "${PROGRESS_DRAWN:-false}" == true ]]; then
    printf '\033[3A\033[0J' >&2
  fi
  PROGRESS_DRAWN=false
}

# download_file <url> <dest_dir> <resolution> <total_bytes>
# Reads/updates the OVERALL_DONE/OVERALL_TOTAL globals set by the caller.
download_file() {
  local url=$1 dest_dir=$2 resolution=$3 total_bytes=$4
  local filename dest tmp start elapsed size info_line overall_line file_bar_line

  filename=$(basename "$url")
  dest="$dest_dir/$filename"
  tmp="$dest.part"

  if [[ -f "$dest" && "$(file_size "$dest")" -ge "$total_bytes" ]]; then
    OVERALL_DONE=$((OVERALL_DONE + 1))
    return 0
  fi

  info_line="${C_BOLD}${filename}${C_RESET} ${C_DIM}·${C_RESET} ${C_CYAN}${resolution}${C_RESET} ${C_DIM}·${C_RESET} ${C_YELLOW}$(human_size "$total_bytes")${C_RESET}"

  curl --silent --location --continue-at - --output "$tmp" "$url" &
  CURRENT_DL_PID=$!
  start=$(date +%s)

  if [[ "$IS_TTY" == true ]]; then
    while kill -0 "$CURRENT_DL_PID" 2> /dev/null; do
      size=$(file_size "$tmp")
      elapsed=$(( $(date +%s) - start ))
      overall_line=$(render_overall_bar "$OVERALL_DONE" "$OVERALL_TOTAL" "$PAGE_CURRENT" "$PAGE_TOTAL")
      file_bar_line=$(render_file_bar "$size" "$total_bytes" "$elapsed")
      progress_draw_block "$overall_line" "$info_line" "$file_bar_line"
      sleep 0.15
    done
  else
    info "Downloading $info_line"
  fi

  if wait "$CURRENT_DL_PID"; then
    mv "$tmp" "$dest"
    OVERALL_DONE=$((OVERALL_DONE + 1))
    if [[ "$IS_TTY" == true ]]; then
      overall_line=$(render_overall_bar "$OVERALL_DONE" "$OVERALL_TOTAL" "$PAGE_CURRENT" "$PAGE_TOTAL")
      file_bar_line=$(render_file_bar "$total_bytes" "$total_bytes" 1)
      progress_draw_block "$overall_line" "$info_line" "$file_bar_line"
    fi
  else
    progress_clear_block
    warn "Failed to download $filename (partial file kept at $tmp for resume)"
  fi

  unset CURRENT_DL_PID
}

# Paginated listing download step: reads {path, resolution, file_size} JSON
# lines and downloads each against the persistent overall/file progress block.
download_page() {
  local dir=$1 metadata=$2
  local item url resolution size

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    url=$(jq -r '.path' <<< "$item")
    resolution=$(jq -r '.resolution' <<< "$item")
    size=$(jq -r '.file_size' <<< "$item")
    download_file "$url" "$dir" "$resolution" "$size"
  done < <(jq -c '.data[]' <<< "$metadata")
}

# Paginated listing download. Reads the PARAMS array plus the SEED, START_PAGE
# and MAX_PAGES globals set by the calling command.
download_listing() {
  local path=$1 dir=$2
  local page=$START_PAGE
  local total='' last_page end_page metadata before

  mkdir -p "$dir"
  before=$(count_files "$dir")

  trap 'kill "${CURRENT_DL_PID:-}" 2>/dev/null || true; progress_clear_block; summary "$dir" "$before" "${total:-?}"; exit 130' INT

  while :; do
    local page_params=(${PARAMS[@]+"${PARAMS[@]}"} --data-urlencode "page=$page")
    [[ -n "$SEED" ]] && page_params+=(--data-urlencode "seed=$SEED")
    metadata=$(api_get "$path" "${page_params[@]}")

    if [[ -z "$total" ]]; then
      total=$(jq -r '.meta.total' <<< "$metadata")
      last_page=$(jq -r '.meta.last_page' <<< "$metadata")
      # random sorting returns a seed; reuse it so later pages have no repeats
      [[ -z "$SEED" ]] && SEED=$(jq -r '.meta.seed // empty' <<< "$metadata")

      if [[ "$total" -eq 0 ]]; then
        trap - INT
        warn 'No wallpapers found'
        return 0
      fi

      end_page=$last_page
      if [[ -n "$MAX_PAGES" && $((START_PAGE + MAX_PAGES - 1)) -lt $last_page ]]; then
        end_page=$((START_PAGE + MAX_PAGES - 1))
      fi

      info "Found $total wallpapers across $last_page pages (fetching pages $START_PAGE-$end_page)"
      OVERALL_DONE=0
      OVERALL_TOTAL=$total
      PAGE_TOTAL=$end_page
    fi

    PAGE_CURRENT=$page
    download_page "$dir" "$metadata"

    if [[ "$page" -ge "$end_page" ]]; then
      break
    fi
    page=$((page + 1))
  done

  trap - INT
  progress_clear_block
  summary "$dir" "$before" "$total"
}

# --- commands ----------------------------------------------------------------

cmd_search() {
  local query='' categories=111 purity=100 sorting=date_added order=desc
  local top_range=1M at_least=1920x1080 resolutions=1920x1080 ratios=16x9
  local colors='' ai_art=1 no_filter=false clean=false dir=$WALLHAVEN_DIR
  SEED='' START_PAGE=1 MAX_PAGES=''

  while [[ $# -ge 1 ]]; do
    case "$1" in
    -c | --categories) require_value "$@"; categories=$2; shift 2 ;;
    -p | --purity) require_value "$@"; purity=$2; shift 2 ;;
    -s | --sorting) require_value "$@"; sorting=$2; shift 2 ;;
    -o | --order) require_value "$@"; order=$2; shift 2 ;;
    -t | --top-range) require_value "$@"; top_range=$2; shift 2 ;;
    -a | --at-least) require_value "$@"; at_least=$2; shift 2 ;;
    -r | --resolutions) require_value "$@"; resolutions=$2; shift 2 ;;
    --ratios) require_value "$@"; ratios=$2; shift 2 ;;
    --colors) require_value "$@"; colors=$2; shift 2 ;;
    --seed) require_value "$@"; SEED=$2; shift 2 ;;
    --page) require_value "$@"; START_PAGE=$2; shift 2 ;;
    --pages) require_value "$@"; MAX_PAGES=$2; shift 2 ;;
    -d | --dir) require_value "$@"; dir=$2; shift 2 ;;
    --ai-art) ai_art=0; shift ;;
    --no-filter) no_filter=true; shift ;;
    --clean) clean=true; shift ;;
    -u | --update) shift ;; # legacy no-op: merging into the directory is now the default
    -h | --help) help; exit 0 ;;
    -*) error "Unknown search option: $1"; help; exit 1 ;;
    *) query="${query:+$query }$1"; shift ;;
    esac
  done

  [[ "$START_PAGE" =~ ^[1-9][0-9]*$ ]] || die '--page must be a positive number'
  [[ -z "$MAX_PAGES" || "$MAX_PAGES" =~ ^[1-9][0-9]*$ ]] || die '--pages must be a positive number'

  PARAMS=(
    --data-urlencode "q=$query"
    --data-urlencode "categories=$categories"
    --data-urlencode "purity=$purity"
    --data-urlencode "sorting=$sorting"
    --data-urlencode "order=$order"
    --data-urlencode "ai_art_filter=$ai_art"
  )
  [[ "$sorting" == toplist ]] && PARAMS+=(--data-urlencode "topRange=$top_range")
  [[ -n "$colors" ]] && PARAMS+=(--data-urlencode "colors=$colors")
  if [[ "$no_filter" != true ]]; then
    PARAMS+=(
      --data-urlencode "atleast=$at_least"
      --data-urlencode "resolutions=$resolutions"
      --data-urlencode "ratios=$ratios"
    )
  fi

  if [[ "$clean" == true && -d "$dir" ]]; then
    printf '%s⚠️  Delete ALL files in %s? [y/N] %s' "$C_YELLOW" "$dir" "$C_RESET" >&2
    local reply=''
    read -r reply || true
    case "$reply" in
    y | Y | yes | YES)
      rm -rf "$dir"
      info "Removed $dir"
      ;;
    *)
      info 'Keeping existing files'
      ;;
    esac
  fi

  info "Search: '${query:-<latest>}' | categories=$categories purity=$purity sorting=$sorting order=$order → $dir"
  download_listing '/search' "$dir"
}

cmd_wall() {
  local id='' download=false
  while [[ $# -ge 1 ]]; do
    case "$1" in
    -d | --download) download=true; shift ;;
    -h | --help) help; exit 0 ;;
    -*) die "Unknown wall option: $1" ;;
    *) id=$1; shift ;;
    esac
  done
  [[ -n "$id" ]] || die "Usage: $(basename "$0") wall <id> [-d|--download]"

  local body
  body=$(api_get "/w/$id")

  heading "🖼️  Wallpaper $id"
  jq -r '.data | [
    ["URL", .url],
    ["Uploader", (.uploader.username // "-")],
    ["Resolution", "\(.resolution)  (ratio \(.ratio))"],
    ["Size", "\(.file_size / 1048576 * 100 | round / 100) MiB (\(.file_type))"],
    ["Category", .category],
    ["Purity", .purity],
    ["Views", (.views | tostring)],
    ["Favorites", (.favorites | tostring)],
    ["Created", .created_at],
    ["Source", (if .source == "" then "-" else .source end)],
    ["Tags", ((.tags // []) | if length == 0 then "-" else map("\(.name) (#\(.id))") | join(", ") end)]
  ][] | @tsv' <<< "$body" | print_kv_stream

  local swatches='' hex
  while IFS= read -r hex; do
    swatches+="$(color_swatch "$hex")  "
  done < <(jq -r '.data.colors[]' <<< "$body")
  printf '  %s%s%-14s%s %s\n' "$C_BOLD" "$C_MAGENTA" 'Colors' "$C_RESET" "$swatches"

  if [[ "$download" == true ]]; then
    mkdir -p "$WALLHAVEN_DIR"
    local path resolution size
    path=$(jq -r '.data.path' <<< "$body")
    resolution=$(jq -r '.data.resolution' <<< "$body")
    size=$(jq -r '.data.file_size' <<< "$body")
    OVERALL_DONE=0
    OVERALL_TOTAL=1
    PAGE_CURRENT=1
    PAGE_TOTAL=0
    trap 'kill "${CURRENT_DL_PID:-}" 2>/dev/null || true; progress_clear_block; exit 130' INT
    download_file "$path" "$WALLHAVEN_DIR" "$resolution" "$size"
    trap - INT
    progress_clear_block
    ok "Saved $(basename "$path") to $WALLHAVEN_DIR"
  fi
}

cmd_tag() {
  local id=${1:-}
  [[ -n "$id" && "$id" != -h && "$id" != --help ]] || die "Usage: $(basename "$0") tag <id>"

  local body
  body=$(api_get "/tag/$id")

  heading "🏷️  Tag $id"
  jq -r '.data | [
    ["Name", .name],
    ["Alias", (if .alias == "" then "-" else .alias end)],
    ["Category", "\(.category) (#\(.category_id))"],
    ["Purity", .purity],
    ["Created", .created_at]
  ][] | @tsv' <<< "$body" | print_kv_stream
}

cmd_collections() {
  local username='' id='' purity='' dir=$WALLHAVEN_DIR

  while [[ $# -ge 1 ]]; do
    case "$1" in
    -p | --purity) require_value "$@"; purity=$2; shift 2 ;;
    -d | --dir) require_value "$@"; dir=$2; shift 2 ;;
    -h | --help) help; exit 0 ;;
    -*) die "Unknown collections option: $1" ;;
    *)
      if [[ -z "$username" ]]; then
        username=$1
      elif [[ -z "$id" ]]; then
        id=$1
      else
        die "Usage: $(basename "$0") collections [username] [id]"
      fi
      shift
      ;;
    esac
  done

  if [[ -n "$id" ]]; then
    SEED='' START_PAGE=1 MAX_PAGES=''
    PARAMS=()
    [[ -n "$purity" ]] && PARAMS+=(--data-urlencode "purity=$purity")
    info "Downloading collection $id of $username → $dir"
    download_listing "/collections/$username/$id" "$dir"
    return 0
  fi

  local path body
  if [[ -n "$username" ]]; then
    path="/collections/$username"
  else
    require_key
    path='/collections'
  fi
  body=$(api_get "$path")

  if [[ "$(jq '.data | length' <<< "$body")" -eq 0 ]]; then
    warn 'No collections found'
    return 0
  fi

  heading "📁 Collections${username:+ of $username}"
  {
    printf 'ID\tLABEL\tPUBLIC\tCOUNT\tVIEWS\n'
    jq -r '.data[] | [.id, .label, (if .public == 1 then "yes" else "no" end), .count, .views] | @tsv' <<< "$body"
  } | column -t -s $'\t' | awk -v bold="$C_BOLD" -v cyan="$C_CYAN" -v reset="$C_RESET" \
        'NR==1 { print "  " bold cyan $0 reset; next } { print "  " $0 }'
}

cmd_settings() {
  require_key

  local body
  body=$(api_get '/settings')

  heading '⚙️  Account settings'
  jq -r '.data | [
    ["Thumb size", .thumb_size],
    ["Per page", (.per_page | tostring)],
    ["Purity", (.purity | join(", "))],
    ["Categories", (.categories | join(", "))],
    ["Resolutions", ((.resolutions // []) | join(", ") | if . == "" then "-" else . end)],
    ["Ratios", ((.aspect_ratios // []) | join(", ") | if . == "" then "-" else . end)],
    ["Top range", .toplist_range],
    ["Tag blacklist", ((.tag_blacklist // []) | map(select(. != "")) | join(", ") | if . == "" then "-" else . end)],
    ["User blacklist", ((.user_blacklist // []) | map(select(. != "")) | join(", ") | if . == "" then "-" else . end)]
  ][] | @tsv' <<< "$body" | print_kv_stream
}

# --- main --------------------------------------------------------------------

main() {
  require_cmd curl
  require_cmd jq

  if [[ $# -eq 0 ]]; then
    help
    exit 1
  fi

  case "$1" in
  -h | --help | help) help; exit 0 ;;
  search) shift; key_hint; cmd_search "$@" ;;
  wall) shift; cmd_wall "$@" ;;
  tag) shift; cmd_tag "$@" ;;
  collections) shift; cmd_collections "$@" ;;
  settings) shift; cmd_settings "$@" ;;
  *) key_hint; cmd_search "$@" ;;
  esac
}

main "$@"
