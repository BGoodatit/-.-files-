#!/usr/bin/env zsh
# shellcheck shell=bash

################################################################################
# bootstrap
#
# This script is intended to set up a new Mac computer with my homefiles and
# other preferences.
################################################################################

# Thank you, thoughtbot!
bootstrap_echo() {
  local fmt="$1"
  shift
  # shellcheck disable=SC2059
  printf "\\n[INFO] $fmt\\n" "$@"
}

bootstrap_error() {
  local fmt="$1"
  shift
  # shellcheck disable=SC2059
  printf "\\n[ERROR] $fmt\\n" "$@"
  exit 1
}

bootstrap_done() {
  bootstrap_echo "Step $1 \\e[0;32m[✔]\\e[0m"
}

################################################################################
# VARIABLE DECLARATIONS
################################################################################

step='1'
DEFAULT_TIME_ZONE="America/New_York"
ACTUAL_COMPUTER_NAME="Hackbook"
HOMEBREW_PREFIX="/opt/homebrew"
GATEKEEPER_DISABLE="Yes"
MACOS_DEFAULT_URL="https://raw.githubusercontent.com/BGoodatit/.dotfiles/main/.macos"
DEFAULT_PASSPHRASE="P0ptartSpaceD0g"
QUIET=false

while getopts ":q" opts; do
  case "${opts}" in
    q)
      QUIET=true
      ;;
    *)
      bootstrap_error "unknown option -${OPTARG}"
      ;;
  esac
done

################################################################################
# Make sure we're on a Mac before continuing
################################################################################
if [ "$(uname)" != "Darwin" ]; then
  bootstrap_error "Oops, it looks like you're using a non-Darwin system. This script
only supports macOS. Exiting..."
fi

################################################################################
# Welcome and setup
################################################################################

printf '\n'
printf '************************************************************************\n'
printf '*******                                                           ******\n'
printf '*******                 Welcome to Mac Bootstrap!                 ******\n'
printf '*******                                                           ******\n'
printf '************************************************************************\n'
printf '\n'

# Authenticate
if ! sudo -nv &> /dev/null; then
  printf 'Before we get started, we need to have sudo access\n'
  printf 'Enter your password (for sudo access):\n'
  sudo /usr/bin/true
  # Keep-alive: update existing `sudo` time stamp until bootstrap has finished
  while true; do
    sudo -n /usr/bin/true
    sleep 60
    kill -0 "$$" || exit
  done 2> /dev/null &
fi

set -e

################################################################################
# Set the timezone
################################################################################
bootstrap_echo "Step $step: Set the timezone to $TIME_ZONE"
sudo systemsetup -settimezone "$TIME_ZONE" > /dev/null
bootstrap_done "$((step++))"

################################################################################
# Set computer name
################################################################################
bootstrap_echo "Step $step: Set computer name to $COMPUTER_NAME"
if [ "$COMPUTER_NAME" != "$ACTUAL_COMPUTER_NAME" ]; then
  sudo scutil --set ComputerName "$COMPUTER_NAME"
  sudo scutil --set HostName "$COMPUTER_NAME"
  sudo scutil --set LocalHostName "$COMPUTER_NAME"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
fi
bootstrap_done "$((step++))"

################################################################################
# Install Apple's Command Line Tools
################################################################################
bootstrap_echo "Step $step: Ensuring Apple's command line tools are installed"
if command -v xcode-select >&- && xpath=$(xcode-select --print-path) \
  && test -d "${xpath}" && test -x "${xpath}"; then
  bootstrap_echo "Apple's command line tools are already installed."
else
  bootstrap_echo "Installing Apple's command line tools"
  xcode-select --install
  while ! command -v xcode-select >&-; do
    sleep 60
  done
fi
bootstrap_done "$((step++))"

################################################################################
# Gatekeeper
################################################################################
bootstrap_echo "Step $step: Disable or enable Gatekeeper control"
if [[ $GATEKEEPER_DISABLE == "Yes" ]]; then
  sudo spctl --master-disable
else
  sudo spctl --master-enable
fi
bootstrap_done "$((step++))"

################################################################################
# Homebrew
################################################################################
bootstrap_echo "Step $step: Ensuring Homebrew is installed and updated"
if [ -d "$HOMEBREW_PREFIX" ]; then
  if ! [ -r "$HOMEBREW_PREFIX" ]; then
    sudo chown -vR "$(whoami):admin" $HOMEBREW_PREFIX
  fi
else
  sudo mkdir "$HOMEBREW_PREFIX"
  sudo chflags norestricted "$HOMEBREW_PREFIX"
  sudo chown -vR "$(whoami):admin" "$HOMEBREW_PREFIX"
