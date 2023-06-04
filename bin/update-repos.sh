#! /usr/bin/env bash

initial_dir=$(pwd)
trap "cd $initial_dir" EXIT

target=${1:-$HOME}

echo "Recursively updating repos in $target"

fd -t directory --hidden '^.git$' $target | while read -r repo; do
    pushd "$repo/.." 2>&1 >/dev/null
    echo -e "\nPulling changes in $repo"

    git pull

    popd 2>&1 >/dev/null
done
