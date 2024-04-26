# Shell detection for cross-compatibility between Zsh and Bash
if [ -n "$ZSH_VERSION" ]; then
   # assume Zsh
   SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
   # assume Bash
   SHELL_NAME="bash"
else
   # default to Zsh if unknown
   SHELL_NAME="zsh"
fi

# OS checks
case "$(uname -s)" in
Darwin*)
  IS_MAC=true
  IS_LINUX=false
  ;;
Linux*)
  IS_MAC=false
  IS_LINUX=true
  ;;
esac

# Source aliases if available
if [ -f ~/.aliases ]; then
  source ~/.aliases
fi

# Environment variables
export VISUAL="code -w"  # Setting Visual Studio Code as the default editor

# Prepend directory to PATH
# Skipped if directory does not exist
# Argument should be /absolute/path or ~/user/path
prepend_path() {
  if [ -d "$1" ]; then
    export PATH="$1:$PATH"
  fi
}

# Ignore the check on terminal setup - always add
# This works well for paths that are relative to the current directory
prepend_path_always() {
  export PATH="$1:$PATH"
}

# Setup PATH for Apple Silicon optimizations
prepend_path "/opt/homebrew/bin"  # Homebrew ARM64 path is prioritized
prepend_path "/usr/local/sbin"
prepend_path "/usr/local/bin"
prepend_path "~/.local/bin"
prepend_path "~/bin"
prepend_path "~/.deno/bin"
prepend_path "~/npm/bin"
prepend_path "./node_modules/.bin"
prepend_path "~/.local/go/bin"

# Node Version Manager (NVM) setup for both Zsh and Bash
setup_nvm() {
  export NVM_DIR="$HOME/.nvm"
  if [ "$SHELL_NAME" = "zsh" ] || [ "$SHELL_NAME" = "bash" ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  fi
}
setup_nvm

# Python configurations
export PIP_REQUIRE_VIRTUALENV=true  # Prevent global pip installs

# Ruby configuration for macOS
if [[ "$IS_MAC" == 'true' ]]; then
  prepend_path /usr/local/opt/ruby/bin
fi
if which ruby >/dev/null && which gem >/dev/null; then
  GEM_PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin"
  prepend_path "$GEM_PATH"
fi

# Clean-up
unset -f prepend_path prepend_path_always
