# Remove duplicates from history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# SDKMAN for managing JVM languages and tools
export SDKMAN_DIR="$HOME/.sdkman"

# NVM for managing Node.js versions
export NVM_DIR="$HOME/.nvm"
