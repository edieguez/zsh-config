# Remove duplicates from history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# PATH customization
# export JAVA_HOME="$HOME/.current_jdk"
# export CUSTOM_PATH="$JAVA_HOME/bin"

# Rust configuration
export RUST_HOME=/opt/rust
export CARGO_HOME=$RUST_HOME/cargo
export RUSTUP_HOME=$RUST_HOME/rustup

# Go configuration
export GOROOT=/opt/go
export GOPATH=$GOROOT/gopath

export SDKMAN_DIR="$HOME/.sdkman"

export CUSTOM_PATH="$CARGO_HOME/bin:$GOROOT/bin:$GOPATH/bin"
