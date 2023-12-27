() {
  # Color shortcuts
  CURRENT_DIR=$fg_bold[yellow]
  USER_AT_HOST=$fg_bold[green]
  SSH=$fg[red]
  ERROR_CODE=$fg[red]

  # Separators
  SEP_A=$fg[white]
  SEP_B=$fg[blue]

  BRANCH=$fg_bold[cyan]
  COMMIT=$fg[magenta]

  RESET_COLOR=$reset_color

  # Format for git_prompt_status()
  ZSH_THEME_GIT_PROMPT_UNMERGED="%F{magenta}%B?%b%f "
  ZSH_THEME_GIT_PROMPT_DELETED="%F{red}%B✖%b%f "
  ZSH_THEME_GIT_PROMPT_RENAMED="%F{yellow}%B➜%b%f "
  ZSH_THEME_GIT_PROMPT_MODIFIED="%F{blue}%B⚙%b%f "
  ZSH_THEME_GIT_PROMPT_ADDED="%F{green}%B✚%b%f "
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{white}%B✭%b%f "
  ZSH_THEME_GIT_PROMPT_AHEAD="%F{red}%B●%b%f "

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

# Prompt format
PROMPT="$(ssh_connection)%{$USER_AT_HOST%}%n@%m%{$SEP_A%}:%{$CURRENT_DIR%}%~${RETURN_CODE} %{$SEP_B%}>%{$RESET_COLOR%} "
RPROMPT='$(git_prompt_status)%{$BRANCH%}$(git_current_branch)$(git_prompt_short_sha)%{$RESET_COLOR%}'
