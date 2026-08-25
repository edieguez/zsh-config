#! /usr/bin/env bash
# This script is a wrapper for queueing a clipboard URL/file into mpv via
# plugins/mpv-remote/bin/mpv-remote add - appends to a running instance's
# playlist (or starts a fresh one if none is running), instead of always
# launching a brand new, disconnected mpv process.
#
# Usage: mpv-wrapper.sh [-n|--next]
#   -n, --next   insert right after whatever's currently playing, instead
#                of appending to the end (mpv-remote add's own -n/--next flag)

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

MPV_REMOTE="$HOME/.config/mpv/plugins/mpv-remote/bin/mpv-remote"

mpv_remote_flags=()
case "${1:-}" in
    -n|--next)
        mpv_remote_flags=(-n)
        ;;
esac

clipboard="$(pbpaste | tr -d '\n')"

# mpv-remote/playlist_manager.lua don't validate the item themselves (only
# ctrl+v/paste-url inside mpv does) - this is the safety net for arbitrary
# clipboard content coming from a hotkey rather than a deliberate CLI call.
mpv_url_regex='^https?://[^[:space:]]+$'

if ! [[ "$clipboard" =~ $mpv_url_regex ]] && ! [[ -f "$clipboard" ]]; then
    # A file copied in Finder (Cmd+C) lands on the pasteboard as a file
    # reference object, not plain text - pbpaste (which only reads the
    # plain-text flavor) sees either nothing, or - what real Finder
    # actually does, verified against a real Cmd+C - just the bare
    # filename with no directory, since Finder uses a persistent file-ID
    # reference internally (/.file/id=N.M) so the copy survives the file
    # being renamed or moved. That reference isn't resolvable as a path
    # via -f/stat/python; it has to go through AppKit's pasteboard API.
    #
    # Read the pasteboard as an NSURL object directly via JXA. Tried the
    # classic AppleScript `the clipboard as «class furl»` coercion first
    # and rejected it: it resolved correctly once, then on a later read of
    # the *same* clipboard reference started returning just "/basename"
    # instead of the full path - unreliable. This NSPasteboard read is
    # stable across repeated reads in testing, and correctly returns
    # nothing for non-file clipboard content instead of inventing a bogus
    # path (the furl coercion turned plain text "hello world" into
    # "/hello world" rather than failing).
    resolved="$(osascript -l JavaScript -e '
        ObjC.import("AppKit");
        var pb = $.NSPasteboard.generalPasteboard;
        var urls = pb.readObjectsForClassesOptions($.NSArray.arrayWithObject($.NSURL), $.NSDictionary.dictionary);
        if (urls && urls.count > 0) { urls.objectAtIndex(0).path.js; } else { ""; }
    ' 2>/dev/null)"
    if [[ -n "$resolved" ]] && [[ -f "$resolved" ]]; then
        clipboard="$resolved"
    fi
fi

if [[ "$clipboard" =~ $mpv_url_regex ]] || [[ -f "$clipboard" ]]; then
    # ${arr[@]+"${arr[@]}"} rather than a bare "${mpv_add_flags[@]}": macOS
    # ships bash 3.2, where expanding an empty array under `set -u` throws
    # "unbound variable" (fixed in bash 4.4+, but that's what /usr/bin/env
    # bash resolves to here).
    if output=$("$MPV_REMOTE" add ${mpv_remote_flags[@]+"${mpv_remote_flags[@]}"} "$clipboard" 2>&1); then
        notify "$output"
    else
        last_line=$(printf '%s' "$output" | grep -v '^$' | tail -1)
        notify_error "mpv-remote add failed: ${last_line:-unknown error}"
        exit 1
    fi
else
    notify_error "Clipboard is not a URL or an existing file"
    exit 1
fi
