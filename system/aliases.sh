alias aria2c='aria2c --file-allocation=none --summary-interval=900'
alias browse-installed-packages="yay -Qq | fzf --preview 'yay -Qil {}' --layout=reverse --bind 'enter:execute(yay -Qil {} | less)'"
alias browse-known-packages="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse"
alias dict='trans en:es -d'
alias gitgraph="git log --graph --format='format:%C(yellow)%h%C(reset) %s %C(magenta)%cr%C(reset)%C(auto)%d%C(reset)'"
alias ipv4='curl --silent -4 icanhazip.com'
alias ipv6='curl --silent -6 icanhazip.com'
alias leech='aria2c --seed-time=0'
alias lg=lazygit
alias mvn-sources='mvn dependency:sources dependency:resolve -Dclassifier=javadoc'
alias ping='ping -c4'
alias random-man='man $(find /usr/share/man/man1 -type f | shuf | head -1)'
alias youtube-dl-mp3='youtube-dl --add-metadata --extract-audio --audio-format mp3'
alias youtube-dl='yt-dlp'

# Load aliases for local environment
source_if_exist "$ROOT_DIR/system/aliases_local.sh"
