# https://sdkman.io/install
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# https://bun.sh
[ -s "/opt/homebrew/share/zsh/site-functions/_bun" ] && source "/opt/homebrew/share/zsh/site-functions/_bun"

# Conditional plugin loading
(( $+commands[aws] )) && plugins+=(aws)
(( $+commands[git] )) && plugins+=(git)
(( $+commands[gradle] )) && plugins+=(gradle)
(( $+commands[mvn] )) && plugins+=(mvn)
[ -s "$GOROOT/bin/go" ] && plugins+=(golang) # Workaround

# Add nvm lazy load plugin if nvm is installed
if [ -d "$NVM_DIR" ]; then
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-nvm-lazy-load" ]; then
    echo "NVM is installed, adding zsh-nvm-lazy-load plugin..."
    git clone https://github.com/undg/zsh-nvm-lazy-load.git "$ZSH_CUSTOM/plugins/zsh-nvm-lazy-load"
  fi

  plugins+=(zsh-nvm-lazy-load)
fi

# Enable fzf plugin if available
# https://github.com/junegunn/fzf/discussions/3922
if (( $+commands[fzf] )); then
  plugins+=(fzf)

  # Build fd exclude options as an array
  local -a exclude_opts
  for dir in "${FZF_EXCLUDED_DIRS[@]}"; do
    exclude_opts+=(--exclude "$dir")
  done

  # Configure CTRL-T (file navigator) to show files, sorted
  export FZF_CTRL_T_COMMAND="fd --type f --hidden --no-ignore ${exclude_opts[*]} | sort -V"

  # Configure ALT-C (directory navigator) to show only directories, sorted
  export FZF_ALT_C_COMMAND="fd --type d --hidden ${exclude_opts[*]} | sort -V"

  # Trigger using COMMAND + ** + TAB for file completion
  _fzf_compgen_path() {
    fd --type f --hidden "${exclude_opts[@]}" | sort -V
  }

  # Trigger using cd + ** + TAB for directory completion
  _fzf_compgen_dir() {
    fd --type d --hidden --no-ignore "${exclude_opts[@]}" | sort -V
  }
fi
