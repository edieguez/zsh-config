#!/usr/bin/env bash
cout() {
    format=$1; shift
    echo -en "[${format}m""$*""[0m"
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    cout "01;31" "❌ Homebrew is not installed. Please install it first.\n"
    exit 1
fi

# Ensure brew update and upgrade succeed
brew update || { cout "01;31" "❌ Failed to update Homebrew\n"; exit 1; }

cout "01;34" "⬆️ Updating packages and casks\n"
brew upgrade --greedy -y || { cout "01;31" "❌ Failed to upgrade Homebrew\n"; exit 1; }

cout "01;34" "🗑️ Cleaning up\n"
brew cleanup
