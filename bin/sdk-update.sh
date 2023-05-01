#! /usr/bin/env bash
load_sdkman() {
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
}

load_sdkman

sdk_list=$(sdk list java | sed 's:\s*$::g')
declare -a sdk_versions=(
    $(echo "$sdk_list" | grep -E '(installed|local only)' | grep -Eio '[0-9]+[\.-][a-z0-9\.-]+$' | sort --version-sort --reverse)
)

for sdk_version in "${sdk_versions[@]}"; do
    echo -n "[$sdk_version]"

    type=$(echo "$sdk_version" | grep -Eio '([a-z][0-9a-z]+-[^\s]+$|[^-]+$)')

    if [[ $type =~ ^r ]]; then
        new_version=$(echo "$sdk_list" | grep $type | grep -Eio '[0-9]+[\.-][a-z0-9\.-]+$' | sort --reverse | head -n 1)
    else
        base_version=$(echo $sdk_version | grep -Eio '^[0-9]+')
        new_version=$(echo "$sdk_list" | grep -Eio " $base_version[^|-]+-?$type" | sed 's: ::g' | sort --reverse | head -n 1)
    fi

    if [[ $sdk_version < $new_version ]]; then
        echo -e "\b -> $new_version]"
        is_default=$(echo "$sdk_list" | grep '>>>' | grep -Eio "$sdk_version")

        yes n | sdk install java $new_version

        echo

        if [ -n "$is_default" ]; then
            sdk default java $new_version
        fi

        sdk uninstall java $sdk_version
    else
        echo -e "\b is up to date]"
    fi
done

sdk selfupdate
sdk flush
