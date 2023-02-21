#! /usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file> <file> ... <destination>"
    exit 1
fi

if [ -d "${@: -1}" ]; then
    set -- "${@:1:$#-1}" "${@: -1}/"
fi

rsync -avP \
    --compress \
    --recursive --links --perms --times --group --owner --devices --specials \
    --human-readable \
    "$@"