fi
if ! command -v brew > /dev/null; then
  bootstrap_echo "Installing Homebrew"
  zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  export PATH="/usr/local/bin:$PATH"
fi
brew update
bootstrap_done "$((step++))"
################################################################################
bootstrap_echo "Step $step: Disable Homebrew analytics"
if [ "$(brew analytics)" != "Analytics are disabled." ]; then
  brew analytics off
fi
bootstrap_done "$((step++))"

################################################################################
# Install Brewfile
################################################################################
bootstrap_echo "Step $step: Installing dependencies from Brewfile"
curl -fsSL https://raw.githubusercontent.com/BGoodatit/homebrew-brewfile/main/Brewfile -o /tmp/Brewfile
brew bundle --file=/tmp/Brewfile
rm /tmp/Brewfile
bootstrap_done "$((step++))"

################################################################################
# zsh plugin
################################################################################
bootstrap_echo "Step $step: Install or upgrade zsh plugin"
if ! [ -f ~/.config/powerlevel10k/powerlevel10k.zsh-theme ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/powerlevel10k
  echo 'source ~/.config/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
fi
brew bundle --file=- <<EOF
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
EOF
bootstrap_done "$((step++))"

################################################################################
# Install dotfiles
################################################################################
bootstrap_echo "Step $step: Install or upgrade and then reload dotfiles"
if [ ! -d "$HOME/.cfg/" ]; then
  curl -fsSOk https://bitbucket.org/!api/2.0/snippets/deild/Gr7nX9/c752be0b868270dbda0959e845eabfa59995c5ce/files/home-cfg.sh | bash
else
  git --git-dir="$HOME/.cfg/" --work-tree="$HOME" checkout
fi
bootstrap_done "$((step++))"

################################################################################
# Ruby
################################################################################
bootstrap_echo "Step $step: Check which Ruby and Gem installs we are using at this point"
bootstrap_echo 'Ruby:    [%s]\n'  "$(command -v ruby);$(ruby -v)"
bootstrap_echo 'Gem:     [%s]\n'  "$(command -v gem);$(gem -v)"
gem update --system --quiet
number_of_cores=$(sysctl -n hw.ncpu)
bundle config --global jobs $((number_of_cores - 1))
bootstrap_done "$((step++))"

###############################################################################
bootstrap_echo "Step $step: Generate ed25519 and RSA key"
if ! $QUIET; then
  [ ! -f ~/.ssh/id_ed25519 ] && ssh-keygen -t ed25519 -a 100 -q -N "$PASSPHRASE"
  [ ! -f ~/.ssh/id_rsa ] && ssh-keygen -t rsa -b 4096 -o -a 100 -q -N "$PASSPHRASE"
else
  [ ! -f ~/.ssh/id_ed25519 ] && ssh-keygen -t ed25519 -a 100 -q -N "$PASSPHRASE" -f ~/.ssh/id_ed25519
  [ ! -f ~/.ssh/id_rsa ] && ssh-keygen -t rsa -b 4096 -o -a 100 -q -N "$PASSPHRASE" -f ~/.ssh/id_rsa
fi
bootstrap_done "$((step++))"

###############################################################################
bootstrap_echo "Step $step: Prefer tools installed by Homebrew according to the PATH environment variable"
UB_POS=$(echo "$PATH" | awk '{print index($1, "/usr/bin")}')
ULB_POS=$(echo "$PATH" | awk '{print index($1, "/usr/local/bin")}')
if [ ! "$ULB_POS" -eq "0" ] && [ ! "$ULB_POS" -gt "$UB_POS" ]; then
  PATH="/usr/local/bin:${PATH//:\/usr\/local\/bin:/:}"
  export PATH
fi
bootstrap_done "$((step++))"

################################################################################
# Set macOS preferences
################################################################################
bootstrap_echo "Step $step: Set macOS preferences"
if [[ $MACOS_URL =~ ^http ]]; then
  bootstrap_echo "Load from url $MACOS_DEFAULT_URL"
  curl -fsSL "$MACOS_URL" | zsh
else
  bootstrap_echo "Load from local file $MACOS_URL"
  [ -f "$MACOS_URL" ] && zsh "$MACOS_URL"
fi
bootstrap_done "$((step++))"

################################################################################
# End
################################################################################

printf '\n'
printf '************************************************************************\n'
printf '****                                                              ******\n'
printf '**** Mac Bootstrap complete! Please restart your computer.        ******\n'
printf '****                                                              ******\n'
printf '************************************************************************\n'
printf '\n'
# vim:syntax=sh:filetype=sh
