# Declare your MacOS related environment variables here
# Fix for NVM not working when being install with Homebrew
if [[ -s /opt/homebrew/opt/nvm/nvm.sh ]]; then
  [[ -d "$HOME/.nvm" ]] || mkdir -p "$HOME/.nvm"
  [[ -s "$HOME/.nvm/nvm.sh" ]] || ln -sf /opt/homebrew/opt/nvm/nvm.sh "$HOME/.nvm/nvm.sh"
  if [[ -s /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm && ! -s "$HOME/.nvm/bash_completion" ]]; then
    ln -sf /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm "$HOME/.nvm/bash_completion"
  fi
fi
