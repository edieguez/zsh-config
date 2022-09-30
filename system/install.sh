#! /usr/bin/env zsh
export ZSH_HOME="$HOME/.zsh"

pushd "$ZSH_HOME"

echo 'Cloning required repositories'
git clone git@github.com:ohmyzsh/ohmyzsh.git
git@github.com:edieguez/zsh-config.git


export OH_MY_ZSH="$ZSH_HOME/ohmyzsh"
export ZSH_CUSTOM="$ZSH_HOME/zsh-config"

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

popd

echo 'Creating symbolic link for .zshrc'
ln -vsfn $HOME/.zsh-config/system/zshrc $HOME/.zshrc

echo 'Done. Restart your shell to finish the setup'
