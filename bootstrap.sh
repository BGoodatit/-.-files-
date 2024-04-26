################################################################################
# Set the timezone; see `sudo systemsetup -listtimezones` for other values
################################################################################
bootstrap_echo "Step $step: Set the timezone to $TIME_ZONE"
sudo systemsetup -settimezone "$TIME_ZONE" > /dev/null
bootstrap_done "$((step++))"

################################################################################
# Set computer name (as done via System Preferences → Sharing)
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
# Checks if path to command line tools exist
if command -v xcode-select >&- && xpath=$(xcode-select --print-path) \
  && test -d "${xpath}" && test -x "${xpath}"; then
  bootstrap_echo "Apple's command line tools are already installed."
else
  bootstrap_echo "Installing Apple's command line tools"
  xcode-select --install
  while ! command -v xcode-select >&-; do
    sleep   60
  done
fi
bootstrap_done "$((step++))"

################################################################################
# Gatekeeper
################################################################################
bootstrap_echo "Step $step: Disable or enable Gatekeeper control"
if [[ $GATEKEEPER_DISABLE =~ Yes    ]]; then
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

###############################################################################
# Download Rustup and install Rust
if ! command -v rustup; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
cargo install -q -- cargo-outdated
cargo install -q -- cargo-release

###############################################################################
# Homebrew formula
###############################################################################
bootstrap_echo "Step $step: Install or upgrade formula dependencies"

brew tap "homebrew/bundle"
brew bundle --file=- << EOF
tap "homebrew/core"
tap "jez/formulae"
brew "asciidoctor"
brew "freetype"
brew "gettext"
brew "libffi"
brew "pcre"
brew "readline"
brew "sqlite"
brew "xz"
brew "autoconf"
brew "automake"
brew "bat"
brew "boost"
brew "curl"
brew "exiftool"
brew "gmp"
brew "libunistring"
brew "lame"
brew "xvid"
brew "ffmpeg"
brew "findutils"
brew "mpfr"
brew "gawk"
brew "gd"
brew "git"
brew "git-filter-repo"
brew "git-lfs"
brew "glib-networking"
brew "gnu-sed"
brew "go"
brew "pkg-config"
brew "gts"
brew "libtool"
brew "graphviz"
brew "gtk-doc"
brew "hledger"
brew "htop"
brew "hugo"
brew "libgit2"
brew "libmypaint"
brew "libressl"
brew "node"
brew "nvm"
brew "openfortivpn"
brew "openssh"
brew "p7zip"
brew "pandoc"
brew "py2cairo"
brew "pygobject3"
brew "ruby-build"
brew "rbenv"
brew "rsync"
brew "ruby"
brew "shellcheck"
brew "shfmt"
brew "shunit2"
brew "telnet"
brew "texinfo"
brew "tmux"
brew "tree"
brew "vifm"
brew "vim"
brew "youtube-dl"
brew "jez/formulae/pandoc-sidenote"
EOF
bootstrap_done "$((step++))"

###############################################################################
# Homebrew cask
###############################################################################
bootstrap_echo "Step $step: Install or upgrade cask"

brew bundle --file=- << EOF
tap "homebrew/cask-fonts"
tap "homebrew/cask"
tap "homebrew/cask-versions"
cask "alacritty"
cask "osxfuse"
cask "1password"
cask "alt-tab"
cask "appcleaner"
cask "basictex"
cask "brave-browser"
cask "calibre"
cask "font-sauce-code-pro-nerd-font"
cask "fork"
cask "imageoptim"
cask "kitty"
cask "onyx"
cask "remember-the-milk"
cask "slack"
cask "teamviewer"
cask "the-unarchiver"
cask "tor-browser"
cask "vagrant"
cask "veracrypt"
cask "visual-studio-code"
cask "vlc"
cask "zoom"
brew "encfs"
brew "ntfs-3g"
EOF
brew cleanup -s --prune 1

if ! command -v virtualbox; then
  if ! brew cask install virtualbox; then
    printf 'Continue? (y/N) \n>_ '
    read -r REPLY
    if [[ ! $REPLY =~ ^[Yy]$   ]]; then
      bootstrap_echo "Exit on demand"
      exit 0
    fi
  fi
fi
bootstrap_done "$((step++))"

################################################################################
# zsh plugin
################################################################################
bootstrap_echo "Step $step: Install or upgrade zsh plugin"
if ! [ -f ~/.config/powerlevel10k/powerlevel10k.zsh-theme ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/powerlevel10k
  echo 'source ~/.config/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
fi
brew bundle --file=- << EOF
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
