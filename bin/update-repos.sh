#! /usr/bin/env bash

initial_dir=$(pwd)
trap "cd $initial_dir" EXIT

target=${1:-$HOME}

echo "Recursively updating repos in $target"

fd -t directory --hidden --no-ignore-vcs '^.git$' $target | while read -r repo; do
	repo=$(dirname "$repo")
	pushd "$repo" 2>&1 >/dev/null

	# array for remotes
	remotes=(
		$(git remote -v | awk '{print $1,$2}' | uniq)
	)

	if [ ${#remotes[@]} -eq 0 ]; then
		echo "No remotes found in $repo"
		continue
	fi

	echo -e "\nFetching changes in $repo"
	git fetch --all --prune

	git pull --rebase

	popd 2>&1 >/dev/null
done
