#!/usr/bin/env bash
# Author  : Chad Mayfield (chad@chadmayfield.com)
# License : GPLv3
# setup macOS using Homebrew
# Ensure the script is running on Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    echo "This script is intended only for Apple Silicon Macs."
    exit 1
fi
# install rosetta on apple silicon
if [[ "$(sysctl -n machdep.cpu.brand_string)" == *'Apple'* ]]; then
  if [ ! -d "/usr/libexec/rosetta" ]; then
    echo "Installing Rosetta..."
    sudo softwareupdate --install-rosetta --agree-to-license
  fi
  # show our install history, we should have rosetta
  sudo softwareupdate --history
fi

# install xcode cli tools
command -v "xcode-select -p" >/dev/null 2>&1; has_xcode=1 || { has_xcode=0; }
if [ "$has_xcode" -eq 0 ]; then
  echo "Installing XCode CLI Tools..."
  sudo xcode-select --install
else
  # show path
  xcode-select -p
  # show version
  xcode-select --version
  # show compiler version
  gcc -v
  llvm-gcc -v
  clang -v
fi

# install homebrew
command -v brew >/dev/null 2>&1; has_brew=1 || { has_brew=0; }
if [ "$has_brew" -eq 0 ]; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # add 'brew --prefix' location to $PATH
  # https://applehelpwriter.com/2018/03/21/how-homebrew-invites-users-to-get-pwned/
  # https://www.n00py.io/2016/10/privilege-escalation-on-os-x-without-exploits/
  if [[ "$(sysctl -n machdep.cpu.brand_string)" == *'Apple'* ]]; then
      # Add Homebrew to your PATH in Zsh, Bash, and Fish
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' | source
    #echo 'export PATH=/opt/homebrew/bin:$PATH' >> /Users/${USER}/.bash_profile
    #echo 'export PATH=/opt/homebrew/sbin:$PATH' >> /Users/${USER}/.bash_profile
  else
    echo 'export PATH="/usr/local/sbin:$PATH"' >> /Users/${USER}/.bash_profile
  fi

  source /Users/${USER}/.bash_profile

  # turn off brew analytics
  brew analytics off
if

# update brew
brew update

# run brewfile to install packages
#brew bundle install

# check for issues
brew doctor

# set brew to update every 12 hours (in seconds)
brew autoupdate start 43200

# show brew auto update status for feedback
brew autoupdate status

# display outdated apps and auto-update status
brew cu --include-mas

# Update Homebrew and upgrade any already-installed formulae
brew update
brew upgrade

# Install pyenv
brew install pyenv
echo 'eval "$(pyenv init --path)"' >> ~/.zprofile
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'status is-login; and source (pyenv init -|psub)' >> ~/.config/fish/config.fish

# Install the latest stable Python version
LATEST_PYTHON=$(pyenv install -l | grep -v - | tail -1)
pyenv install $LATEST_PYTHON
pyenv global $LATEST_PYTHON

# Install pip
pyenv exec python -m ensurepip --upgrade

# Install rbenv
brew install rbenv
echo 'eval "$(rbenv init -)"' >> ~/.zprofile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
echo 'status is-login; and rbenv init - | source' >> ~/.config/fish/config.fish

# Install the latest stable Ruby version
LATEST_RUBY=$(rbenv install -l | grep -v - | tail -1)
rbenv install $LATEST_RUBY
rbenv global $LATEST_RUBY

# Install Node.js and npm using n
brew install n
n stable

# Install Yarn
brew install yarn

# Refresh shell environments
source ~/.zshrc
source ~/.bashrc
source ~/.config/fish/config.fish

echo "Installation complete. Please restart your terminal."
