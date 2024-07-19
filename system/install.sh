#! /usr/bin/env zsh
export ZSH_HOME="$HOME/.zsh"
export ZSH_CUSTOM="$ZSH_HOME/zsh-config"

mkdir -v $ZSH_HOME
pushd "$ZSH_HOME"

echo 'Cloning required repositories'
git clone https://github.com/ohmyzsh/ohmyzsh.git
git clone https://github.com/edieguez/zsh-config.git


# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

popd

echo 'Creating symbolic link for .zshrc'
ln -vsfn "$ZSH_CUSTOM/system/zshrc" "$HOME/.zshrc"

echo 'Done. Restart your shell to finish the setup'
