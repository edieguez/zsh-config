() {
  CURRENT_DIR=$fg_bold[yellow]
  USER_AT_HOST=$fg_bold[green]
  SSH=$fg_bold[red]
  ERROR_CODE=$fg_bold[red]
  SEP_A=$fg_bold[white]
  SEP_B=$fg_bold[blue]
  BRANCH=$fg_bold[cyan]
  COMMIT=$fg_bold[magenta]
  RESET_COLOR=$reset_color

  ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{245}%B?%b%f "
  ZSH_THEME_GIT_PROMPT_ADDED="%F{cyan}%B+%b%f "
  ZSH_THEME_GIT_PROMPT_MODIFIED="%F{yellow}%B~%b%f "
  ZSH_THEME_GIT_PROMPT_RENAMED="%F{blue}%B→%b%f "
  ZSH_THEME_GIT_PROMPT_DELETED="%F{red}%B✕%b%f "
  ZSH_THEME_GIT_PROMPT_UNMERGED="%F{208}%B≠%b%f "
  ZSH_THEME_GIT_PROMPT_DIVERGED="%F{141}%B⇕%b%f "
  ZSH_THEME_GIT_PROMPT_STASHED="%F{magenta}%B⚑%b%f "

  ZSH_THEME_GIT_PROMPT_SHA_BEFORE=" %{$SEP_A%}[%{$COMMIT%}"
  ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$SEP_A%}]"

  RETURN_CODE="%(?..%{$ERROR_CODE%} %?)"
}

ssh_connection() {
  [[ -n $SSH_CONNECTION ]] && echo -n "%{$SSH%}(ssh) "
}

# Excludes staged-only modifications from MODIFIED — covered separately by git_staged_status.
git_prompt_status() {
  local output
  output=$(_omz_git_prompt_status)
  git diff --quiet 2>/dev/null && output=${output//$ZSH_THEME_GIT_PROMPT_MODIFIED/}
  echo -n $output
}

git_staged_status() {
  git rev-parse --git-dir &>/dev/null || return
  git diff --cached --quiet 2>/dev/null || echo -n "%B%F{green}✔%f%b "
}

git_sync_status() {
  local counts behind ahead
  counts=$(git rev-list --count --left-right @{u}...HEAD 2>/dev/null) || return
  behind=${counts%%$'\t'*}
  ahead=${counts##*$'\t'}
  (( behind > 0 )) && echo -n "%B%F{245}↓${behind}%f%b "
  (( ahead > 0 )) && echo -n "%B%F{208}↑${ahead}%f%b "
}

PROMPT="$(ssh_connection)%{$USER_AT_HOST%}%n@%m%{$SEP_A%}:%{$CURRENT_DIR%}%~${RETURN_CODE} %{$SEP_B%}>%{$RESET_COLOR%} "

_aya_git_rprompt() {
  git rev-parse --git-dir &>/dev/null || return
  echo -n "$(git_sync_status)$(git_staged_status)$(git_prompt_status)%{$BRANCH%}$(git_current_branch)$(git_prompt_short_sha)%{$RESET_COLOR%}"
}

_aya_async_callback() {
  local fd=$1
  RPROMPT="$(cat <&$fd)"
  exec {fd}<&-
  _aya_async_fd=
  zle reset-prompt
}

_aya_precmd() {
  if (( _aya_async_fd > 0 )); then
    zle -F $_aya_async_fd 2>/dev/null
    exec {_aya_async_fd}<&-
  fi
  RPROMPT=
  exec {_aya_async_fd}< <(_aya_git_rprompt)
  (( _aya_async_fd > 0 )) && zle -F $_aya_async_fd _aya_async_callback
}

precmd_functions+=(_aya_precmd)
