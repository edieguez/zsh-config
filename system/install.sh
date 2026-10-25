#! /usr/bin/env zsh
set -e
export ZSH_HOME="$HOME/.zsh"
export ZSH_CUSTOM="$ZSH_HOME/zsh-config"

mkdir -pv $ZSH_HOME
pushd "$ZSH_HOME"

echo 'Cloning required repositories'
git clone https://github.com/ohmyzsh/ohmyzsh.git
git clone https://github.com/edieguez/zsh-config.git

# https://github.com/zdharma-continuum/fast-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting

popd

if [[ -e "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    echo 'Backing up existing .zshrc to .zshrc.bak'
    mv -v "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

echo 'Creating symbolic link for .zshrc'
ln -vsfn "$ZSH_CUSTOM/system/zshrc" "$HOME/.zshrc"

echo 'Done. Restart your shell to finish the setup'
