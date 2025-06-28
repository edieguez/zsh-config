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

clipboard="$(pbpaste)"

if [[ -z "$clipboard" ]]; then
    notify_error "MPV launch failed: clipboard is empty"
    exit 1
fi

mpv_url_regex='^https?://[^[:space:]]+$'

if [[ ! "$clipboard" =~ $mpv_url_regex ]]; then
    notify_error "MPV launch failed: clipboard does not contain a valid URL"
    exit 1
fi

notify "Launching MPV with URL $clipboard"

mpv "$clipboard" || {
    notify_error "MPV launch failed: $?"
    exit 1
}
