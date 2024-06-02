#!/bin/zsh
# Oh My Zsh configuration with plugins
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"  # Uncomment to use a different theme
plugins=(git brew node npm vscode)

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Starship prompt initialization
if [ -f "$HOME/.cargo/bin/starship" ]; then
    eval "$("$HOME/.cargo/bin/starship" init zsh)"
fi

# Aliases
alias cp='cp -rv'
alias ls='lsd'  # Assuming `lsd` is installed
alias mv='mv -v'
alias mkdir='mkdir -pv'
alias editbp="code ~/.zshrc"
alias shutdown="say 'As you wish, sir.' && sudo shutdown -h now"
alias restart="sudo shutdown -r now && say 'The system has been restarted, Sir. We are online and ready to resume.'"
alias brewup="brew update && brew upgrade && brew cleanup"
alias updateall="brew update && brew upgrade && npm update -g && gem update --system && softwareupdate --install --all && brew cleanup"

# NVM (Node Version Manager) setup
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Ruby environment with chruby
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.3

# Custom functions for interactive use
function blastoff(){
    echo "🚀"
}

# Environment management (Python, Ruby, etc.)
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Load nvmrc in the current directory
autoload -U add-zsh-hook
load-nvmrc() {
  if [ -f .nvmrc ]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc

# Starship prompt settings for command timings
zmodload zsh/parameter  # Needed to access jobstates variable for STARSHIP_JOBS_COUNT
zmodload zsh/datetime
zmodload zsh/mathfunc

__starship_get_time() {
    (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
}

prompt_starship_precmd() {
    STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=()
    if (( ${+STARSHIP_START_TIME} )); then
        __starship_get_time && (( STARSHIP_DURATION = STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
        unset STARSHIP_START_TIME
    else
        unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
    fi
    STARSHIP_JOBS_COUNT=${#jobstates}
}

prompt_starship_preexec() {
    __starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_starship_precmd
add-zsh-hook preexec prompt_starship_preexec

# Set up a function to redraw the prompt if the user switches vi modes
starship_zle-keymap-select() {
    zle reset-prompt
}

__starship_preserved_zle_keymap_select=${widgets[zle-keymap-select]#user:}
if [[ -z $__starship_preserved_zle_keymap_select ]]; then
    zle -N zle-keymap-select starship_zle-keymap-select
else
    starship_zle-keymap-select-wrapped() {
        $__starship_preserved_zle_keymap_select "$@"
        starship_zle-keymap-select "$@"
    }
    zle -N zle-keymap-select starship_zle-keymap-select-wrapped
fi

export STARSHIP_SHELL="zsh"
STARSHIP_SESSION_KEY="$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"
STARSHIP_SESSION_KEY="${STARSHIP_SESSION_KEY}0000000000000000"
export STARSHIP_SESSION_KEY=${STARSHIP_SESSION_KEY:0:16}

VIRTUAL_ENV_DISABLE_PROMPT=1
setopt promptsubst

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

eval "$(thefuck --alias)"
eval "$(rbenv init -)"

# Oh-My-Zsh settings
ENABLE_CORRECTION="true"
setopt promptsubst

# zsh-autosuggestions and zsh-syntax-highlighting
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Homebrew shell completion
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
  autoload -Uz compinit
  compinit
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/adriot/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/adriot/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/adriot/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/adriot/google-cloud-sdk/completion.zsh.inc'; fi

# Source additional dotfiles
for DOTFILE in $(find /Users/adriot/.dotfiles/system -type f); do
  source $DOTFILE
done
