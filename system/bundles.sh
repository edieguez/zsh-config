# https://sdkman.io/install
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Conditional plugin loading
(( $+commands[aws] )) && plugins+=(aws)
(( $+commands[git] )) && plugins+=(git)
(( $+commands[go] )) && plugins+=(golang)
(( $+commands[gradle] )) && plugins+=(gradle)
(( $+commands[mvn] )) && plugins+=(mvn)

plugins+=(fzf)

if [ $+commands[fzf] ]; then
  plugins+=(fzf)

  # FZF "**" command syntax
  # https://github.com/junegunn/fzf/discussions/3922
  _fzf_compgen_path() {
    fd --type f --hidden --no-ignore \
      --exclude Library \
      --exclude .git
  }
fi
