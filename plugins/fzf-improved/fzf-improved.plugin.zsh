# Global display options applied to every fzf invocation.
# --height        open inline instead of full-screen
# --layout=reverse  prompt at the bottom, results above it
# --border        draw a border around the widget
export FZF_DEFAULT_OPTS='
  --height=60% --layout=reverse --border
'

# Directory names that fd will skip in Ctrl+T and Alt+C searches.
# Matching is by name at any depth — node_modules anywhere in the tree is excluded,
# not just at the root. To add entries without editing this file, append in
# system/environment.local.sh: FZF_EXCLUDED_DIRS+=(my-cache)
## Check if FZF_EXCLUDED_DIRS is already defined (e.g. in environment.local.sh) and append to it, otherwise initialize it.
if [[ -z "${FZF_EXCLUDED_DIRS+x}" ]]; then
  export FZF_EXCLUDED_DIRS=()
fi

FZF_EXCLUDED_DIRS+=(
  # Language/tool build and cache
  __pycache__ .angular .cache .mypy_cache .venv .next node_modules bower_components dist build out coverage target elm-stuff .cargo .pnp .pnp.js

  # Dev tools and metadata
  .vscode .idea .git .hg .svn .m2 .npm .nvm .sdkman terraform.tfstate.d

  # macOS system
  .DS_Store .AppleDouble .Spotlight-V100 .Trash .Trashes Library

  # Linux system
  lost+found .proc .sys .dev .run .var
)

# Expand FZF_EXCLUDED_DIRS into --exclude flags consumed by fd below.
typeset -ga _fzf_exclude_opts
for _fzf_dir in "${FZF_EXCLUDED_DIRS[@]}"; do
  _fzf_exclude_opts+=(--exclude "$_fzf_dir")
done
unset _fzf_dir
export FZF_EXCLUDE_OPTS="${_fzf_exclude_opts[*]}"

# Shared preview command: bat with syntax highlighting for files, lsd tree for dirs.
# Duplicated usage sites reference this variable so the command lives in one place.
_FZF_IMPROVED_PREVIEW='if [[ -d {} ]]; then lsd -lh --tree --depth 2 --color=always {} 2>/dev/null || ls -lh --color=always {}; elif command -v bat &>/dev/null; then bat --style=numbers,changes,header,grid --color=always --line-range :500 {}; else cat {}; fi'

# Clipboard command — pbcopy on macOS, xclip/xsel on Linux.
# Falls back to bat (styled output) then cat when no clipboard tool is found.
if command -v pbcopy &>/dev/null; then
  _FZF_COPY_CMD='pbcopy'
elif command -v xclip &>/dev/null; then
  _FZF_COPY_CMD='xclip -sel clip'
elif command -v xsel &>/dev/null; then
  _FZF_COPY_CMD='xsel --clipboard --input'
elif command -v bat &>/dev/null; then
  _FZF_COPY_CMD='bat'
else
  _FZF_COPY_CMD='cat'
fi

# Open command — open on macOS, xdg-open on Linux.
if command -v open &>/dev/null; then
  _FZF_OPEN_CMD='open'
elif command -v xdg-open &>/dev/null; then
  _FZF_OPEN_CMD='xdg-open'
else
  _FZF_OPEN_CMD=''
fi

# ctrl-e opens $EDITOR (terminal); alt-e opens $VISUAL (GUI) if set.
# ctrl-o opens selection with the system default app, then closes fzf.
_FZF_EDITOR_BIND='ctrl-e:become(${EDITOR:-vi} {+} </dev/tty >/dev/tty)'
_FZF_VISUAL_BIND='alt-e:become(${VISUAL:-${EDITOR:-vi}} {+})'
[[ -n "$_FZF_OPEN_CMD" ]] && _FZF_OPEN_BIND="ctrl-o:execute-silent(${_FZF_OPEN_CMD} {+})+abort" || _FZF_OPEN_BIND=''

