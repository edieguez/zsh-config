#! /usr/bin/env bash

if [ $# -lt 1 ]; then
    printf "\033[01;33m[!] Usage: $(basename "$0") <backup.tar.gz> [-l|--list]\n\033[0m"
    exit 1
fi

backup_file="$1"
list_only=false

for arg in "$@"; do
    case "$arg" in
        -l|--list) list_only=true ;;
    esac
done

if [ ! -f "$backup_file" ]; then
    printf "\033[01;31m[e] File not found: $backup_file\n\033[0m"
    exit 1
fi

if [ -z "$ZSH_CUSTOM" ]; then
    printf "\033[01;31m[e] ZSH_CUSTOM is not set\n\033[0m"
    exit 1
fi

if $list_only; then
    printf "\033[34m[i] Contents of $backup_file\n\033[0m"
    tar tzf "$backup_file"
    exit 0
fi

printf "\033[34m[i] Restoring $backup_file → $ZSH_CUSTOM\n\033[0m"
tar xvzf "$backup_file" -C "$ZSH_CUSTOM"
printf "\033[34m[i] Restore finished\n\033[0m"
