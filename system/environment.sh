# Remove duplicates from history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

CUSTOM_PATH=()
CUSTOM_FPATH=()

# SDKMAN for managing JVM languages and tools
if [ -d "$HOME/.sdkman" ]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  CUSTOM_PATH+=(
    "$SDKMAN_DIR/candidates/java/current/bin"
    "$SDKMAN_DIR/candidates/maven/current/bin"
  )
fi
