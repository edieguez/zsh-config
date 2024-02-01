#! /usr/bin/env bash

initial_dir=$(pwd)
trap "cd $initial_dir" EXIT

target=${1:-$HOME}

echo "Recursively updating repos in $target"

fd -t directory --hidden --no-ignore-vcs '^.git$' $target | while read -r repo; do
	repo=$(dirname "$repo")
	pushd "$repo" 2>&1 >/dev/null
	echo -e "\nPulling changes in $repo"

	git pull --rebase

	popd 2>&1 >/dev/null
done
