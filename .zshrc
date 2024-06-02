
# Oh My Zsh configuration with plugins
export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="bira" # Uncomment to use the bira theme
plugins=(git brew node npm vscode) # Assuming uniqueness is handled by Oh My Zsh

# Zsh options and Oh My Zsh updates
ENABLE_CORRECTION="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# NVM (Node Version Manager) setup
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# asdf version manager
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Starship prompt initialization
eval "$(starship init zsh)"

# zsh-autosuggestions and zsh-syntax-highlighting
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Homebrew shell completion
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
  autoload -Uz compinit && compinit
fi

# Aliases
alias shutdown="say 'As you wish, sir.' ; sudo shutdown -h now"
alias restart="sudo shutdown -r now ; say 'The system has been restarted, Sir. We are online and ready to resume.'"
alias sudo='sudo -p "You better know what you are doing:"'
alias ls="lsd"
alias ll="ls -lGaf"
alias updateall="brew update && brew upgrade ; npm update -g ; say 'Updates complete.'"
alias expresso="brew update --verbose && brew doctor && brew upgrade --verbose && brew cleanup -s"
alias checkup="brew update && brew upgrade && brew upgrade --cask && npm update -g && npm upgrade -g && gem update --system && softwareupdate --install --all && say 'System checkup complete, sir.' && brew cleanup -s"
alias activedock="defaults write com.apple.dock static-only -bool TRUE; killall Dock"
alias staticdock="defaults write com.apple.dock static-only -bool FALSE; killall Dock"
alias dock="defaults delete com.apple.dock; killall Dock"
alias brainfreeze="sudo systemsetup -setrestartfreeze on"
alias charging="defaults write com.apple.PowerChime ChimeOnAllHardware -bool true && \
open /System/Library/CoreServices/PowerChime.app"
alias charged="defaults write com.apple.PowerChime ChimeOnAllHardware -bool false && \
open /System/Library/CoreServices/PowerChime.app"
alias srcconfig=" source ~/.zshrc"
# Alias to hide desktop icons
alias hidedesktop="defaults write com.apple.finder CreateDesktop false; killall Finder"
# Alias to show desktop icons
alias desktop="defaults write com.apple.finder CreateDesktop true; killall Finder"
# Alias to hide system files
alias hide="defaults write com.apple.finder AppleShowAllFiles -boolean false; killall Finder"
# Alias to show system files
alias show="defaults write com.apple.finder AppleShowAllFiles -boolean true; killall Finder"
# Charging sound alerts
alias charging="defaults write com.apple.PowerChime ChimeOnAllHardware -bool true && open /System/Library/CoreServices/PowerChime.app"
alias charged="defaults write com.apple.PowerChime ChimeOnAllHardware -bool false && open /System/Library/CoreServices/PowerChime.app"
alias srcconfig="source ~/.zshrc"
# Environment management (Python, Ruby, etc.)
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.3

# Load nvmrc in the current directory
autoload -U add-zsh-hook
load-nvmrc() {
  if [ -f .nvmrc ]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# ZSH has a quirk where `preexec` is only run if a command is actually run (i.e
# pressing ENTER at an empty command line will not cause preexec to fire). This
# can cause timing issues, as a user who presses "ENTER" without running a command
# will see the time to the start of the last command, which may be very large.

# To fix this, we create STARSHIP_START_TIME upon preexec() firing, and destroy it
# after drawing the prompt. This ensures that the timing for one command is only
# ever drawn once (for the prompt immediately after it is run).

zmodload zsh/parameter  # Needed to access jobstates variable for STARSHIP_JOBS_COUNT

# Defines a function `__starship_get_time` that sets the time since epoch in millis in STARSHIP_CAPTURED_TIME.
if [[ $ZSH_VERSION == ([1-4]*) ]]; then
    # ZSH <= 5; Does not have a built-in variable so we will rely on Starship's inbuilt time function.
    __starship_get_time() {
        STARSHIP_CAPTURED_TIME=$(::STARSHIP:: time)
    }
else
    zmodload zsh/datetime
    zmodload zsh/mathfunc
    __starship_get_time() {
        (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
    }
fi

# The two functions below follow the naming convention `prompt_<theme>_<hook>`
# for compatibility with Zsh's prompt system. See
# https://github.com/zsh-users/zsh/blob/2876c25a28b8052d6683027998cc118fc9b50157/Functions/Prompts/promptinit#L155

# Runs before each new command line.
prompt_starship_precmd() {
    # Save the status, because subsequent commands in this function will change $?
    STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=()

    # Calculate duration if a command was executed
    if (( ${+STARSHIP_START_TIME} )); then
        __starship_get_time && (( STARSHIP_DURATION = STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
        unset STARSHIP_START_TIME
    # Drop status and duration otherwise
    else
        unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
    fi

    # Use length of jobstates array as number of jobs. Expansion fails inside
    # quotes so we set it here and then use the value later on.
    STARSHIP_JOBS_COUNT=${#jobstates}
}

# Runs after the user submits the command line, but before it is executed and
# only if there's an actual command to run
prompt_starship_preexec() {
    __starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME
}

# Add hook functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_starship_precmd
add-zsh-hook preexec prompt_starship_preexec

# Set up a function to redraw the prompt if the user switches vi modes
starship_zle-keymap-select() {
    zle reset-prompt
}

## Check for existing keymap-select widget.
# zle-keymap-select is a special widget so it'll be "user:fnName" or nothing. Let's get fnName only.
__starship_preserved_zle_keymap_select=${widgets[zle-keymap-select]#user:}
if [[ -z $__starship_preserved_zle_keymap_select ]]; then
    zle -N zle-keymap-select starship_zle-keymap-select;
else
    # Define a wrapper fn to call the original widget fn and then Starship's.
    starship_zle-keymap-select-wrapped() {
        $__starship_preserved_zle_keymap_select "$@";
        starship_zle-keymap-select "$@";
    }
    zle -N zle-keymap-select starship_zle-keymap-select-wrapped;
fi

export STARSHIP_SHELL="zsh"

# Set up the session key that will be used to store logs
STARSHIP_SESSION_KEY="$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"; # Random generates a number b/w 0 - 32767
STARSHIP_SESSION_KEY="${STARSHIP_SESSION_KEY}0000000000000000" # Pad it to 16+ chars.
export STARSHIP_SESSION_KEY=${STARSHIP_SESSION_KEY:0:16}; # Trim to 16-digits if excess.

VIRTUAL_ENV_DISABLE_PROMPT=1

setopt promptsubst

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

eval "$(thefuck --alias)"

eval "$(rbenv init -)"
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
  autoload -Uz compinit
  compinit
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/adriot/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/adriot/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/adriot/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/adriot/google-cloud-sdk/completion.zsh.inc'; fi

for DOTFILE in `find /Users/adriot/.dotfiles/system`
do
  [ -f $DOTFILE ] && source $DOTFILE
done
