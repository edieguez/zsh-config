ZSH_THEME="aya"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(
    extract
    fast-syntax-highlighting
    git
    sudo
    virtualenv_py
    z
)

source_if_exist() {
    if [ -e $1 ]; then
        source $1
    fi
}

declare PLATFORM

if [[ $(uname) == "Darwin" ]]; then
    PLATFORM="macos"
elif [[ $(uname) == "Linux" ]]; then
    PLATFORM="linux"
else
    PLATFORM="unknown"
fi

source "$ZSH_CUSTOM/system/environment.sh"
source_if_exist "$ZSH_CUSTOM/system/$PLATFORM/environment.sh"
source_if_exist "$ZSH_CUSTOM/system/environment.local.sh"

source "$ZSH_CUSTOM/system/bundles.sh"
source_if_exist "$ZSH_CUSTOM/system/$PLATFORM/bundles.sh"
source_if_exist "$ZSH_CUSTOM/system/bundles.local.sh"

# Load Oh my ZSH
source $OH_MY_ZSH/oh-my-zsh.sh

source "$ZSH_CUSTOM/system/aliases.sh"
source_if_exist "$ZSH_CUSTOM/system/$PLATFORM/aliases.sh"
source_if_exist "$ZSH_CUSTOM/system/aliases.local.sh"

source "$ZSH_CUSTOM/system/functions.sh"
source_if_exist "$ZSH_CUSTOM/system/$PLATFORM/functions.sh"
source_if_exist "$ZSH_CUSTOM/system/functions.local.sh"

# Fourth highest precedency: bin directories in CUSTOM_PATH
# Third highest precedency: binaries in ZSH_CUSTOM/bin
PATH="$ZSH_CUSTOM/bin/:$CUSTOM_PATH:$PATH"

# Second precedency: directories based on OS
if [[ $PLATFORM != "unknown" ]]; then
    PATH="$ZSH_CUSTOM/bin/$PLATFORM:$PATH"
fi

# Highest precedency: binaries in local directory
PATH="$ZSH_CUSTOM/bin/local:$PATH"
