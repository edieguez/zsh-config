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

spf() {
  os=$(uname -s)

  # Linux
  if [[ "$os" == "Linux" ]]; then
    export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
  fi

  # macOS
  if [[ "$os" == "Darwin" ]]; then
    export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
  fi

  command spf "$@"

  [ ! -f "$SPF_LAST_DIR" ] || {
    . "$SPF_LAST_DIR"
    rm -f -- "$SPF_LAST_DIR" > /dev/null
  }
}

s() {spf}

y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}
