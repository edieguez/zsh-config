# Color shortcuts
RED=$fg[red]
YELLOW=$fg[yellow]
GREEN=$fg[green]
WHITE=$fg[white]
BLUE=$fg[blue]
RED_BOLD=$fg_bold[red]
YELLOW_BOLD=$fg_bold[yellow]
GREEN_BOLD=$fg_bold[green]
WHITE_BOLD=$fg_bold[white]
BLUE_BOLD=$fg_bold[blue]
RESET_COLOR=$reset_color

if [[ -n $SSH_CONNECTION ]]; then
    PROMPT="%{$RED_BOLD%}(ssh) "
else
    PROMPT=""
fi

return_code="%(?..%{$RED%}%? %{$RESET_COLOR%})"

# Prompt format
PROMPT+='%{$GREEN_BOLD%}%n@%m%{$WHITE%}:%{$YELLOW%}%~%u%{$RESET_COLOR%} ${return_code}%{$BLUE%}>%{$RESET_COLOR%} '
