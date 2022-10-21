alias browse-installed-packages="yay -Qq | fzf --preview 'yay -Qil {}' --layout=reverse --bind 'enter:execute(yay -Qil {} | less)'"
alias browse-known-packages="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse"
alias dict='trans en:es -d'
alias lg=lazygit
alias random-man='man $(find /usr/share/man/man1 -type f | shuf | head -1)'
alias youtube-dl-mp3='youtube-dl --add-metadata --extract-audio --audio-format mp3'

# Load aliases for local environment
source_if_exist "$ROOT_DIR/system/aliases_local.sh"
