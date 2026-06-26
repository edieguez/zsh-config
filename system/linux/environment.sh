# Declare your Linux related environment variables here
# Rust configuration
export RUST_HOME="/opt/rust"
export CARGO_HOME="$RUST_HOME/cargo"
export RUSTUP_HOME="$RUST_HOME/rustup"

# Go configuration
export GOROOT="/opt/go"
export GOPATH="$GOROOT/gopath"

export CUSTOM_PATH="$CARGO_HOME/bin:$GOROOT/bin:$GOPATH/bin"
