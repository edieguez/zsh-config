#! /usr/bin/env bash

printf "[34m[i] Starting local backup\n[0m"
initial_dir=$(pwd)

printf "[34m[i] Moving to $ZSH_CUSTOM\n[0m"
pushd "$ZSH_CUSTOM" > /dev/null
trap 'popd > /dev/null' EXIT

printf "[34m[i] Searching for local configuration files\n[0m"
local_files=()
while IFS= read -r -d '' entry; do
    local_files+=("$entry")
done < <(find -L . \( \( -type d -name local \) -o \( -type f -regex '.*\.local.sh$' \) \) -print0)

if [ ${#local_files[@]} -gt 0 ]; then
    printf "[34m[i] Local configuration files found\n[0m"

    backup_filename="$(date +%Y%m%d_%H%M%S) $HOSTNAME.tar.gz"
    printf "[01;34m[i] Creating backup file: $backup_filename\n[0m"

    tar cvzf "$initial_dir/$backup_filename" "${local_files[@]}"

    printf "[34m[i] Local backup finished\n[0m"
else
    printf "[01;33m[!] No local configuration files found\n[0m"
    exit 1
fi
