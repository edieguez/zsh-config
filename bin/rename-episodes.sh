#!/usr/bin/env zsh
#
# rename_episodes - batch rename video files to SxxExx format
#
# Usage:
#   rename_episodes <pattern> [--season|-s n] [--start n] [--width n] [--apply|-a] [--help|-h]
#   rename_episodes --undo [logfile]
#
# Operates on the current working directory.

emulate -L zsh
setopt extendedglob

local usage="Usage: ${0:t} <pattern> [--season|-s n] [--start n] [--width n] [--apply|-a] [--help|-h]
       ${0:t} --undo|-u [logfile]"

if (( $# == 0 )) || [[ "$1" == -h || "$1" == --help ]]; then
    print "$usage"
    print ""
    print "  <pattern>        Glob pattern to match, quoted, e.g. '*.mkv'"
    print "  --season, -s n   Season number (default: 1)"
    print "  --start n        First episode number (default: 1)"
    print "  --width n        Zero-pad width for season/episode (default: 2)"
    print "  --apply, -a      Actually rename (default is dry run)"
    print "  --undo, -u [file] Reverse a previous run using its log file"
    print "                   (defaults to the most recent .rename_episodes_*.log)"
    print "  --help, -h       Show this help"
    exit 0
fi

# --- Undo mode ---
if [[ "$1" == --undo || "$1" == -u ]]; then
    shift
    logfile="$1"

    if [[ -z "$logfile" ]]; then
        local -a logs
        logs=( .rename_episodes_*.log(N.om) )   # newest modified first
        if (( ${#logs} == 0 )); then
            print -u2 "No .rename_episodes_*.log file found in current directory."
            exit 1
        fi
        logfile="${logs[1]}"
        print "Using most recent log: ${logfile}"
    fi

    if [[ ! -f "$logfile" ]]; then
        print -u2 "Log file not found: ${logfile}"
        exit 1
    fi

    local orig arrow new_
    local -a to_restore_from to_restore_to
    while IFS=' ' read -r orig arrow new_; do
        [[ -z "$orig" ]] && continue
        if [[ ! -e "$new_" ]]; then
            print -u2 "Skipping: '${new_}' not found (already moved or missing)."
            continue
        fi
        if [[ -e "$orig" ]]; then
            print -u2 "Skipping: original name '${orig}' already exists (would overwrite)."
            continue
        fi
        to_restore_from+=("$new_")
        to_restore_to+=("$orig")
    done < "$logfile"

    if (( ${#to_restore_from} == 0 )); then
        print "Nothing to undo."
        exit 0
    fi

    local i
    for (( i = 1; i <= ${#to_restore_from}; i++ )); do
        print "${to_restore_from[i]}  ->  ${to_restore_to[i]}"
    done

    for (( i = 1; i <= ${#to_restore_from}; i++ )); do
        mv -- "${to_restore_from[i]}" "${to_restore_to[i]}"
    done

    print "\nUndo complete using ${logfile}."
    exit 0
fi

# --- Rename mode ---
pattern="$1"
shift

season=1
start=1
width=2
apply=0

while (( $# )); do
    case "$1" in
        --season|-s) shift; season="$1" ;;
        --start)     shift; start="$1" ;;
        --width)     shift; width="$1" ;;
        --apply|-a)  apply=1 ;;
        --help|-h)   print "$usage"; exit 0 ;;
        *) print -u2 "Unknown argument: $1"; print -u2 "$usage"; exit 1 ;;
    esac
    shift
done

local name val
for name val in season "$season" start "$start" width "$width"; do
    if [[ "$val" != <-> ]]; then
        print -u2 "Invalid value for --${name}: '${val}' (must be a non-negative integer)"
        exit 1
    fi
done

local -a files
files=( ${~pattern}(N.n) )   # N: no error on no match, n: natural sort, .: regular files only

if (( ${#files} == 0 )); then
    print "No files matched pattern: ${pattern}"
    exit 0
fi

episode=$start
local -a old_names new_names
local f ext new

for f in "${files[@]}"; do
    ext="${f##*.}"
    new="S${(l:$width::0:)season}E${(l:$width::0:)episode}.${ext}"

    if [[ -e "$new" && "$new" != "$f" ]]; then
        print -u2 "Skipping '${f}': target '${new}' already exists."
    else
        old_names+=("$f")
        new_names+=("$new")
    fi
    (( episode++ ))
done

if (( ${#old_names} == 0 )); then
    print "Nothing to rename (all targets already exist or no files left after skips)."
    exit 0
fi

local i
for (( i = 1; i <= ${#old_names}; i++ )); do
    print "${old_names[i]}  ->  ${new_names[i]}"
done

if (( apply )); then
    logfile=".rename_episodes_$(date +%Y%m%d_%H%M%S).log"
    for (( i = 1; i <= ${#old_names}; i++ )); do
        mv -- "${old_names[i]}" "${new_names[i]}"
        print "${old_names[i]} -> ${new_names[i]}" >> "$logfile"
    done
    print "\nDone. Log written to ${logfile}"
    print "To undo: ${0:t} -u ${logfile}"
else
    print "\n(dry run — pass --apply/-a to actually rename)"
fi
