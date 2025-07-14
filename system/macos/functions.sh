n() {
    local command="$1"
    shift

    # Scape arguments to avoid problems with quotes
    local arguments
    printf -v arguments "%q " "${@[@]}"

    eval "$command $arguments"

    local exit_code=$?

    if type -p terminal-notifier > /dev/null; then
        if [ $exit_code -eq 0 ]; then
            terminal-notifier -title "$command" -message "$command ${arguments}executed successfully" -appIcon "Terminal" -sound "Purr"
        else
            terminal-notifier -title "$command" -message "$command ${arguments}executed with errors [$exit_code]" -appIcon "Terminal" -sound "Basso"
        fi
    elif type -p osascript > /dev/null; then
        if [ $exit_code -eq 0 ]; then
            osascript -e "display notification \"$command ${arguments}executed successfully\" with title \"$command\" sound name \"Purr\""
        else
            osascript -e "display notification \"$command ${arguments}executed with errors [$exit_code]\" with title \"$command\" sound name \"Basso\""
        fi
    else
        tput bel
    fi

    return $exit_code
}
