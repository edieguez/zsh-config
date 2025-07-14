#! /usr/bin/env bash

printf "[34m[i] Starting local backup\n[0m"
initial_dir=$(pwd)

printf "[34m[i] Moving to $ZSH_CUSTOM\n[0m"
pushd $ZSH_CUSTOM > /dev/null

printf "[34m[i] Searching for local configuration files\n[0m"
local_files=$(find -L . -type d -name local -or -regex '.*\.local.sh$')

if [ -n "$local_files" ]; then
    printf "[34m[i] Local configuration files found\n[0m"

    backup_filename="$(date +%Y%m%d_%H%M%S) $(hostname).tar.gz"
    printf "[01;34m[i] Creating backup file: $backup_filename\n[0m"

    tar cvzf "$initial_dir/$backup_filename" $local_files

    printf "[34m[i] Local backup finished\n[0m"
    popd > /dev/null
else
    printf "[01;33m[!] No local configuration files found\n[0m"

    popd > /dev/null
    exit 1
fi
