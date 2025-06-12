# Remove duplicates from history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Simple preview at the right using bat. Fallback to cat if bat is not installed
export FZF_DEFAULT_OPTS='
  --height=60% --layout=reverse --border
  --preview="if [[ -d {} ]]; then ls -lAh --color=always {}; elif command -v bat &>/dev/null; then bat --style=numbers,changes --color=always --line-range :500 {}; else cat {}; fi"
  --preview-window=right:50%:wrap
'
export FZF_EXCLUDED_DIRS=(
  # Language/tool build and cache
  __pycache__ .angular .cache .mypy_cache .venv .next node_modules bower_components dist build out coverage target elm-stuff .cargo .pnp .pnp.js

  # Dev tools and metadata
  .vscode .idea .git .hg .svn .m2 .npm .nvm .sdkman terraform.tfstate.d

  # macOS system
  .DS_Store .AppleDouble .Spotlight-V100 .Trash .Trashes Library

  # Linux system
  lost+found .proc .sys .dev .run .var
)

# Rust configuration
export RUST_HOME="/opt/rust"
export CARGO_HOME="$RUST_HOME/cargo"
export RUSTUP_HOME="$RUST_HOME/rustup"

# Go configuration
export GOROOT="/opt/go"
export GOPATH="$GOROOT/gopath"

# SDKMAN for managing JVM languages and tools
export SDKMAN_DIR="$HOME/.sdkman"

# NVM for managing Node.js versions
export NVM_DIR="$HOME/.nvm"

export CUSTOM_PATH="$CARGO_HOME/bin:$GOROOT/bin:$GOPATH/bin"
