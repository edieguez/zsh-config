0x0() {
    if [ $# -lt 1 ]; then
        echo "Usage: 0x0 <file>"
        return 1
    fi

    echo "Uploading $1 to 0x0.st. Please wait..."
    curl -F "file=@$1" -Fsecret= https://0x0.st
}

gitlog() {
  git log \
    --oneline \
    --abbrev-commit \
    --color=always \
    --format="%C(auto)%h %<(10)%an %C(blue)%ad %C(green)%ar %C(auto)%s" \
    --date=format:'%d-%b-%Y %H:%M:%S' |
    fzf --ansi --preview "echo {} | awk '{print \$1}' | xargs -I % sh -c 'git show --color=always --stat % && git diff --color=always %~1 %'" |
    awk '{print $1}' | xargs -I % git show --color=always --stat %
}

google-translate() {
    trans en:es "$*"
}

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

# Load functions for local environment
source_if_exist "$ROOT_DIR/system/functions_local.sh"
