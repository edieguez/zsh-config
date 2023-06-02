update-repos() {
    local target=${1:-$HOME}

    echo "Updating repos in $target"

    fd -t directory --hidden '^.git$' $target | while read -r repo; do
        pushd "$repo/.." 2>&1 >/dev/null
        echo "\nPulling changes in $repo"

        git pull

        popd 2>&1 >/dev/null
    done
}

google-translate() {
    trans en:es "$*"
}

# Load functions for local environment
source_if_exist "$ROOT_DIR/system/functions_local.sh"
