() {
  # Color shortcuts
  CURRENT_DIR=$fg_bold[yellow]
  USER_AT_HOST=$fg_bold[green]
  SSH=$fg_bold[red]
  ERROR_CODE=$fg_bold[red]

  # Separators
  SEP_A=$fg_bold[white]
  SEP_B=$fg_bold[blue]

  BRANCH=$fg_bold[cyan]
  COMMIT=$fg_bold[magenta]

  RESET_COLOR=$reset_color

  # Format for git_prompt_status()
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{white}%B✭%b%f "
  ZSH_THEME_GIT_PROMPT_ADDED="%F{green}%B✚%b%f "
  ZSH_THEME_GIT_PROMPT_MODIFIED="%F{yellow}%B~%b%f "
  ZSH_THEME_GIT_PROMPT_RENAMED="%F{cyan}%B➜%b%f "
  ZSH_THEME_GIT_PROMPT_DELETED="%F{red}%B✖%b%f "
  ZSH_THEME_GIT_PROMPT_UNMERGED="%F{magenta}%B!%b%f "
  ZSH_THEME_GIT_PROMPT_DIVERGED="%F{141}%B↕%b%f "
  ZSH_THEME_GIT_PROMPT_STASHED="%F{blue}%B⚑%b%f "

  # Format for git_prompt_long_sha() and git_prompt_short_sha()
  ZSH_THEME_GIT_PROMPT_SHA_BEFORE=" %{$SEP_A%}[%{$COMMIT%}"
  ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$SEP_A%}]"

  RETURN_CODE="%(?..%{$ERROR_CODE%} %?)"
}

ssh_connection() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo -n "%{$SSH%}(ssh) "
  fi
}

git_sync_status() {
  local counts behind ahead
  counts=$(git rev-list --count --left-right @{u}...HEAD 2>/dev/null) || return
  behind=${counts%%$'\t'*}
  ahead=${counts##*$'\t'}
  (( behind > 0 )) && echo -n "%B%F{245}↓${behind}%f%b "
  (( ahead > 0 )) && echo -n "%B%F{208}↑${ahead}%f%b "
}

# Prompt segments
_aya_ssh="$(ssh_connection)"
_aya_user_host="%{$USER_AT_HOST%}%n@%m"
_aya_path="%{$CURRENT_DIR%}%~"
_aya_arrow="%{$SEP_B%}>%{$RESET_COLOR%}"

# Prompt format
PROMPT="${_aya_ssh}${_aya_user_host}%{$SEP_A%}:${_aya_path}${RETURN_CODE} ${_aya_arrow} "
RPROMPT='$(git_sync_status)$(git_prompt_status)%{$BRANCH%}$(git_current_branch)$(git_prompt_short_sha)%{$RESET_COLOR%}'
