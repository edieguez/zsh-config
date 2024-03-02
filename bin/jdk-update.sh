#! /usr/bin/env bash
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
else
    echo "SDKMAN! (https://sdkman.io) is not installed"
    exit 1
fi

sdk_list=$(awk -F '|' 'NF == 6 {gsub(/ /,"", $0); print $0}' <(sdk list java))
declare -a sdk_versions=(
    $(echo "$sdk_list" |\
        awk -F '|' '$5 ~ /(installed|local only)/ {print $NF}' |\
        sort --version-sort --reverse)
)

for sdk_version in "${sdk_versions[@]}"; do
    echo -n "[$sdk_version]"

    type=$(echo "$sdk_version" | sed 's/^[0-9\.\-]\+//g')
    base_version=$(echo $sdk_version | grep -Eio '^[0-9]+')
    new_version=$(echo "$sdk_list" |\
        awk -F '|' 'NF == 6 {print $NF}' |\
        grep -Eio "^$base_version[0-9\.\-]+$type$" |\
        sort --version-sort --reverse | head -n 1)

    if [ ${#sdk_version} -lt ${#new_version} ] || [[ $sdk_version < $new_version ]]; then
        echo -e "\b -> $new_version]"
        is_default=$(echo "$sdk_list" | grep '>>>' | grep -Eio "$sdk_version")

        if [ -n "$is_default" ]; then
            yes | sdk install java $new_version
        else
            yes n | sdk install java $new_version
        fi

        if [ $? -eq 0 ]; then
            sdk uninstall java $sdk_version
        else
            echo -n "Failed to install $new_version. Keeping $sdk_version"
        fi
    else
        echo -e "\b is up to date]"
    fi
done

sdk selfupdate
sdk flush
