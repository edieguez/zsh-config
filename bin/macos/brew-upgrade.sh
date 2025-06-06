#!/usr/bin/env bash
cout() {
    format=$1; shift
    echo -en "[${format}m""$*""[0m"
}

main() {
    # Set the Internal Field Separator to 'new line'
    local IFS='
'
    brew update
    brew upgrade

    packages="$(brew list --cask --versions)"

    for line in $packages; do
        local package=$(echo $line | cut -d' ' -f1)
        local version=$(echo $line | cut -d' ' -f2)
        local last_version=$(brew info --cask $package | head -n1 | cut -d' ' -f3)

        if [[ $version != $last_version ]]; then
            cout "01;33" "⚠️ Updating $package $version -> $last_version\n"
            brew reinstall --cask $package
        else
            cout "01;32" "✅ $package $version is up to date\n"
        fi
    done

    brew cleanup
}

# Invoke the main function
main