# Shell helpers for transform: bindings. These run in a POSIX sh subshell spawned
# by fzf, so they are inlined as a string and eval'd at bind time — not zsh functions.
# All state is encoded in $FZF_PROMPT (e.g. "Files +hg> "), which fzf reliably exposes
# to transform: subshells after every change-prompt. No temp files, no header parsing.
export FZF_IMPROVED_HELPERS='
  # Emit reload+change-prompt fzf actions for given state.
  # $1=type(f|d) $2=hidden(0|1) $3=gitignored(0|1)
  _fzf_state_actions() {
    t=$1 hidden=$2 gi=$3
    h_flag="" ni_flag="" markers=""
    [ "$hidden" = "1" ] && { h_flag="--hidden ";         markers="${markers}h"; }
    [ "$gi" = "1" ]     && { ni_flag="--no-ignore-vcs "; markers="${markers}g"; }
    case $t in f) label=Files ;; *) label=Dirs ;; esac
    [ -n "$markers" ] && suffix=" +${markers}" || suffix=""
    printf "reload(fd --type %s --follow %s%s%s)+change-prompt(%s%s> )" \
      "$t" "$h_flag" "$ni_flag" "$FZF_EXCLUDE_OPTS" \
      "$label" "$suffix"
  }

  # Read state from $FZF_PROMPT, toggle one dimension, emit new actions.
  # Prompt format: "Files> " | "Files +h> " | "Files +g> " | "Files +hg> "
  # $1=toggle(mode|hidden|gitignored)
  _fzf_toggle() {
    toggle=$1
    case $FZF_PROMPT in Files*) t=f ;; *) t=d ;; esac
    hidden=0; gi=0
    case $FZF_PROMPT in *+h*">"*) hidden=1 ;; esac
    case $FZF_PROMPT in *+*g*">"*) gi=1 ;; esac
    case $toggle in
      mode)       [ "$t" = "f" ] && t=d || t=f ;;
      hidden)     [ "$hidden" = "1" ] && hidden=0 || hidden=1 ;;
      gitignored) [ "$gi" = "1" ] && gi=0 || gi=1 ;;
    esac
    _fzf_state_actions "$t" "$hidden" "$gi"
  }
'

# Ctrl+T — fuzzy file/directory finder.
export FZF_CTRL_T_COMMAND="fd --type f --follow ${_fzf_exclude_opts[*]}"
export FZF_CTRL_T_OPTS="
  --multi
  --prompt='Files> '
  --preview='${_FZF_IMPROVED_PREVIEW}'
  --preview-window=right:60%:wrap:border-left
  --bind='ctrl-]:transform:eval \"\$FZF_IMPROVED_HELPERS\"; _fzf_toggle hidden'
  --bind='ctrl-g:transform:eval \"\$FZF_IMPROVED_HELPERS\"; _fzf_toggle gitignored'
  --bind='ctrl-\\:transform:eval \"\$FZF_IMPROVED_HELPERS\"; _fzf_toggle mode'
  --bind='${_FZF_EDITOR_BIND}'
  --bind='${_FZF_VISUAL_BIND}'
  --bind='${_FZF_OPEN_BIND}'
  --bind='ctrl-y:become(printf %s \$(realpath {}) | ${_FZF_COPY_CMD})'
"

# Alt+C (Linux) / Esc+C (macOS) — fuzzy directory navigator.
# No files/dirs toggle here — Alt+C is dedicated to cd.
export FZF_ALT_C_COMMAND="fd --type d --follow ${_fzf_exclude_opts[*]}"
export FZF_ALT_C_OPTS="
  --prompt='Dirs> '
  --preview='lsd -lh --tree --depth 2 --color=always {} 2>/dev/null || ls -lh --color=always {}'
  --preview-window=right:60%:wrap:border-left
  --bind='ctrl-]:transform:eval \"\$FZF_IMPROVED_HELPERS\"; _fzf_toggle hidden'
  --bind='ctrl-g:transform:eval \"\$FZF_IMPROVED_HELPERS\"; _fzf_toggle gitignored'
  --bind='${_FZF_OPEN_BIND}'
  --bind='ctrl-y:become(printf %s \$(realpath {}) | ${_FZF_COPY_CMD})'
"

# Ctrl+R — history search.
# No preview because history entries are not file paths.
export FZF_CTRL_R_OPTS="--no-preview --scheme=history"

# ** tab completion preview.
# Auto-detects whether the candidate is a file (bat) or directory (lsd tree).
export FZF_COMPLETION_OPTS="
  --preview='${_FZF_IMPROVED_PREVIEW}'
  --preview-window=right:60%:wrap:border-left
"

# Candidate list for ** file completion.
# --hidden includes dotfiles. FZF_EXCLUDED_DIRS is applied for performance —
# traversing node_modules/.cargo/.git etc. makes completion unusably slow.
_fzf_compgen_path() {
  fd --type f --follow --no-ignore --hidden "${_fzf_exclude_opts[@]}"
}

# Candidate list for ** directory completion.
_fzf_compgen_dir() {
  fd --type d --follow --no-ignore --hidden "${_fzf_exclude_opts[@]}"
}
