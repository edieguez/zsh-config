n() {
    local command="$1"
    shift

    # Scape arguments to avoid problems with quotes
    local arguments
    printf -v arguments "%q " "${@[@]}"

    eval "$command $arguments"

    local exit_code=$?

    if type -p notify-send > /dev/null; then
        if [ $exit_code -eq 0 ]; then
            notify-send --app-name "$command" --expire-time 15000 --icon "dialog-ok" "$command ${arguments}executed successfully"

            if type -p paplay > /dev/null; then
                paplay /usr/share/sounds/freedesktop/stereo/complete.oga &> /dev/null
            fi
        else
            notify-send --app-name "$command" --expire-time 15000 --icon "dialog-error" "$command ${arguments}executed with errors [$exit_code]"

            if type -p paplay > /dev/null; then
                paplay /usr/share/sounds/freedesktop/stereo/dialog-error.oga &> /dev/null
            fi
        fi
    else
        tput bel
    fi

    return $exit_code
}
