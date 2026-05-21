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

# Ctrl+T — fuzzy file finder.
export FZF_CTRL_T_COMMAND="fd --type f --follow ${_fzf_exclude_opts[*]}"
# Preview: bat with syntax highlighting, falls back to cat.
# Remove the bat branch to always use cat.
export FZF_CTRL_T_OPTS="
  --preview='if command -v bat &>/dev/null; then bat --style=numbers,changes,header,grid --color=always --line-range :500 {}; else cat {}; fi'
  --preview-window=right:60%:wrap:border-left
"

# Alt+C (Linux) / Esc+C (macOS) — fuzzy directory navigator.
export FZF_ALT_C_COMMAND="fd --type d --follow ${_fzf_exclude_opts[*]}"
# Preview: lsd tree, falls back to ls.
# Change --depth to control how many levels the tree shows.
export FZF_ALT_C_OPTS="
  --preview='lsd -lh --tree --depth 2 --color=always {} 2>/dev/null || ls -lh --color=always {}'
  --preview-window=right:60%:wrap:border-left
"

# Ctrl+R — history search.
# No preview because history entries are not file paths.
# Remove --no-preview to restore fzf's default preview behavior.
export FZF_CTRL_R_OPTS="--no-preview"

# ** tab completion preview.
# Auto-detects whether the candidate is a file (bat) or directory (lsd tree).
export FZF_COMPLETION_OPTS="
  --preview='if [[ -d {} ]]; then lsd -lh --tree --depth 2 --color=always {} 2>/dev/null || ls -lh --color=always {}; elif command -v bat &>/dev/null; then bat --style=numbers,changes,header,grid --color=always --line-range :500 {}; else cat {}; fi'
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
