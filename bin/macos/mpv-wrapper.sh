#! /usr/bin/env bash
# This script is a wrapper for launching MPV with a URL from the clipboard

set -euo pipefail

if type -p terminal-notifier &>/dev/null; then
    notify() {
        local message
        message=$(printf '%s' "$1" | sed 's/"/\\"/g')
        terminal-notifier -title "MPV" -message "${message}" -sound "Purr"
    }
    notify_error() {
        local message
        message=$(printf '%s' "$1" | sed 's/"/\\"/g')
        terminal-notifier -title "MPV error" -message "${message}" -sound "Basso"
    }
else
    notify() {
        local message
        message=$(printf '%s' "$1" | sed 's/"/\\"/g')
        osascript -e "display notification \"${message}\" with title \"MPV\" sound name \"Purr\""
    }

    notify_error() {
        local message
        message=$(printf '%s' "$1" | sed 's/"/\\"/g')
        osascript -e "display notification \"${message}\" with title \"MPV error\" sound name \"Basso\""
    }
fi

clipboard="$(pbpaste | tr -d '\n')"

mpv_url_regex='^https?://[^[:space:]]+$'
mpv_base=(mpv --hwdec=videotoolbox --ao=coreaudio --audio-buffer=0.5)

if [[ "$clipboard" =~ $mpv_url_regex ]] || [[ -f "$clipboard" ]]; then
    notify "Launching MPV with $clipboard"
    mpv_output=$("${mpv_base[@]}" "$clipboard" 2>&1)
else
    notify "Launching MPV in idle mode"
    mpv_output=$("${mpv_base[@]}" --idle 2>&1)
fi || {
    last_line=$(printf '%s' "$mpv_output" | grep -v '^$' | tail -1)
    notify_error "MPV launch failed: ${last_line:-unknown error}"
    exit 1
}
