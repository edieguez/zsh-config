0x0() {
    if [ $# -lt 1 ]; then
        echo "Usage: 0x0 <file>"
        return 1
    fi

    echo "Uploading $1 to 0x0.st. Please wait..."
    curl -F "file=@$1" -Fsecret= https://0x0.st
}

dropbox() {
    : ${DROPBOX_DIR=$HOME/Dropbox}
    : ${DROPBOX_REMOTE=Dropbox}
    rclone --verbose bisync "$DROPBOX_DIR" "$DROPBOX_REMOTE:" $@

    if [ $? -eq 0 ]; then
        notify-send -a "Dropbox" "Bisync $DROPBOX_DIR to $DROPBOX_REMOTE finished" -t 20000
    else
        notify-send -a "Dropbox" "Bisync $DROPBOX_DIR to $DROPBOX_REMOTE failed" -t 20000
        return 1
    fi
}

docker() {
    systemctl status docker.service | grep 'active (running)' > /dev/null
    [ $? -ne 0 ] && sudo systemctl start docker.service

    /usr/bin/docker $@
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

# Load functions for local environment
source_if_exist "$ROOT_DIR/system/functions_local.sh"
