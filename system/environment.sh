# Remove duplicates from history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Rust configuration
export RUST_HOME="/opt/rust"
export CARGO_HOME="$RUST_HOME/cargo"
export RUSTUP_HOME="$RUST_HOME/rustup"

# Go configuration
export GOROOT="/opt/go"
export GOPATH="$GOROOT/gopath"

export SDKMAN_DIR="$HOME/.sdkman"

PATH="$ZSH_CUSTOM/bin/local:$ZSH_CUSTOM/bin/:$CARGO_HOME/bin:$GOROOT/bin:$GOPATH/bin:$PATH"

# Add custom bin directories based on OS
if [[ $(uname) == "Darwin" ]]; then
  PATH="$ZSH_CUSTOM/bin/macos:$PATH"
elif [[ $(uname) == "Linux" ]]; then
  PATH="$ZSH_CUSTOM/bin/linux:$PATH"
fi
