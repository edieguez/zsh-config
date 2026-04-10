#!/usr/bin/env bash
cout() {
    format=$1; shift
    echo -en "[${format}m""$*""[0m"
}

main() {
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        cout "01;31" "❌ Homebrew is not installed. Please install it first.\n"
        exit 1
    fi

    # Ensure brew update and upgrade succeed
    brew update || { cout "01;31" "❌ Failed to update Homebrew\n"; exit 1; }
    brew upgrade || { cout "01;31" "❌ Failed to upgrade Homebrew\n"; exit 1; }

    # Set the Internal Field Separator to 'new line'
    local IFS='
'
    cout "01;34" "ℹ️ Upgrading all casks\n"
    packages="$(brew list --cask --versions)"

    for line in $packages; do
        local package=$(echo $line | cut -d' ' -f1)
        local version=$(echo $line | cut -d' ' -f2)
        local last_version=$(brew info --cask $package | sed -n 's/^==>.*: \([^ ]*\).*/\1/p')

        if [[ $version != $last_version ]]; then
            cout "01;34" "ℹ️ Updating $package $version -> $last_version\n"
            brew reinstall --cask $package
        else
            cout "01;32" "✅ $package $version is up to date\n"
        fi
    done

    brew cleanup
}

# Invoke the main function
main
