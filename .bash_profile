#!/bin/bash
# Load .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Homebrew settings
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export MANPATH="/opt/homebrew/share/man:$MANPATH"
export INFOPATH="/opt/homebrew/share/info:$INFOPATH"

# Initialize Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# MacPorts settings
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
export MANPATH="/opt/local/share/man:$MANPATH"

# Add Visual Studio Code (code) to PATH
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Pyenv settings
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Ruby with rbenv
if command -v rbenv >/dev/null; then
    eval "$(rbenv init -)"
fi

# Virtualenvwrapper settings
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
export VIRTUALENVWRAPPER_PYTHON="/opt/homebrew/bin/python3"

# Load nvm if installed
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Ruby environment with chruby
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.3

# Source additional configurations
if [ -f "/opt/homebrew/etc/profile.d/bash_completion.sh" ]; then
    source "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

. "$HOME/.cargo/env"

# Set PATH for specific tools
export PATH="$HOME/httrack_install/bin:$PATH"

# Ensure PATH is clean and correctly set up
eval 'PATH="$(bash --norc -ec 'IFS=:; paths=($PATH);
for i in ${!paths[@]}; do
if [[ ${paths[i]} == "''/Users/adriot/.pyenv/shims''" ]]; then unset '\''paths[i]'\''; fi; done;
echo "${paths[*]}"')"
export PATH="/Users/adriot/.pyenv/shims:${PATH}"
command pyenv rehash 2>/dev/null'
