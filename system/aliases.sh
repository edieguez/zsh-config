# Drop-in replacements — only active when the modern tool is installed
(( $+commands[bat]  )) && alias cat='bat'
(( $+commands[lsd]  )) && alias ls='lsd --group-directories-first' ll='ls -lh' la='ls -lha' tree='ls -lh --tree --depth 3 2>/dev/null'
(( $+commands[nvim] )) && alias vi='nvim' vim='nvim'
(( $+commands[yt-dlp]  )) && alias youtube-dl='yt-dlp' youtube-dl-mp3='yt-dlp --add-metadata --extract-audio --audio-format mp3'

alias aria2c='aria2c --file-allocation=none --summary-interval=900'
alias dict='trans en:es -d'
alias ipv4='curl --silent -4 icanhazip.com'
alias ipv6='curl --silent -6 icanhazip.com'
alias leech='aria2c --seed-time=0'
alias lg=lazygit
alias mvn-sources='mvn dependency:sources dependency:resolve -Dclassifier=javadoc'
alias ping='ping -c4'
alias random-man='man $(find /usr/share/man/man1 -type f | shuf | head -1)'
