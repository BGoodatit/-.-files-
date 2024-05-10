#!/usr/bin/env bash
# Author  : Chad Mayfield (chad@chadmayfield.com)
# License : GPLv3
# Setup macOS using Homebrew
# Ensure the script is running on Apple Silicon

if [[ $(uname -m) != "arm64" ]]; then
    echo "This script is intended only for Apple Silicon Macs."
    exit 1
fi

# Install Rosetta on Apple Silicon if needed
if [[ "$(sysctl -n machdep.cpu.brand_string)" == *'Apple'* && ! -d "/usr/libexec/rosetta" ]]; then
    echo "Installing Rosetta..."
    sudo softwareupdate --install-rosetta --agree-to-license
    # Show our install history, we should have Rosetta
    sudo softwareupdate --history
fi

# Install XCode CLI tools if not installed
if ! xcode-select -p &>/dev/null; then
    echo "Installing XCode CLI Tools..."
    sudo xcode-select --install
else
    # Show path, version, and compiler version
    xcode-select -p
    xcode-select --version
    gcc -v
    clang -v
fi

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Configure shell environment for Homebrew
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' | source
    source ~/.bash_profile
fi

# Disable Homebrew analytics
brew analytics off

# Update Homebrew and all installed packages
brew update
brew upgrade

# Install rbenv and Ruby, and set global version
brew install rbenv
# Initialize rbenv
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zprofile
source ~/.bash_profile # Refresh shell settings

# Install the latest stable version of Ruby
latest_ruby=$(rbenv install -l | grep -v - | tail -1) # Automatically fetches the latest stable version
echo "Installing Ruby version $latest_ruby..."
rbenv install $latest_ruby
rbenv global $latest_ruby

# Install pyenv, Python, and set global version
brew install pyenv
latest_python=$(pyenv install -l | grep -v - | grep -v b | tail -1)
pyenv install $latest_python
pyenv global $latest_python
echo 'eval "$(pyenv init --path)"' >> ~/.zprofile
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'status is-login; and source (pyenv init -|psub)' >> ~/.config/fish/config.fish

# Install Node.js and npm using n
brew install n
n stable

# Install Yarn
brew install yarn

# Set Homebrew to update automatically every 12 hours
brew autoupdate start 43200

# Refresh shell environments
source ~/.zshrc
source ~/.bashrc
source ~/.config/fish/config.fish

echo "Installation complete. Please restart your terminal."
