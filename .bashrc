#!/bin/bash
# Path settings
export PATH="$HOME/bin:/opt/homebrew/bin:$PATH"

# Aliases
alias cp='cp -rv'
alias ls='ls -lGAF'  # macOS `ls`
alias mv='mv -v'
alias mkdir='mkdir -pv'
alias editbp="code ~/.bash_profile"
alias shutdown="say 'As you wish, sir.' && sudo shutdown -h now"
alias restart="sudo shutdown -r now && say 'The system has been restarted, Sir. We are online and ready to resume.'"
alias brewup="brew update --verbose && brew upgrade --verbose && brew cleanup"

# Custom functions
function blastoff(){
    echo "🚀"
}
function set_win_title(){
    echo -ne "\033]0; $(basename "$PWD") \007"
}

# Choose one function to keep for starship prompt
starship_precmd_user_func="blastoff"  # or "set_win_title"

# Environment setups
export SOFTWARE_UPDATE_AVAILABLE="📦"

# Version managers
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi
. "$HOME/.cargo/env"
source /opt/homebrew/opt/asdf/libexec/asdf.sh
source /Users/adriot/starship.bash
source ~/.local/share/blesh/ble.sh

if type brew &>/dev/null; then
    HOMEBREW_PREFIX="$(brew --prefix)"
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    else
        for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
            [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
        done
    fi
fi
