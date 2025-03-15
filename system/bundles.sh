# https://sdkman.io/install
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Conditional plugin loading
(( $+commands[aws] )) && plugins+=(aws)
(( $+commands[fzf] )) && plugins+=(fzf)
(( $+commands[git] )) && plugins+=(git)
(( $+commands[go] )) && plugins+=(golang)
(( $+commands[gradle] )) && plugins+=(gradle)
(( $+commands[mvn] )) && plugins+=(mvn)
