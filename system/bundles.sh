# https://sdkman.io/install
# Lazy-load SDKMAN: defer sourcing the slow init script until first use of `sdk`
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  sdk() {
    unfunction sdk
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
  }
fi

# Conditional plugin loading
(( $+commands[aws] )) && plugins+=(aws)
(( $+commands[git] )) && plugins+=(git)
(( $+commands[gradle] )) && plugins+=(gradle)
(( $+commands[mvn] )) && plugins+=(mvn)
(( $+commands[go] )) && plugins+=(golang)
(( $+commands[rustc] )) && plugins+=(rust)

# Add nvm lazy load plugin if nvm is installed
if [ -d "$NVM_DIR" ]; then
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-nvm-lazy-load" ]; then
    echo "NVM is installed, adding zsh-nvm-lazy-load plugin..."
    git clone https://github.com/undg/zsh-nvm-lazy-load.git "$ZSH_CUSTOM/plugins/zsh-nvm-lazy-load"
  fi

  plugins+=(zsh-nvm-lazy-load)
fi

(( $+commands[fzf] )) && plugins+=(fzf-improved fzf)
