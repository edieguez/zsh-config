ZSH_THEME="aya"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(
    extract
    fast-syntax-highlighting
    git
    sudo
    virtualenv_py
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

unset -f source_if_exist

# Build PATH (highest to lowest precedence):
# bin/local > bin/$PLATFORM > bin/ > CUSTOM_PATH > system PATH
typeset -a _bins
_bins=($ZSH_CUSTOM/bin/ $CUSTOM_PATH)
[[ $PLATFORM != "unknown" ]] && _bins=($ZSH_CUSTOM/bin/$PLATFORM $_bins)
_bins=($ZSH_CUSTOM/bin/local $_bins)
PATH="${(j[:])_bins}:$PATH"
unset _bins
