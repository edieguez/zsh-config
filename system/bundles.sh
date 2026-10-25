# https://sdkman.io/install
# Lazy-load SDKMAN: defer sourcing the slow init script until first use of `sdk`
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  sdk() {
    unfunction sdk
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
  }
fi

# Conditional plugin loading (git is always on, see init.sh)
(( $+commands[aws] )) && plugins+=(aws)
(( $+commands[go] )) && plugins+=(golang)
(( $+commands[gradle] )) && plugins+=(gradle)
(( $+commands[mvn] )) && plugins+=(mvn)
(( $+commands[rustc] )) && plugins+=(rust)
(( $+commands[zoxide] )) && { plugins+=(zoxide); export ZOXIDE_CMD_OVERRIDE=cd } || plugins+=(z)

# Add nvm lazy load plugin if nvm is installed.
# Only enable the plugin once its clone exists, so an offline first run does not warn on every start.
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"

  if [ -d "$ZSH_CUSTOM/plugins/zsh-nvm-lazy-load" ] ||
     { echo "NVM is installed, adding zsh-nvm-lazy-load plugin..." &&
       git clone https://github.com/undg/zsh-nvm-lazy-load.git "$ZSH_CUSTOM/plugins/zsh-nvm-lazy-load"; }; then
    plugins+=(zsh-nvm-lazy-load)
  fi
fi

(( $+commands[fzf] )) && plugins+=(fzf-improved fzf)
