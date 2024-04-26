#!/usr/bin/env bash
#title         :iTerm-fish.sh
#description   :This script will install and configure Fish Shell +Fisher
#author        :BGoodatit
#date          :2024-04-03
#version       :1.1
#usage         :bash <(curl --silent --location "https://github.com/BGoodatit/iterm-fish-fisher-osx/blob/master/install.sh?raw=true")
#bash_version  :5.0.17(1)-release
#===================================================================================

set -ueo pipefail

TEMP_DIR=$(mktemp -d)
COLOR_SCHEME_URL="https://raw.githubusercontent.com/BGoodatit/dotfiles/main/base16-londontube.dark.256.itermcolors?raw=true"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/blob/bc4416e176d4ac2092345efd7bcb4abef9d6411e/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf?raw=true"
PLUGINS_INSTALLER_URL="https://github.com/BGoodatit/iterm-fish-fisher-osx/blob/master/install_plugins.sh?raw=true"

INFO_LEVEL="\033[0;33m"
SUCCESS_LEVEL="\033[0;32m"

function print_info() {
  echo -e "${INFO_LEVEL}$1\033[0m"
}

function print_success() {
  echo -e "${SUCCESS_LEVEL}$1\033[0m"
}

function print_banner() {
  print_info "                                               "
  print_info "   ____ _ ____ _  _ ____ _  _ ____ _    _      "
  print_info "   |___ | [__  |__| [__  |__| |___ |    |      "
  print_info "   |    | ___] |  | ___] |  | |___ |___ |___   "
  print_info "                                               "
  print_info "    Command Line Tools + Homebrew + iTerm2     "
  print_info "         + Fish Shell + Fisher + Plugins       "
  print_info "                 Optimized for Apple Silicon   "
  print_info "                                               "
}

function install_command_line_tools() {
  if xcode-select --print-path &>/dev/null; then
    print_success "Command Line Tools already installed, skipping..."
  else
    print_info "Installing Command Line Tools for Apple Silicon MacBooks..."
    xcode-select --install &>/dev/null
    until xcode-select --print-path &>/dev/null; do
      sleep 5
    done
  fi
}

function install_homebrew() {
  if command -v brew &>/dev/null; then
    print_success "Homebrew already installed, skipping..."
  else
    print_info "Installing Homebrew specifically for Apple Silicon MacBooks..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/"$USER"/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

function install_iterm() {
  if [[ -d /Applications/iTerm.app ]]; then
    print_success "iTerm 2 already installed, skipping..."
  else
    print_info "Installing iTerm 2 optimized for Apple Silicon MacBooks..."
    brew install --cask iterm2
  fi
}

function install_fish_shell() {
  if command -v fish &>/dev/null; then
    print_success "Fish Shell already installed, skipping..."
  else
    print_info "Installing Fish Shell..."
    brew install fish
    command -v fish | sudo tee -a /etc/shells
    chsh -s "$(command -v fish)"
  fi
}
function install_fisher_and_plugins() {
  print_info "Installing Fisher + Plugins and post-processing installation..."

  # Install Oh My Fish (omf) framework
  fish -c "curl --silent --location https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | source"

  # Install Fisher and other tools within Fish shell
  fish -c "curl --silent --location https://git.io/fisher | source && \
             brew install terminal-notifier grc && \
             fisher install jorgebucaran/fisher \
                           edc/bass \
                           oh-my-fish/theme-chain \
                           patrickf1/colored_man_pages.fish \
                           franciscolourenco/done \
                           oh-my-fish/plugin-grc \
                           jorgebucaran/nvm.fish \
                           oh-my-fish/plugin-pj \
                           markcial/upto \
                           patrickf1/fzf.fish \
                           jethrokuan/z \
                           jorgebucaran/fnm && \
             omf install bass \
                         fish-spec \
                         foreign-env \
                         expand \
                         fish_logo \
                         vcs && \
             set --universal --export theme_nerd_fonts yes; \
             set --universal --export theme_color_scheme zenburn; \
             set --universal --export PROJECT_PATHS ~/Library/Projects && \
             fish_update_completions"

  print_success "Fisher and plugins installed successfully."
}

function print_post_installation() {
  print_success "                 "
  print_success "!!! IMPORTANT !!!"
  print_success "                 "

  print_success "The script accomplished all the commands it was told to do"
  print_success "Some things can't be automated and you need to do them manually"
  print_success " "
  print_success "1) Open iTerm -> Preferences -> Profiles -> Colors -> Color Presets and apply base16-londontube.dark preset"
  print_success "2) Open iTerm -> Preferences -> Profiles -> Text -> Font and apply Hack Nerd Font with ligatures checkbox ticked"
  print_success "3) Open iTerm -> Preferences -> Profiles -> Text -> Use a different font for non-ASCII text and apply FiraCode Nerd Font with ligatures checkbox ticked"
}

function setup_fish_config() {
  mkdir -p ~/.config/fish
  cat >~/.config/fish/config.fish <<'EOF'
        if status is-interactive
    # iTerm2 Shell Integration
    if begin
            status --is-interactive; and not functions -q -- iterm2_status; and [ "$ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX""$TERM" != screen ]; and [ "$ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX""$TERM" != screen-256color ]; and [ "$ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX""$TERM" != tmux-256color ]; and [ "$TERM" != dumb ]; and [ "$TERM" != linux ]
        end
        function iterm2_status
            printf "\033]133;D;%s\007" $argv
        end

        # Mark start of prompt
        function iterm2_prompt_mark
            printf "\033]133;A\007"
        end

        # Mark end of prompt
        function iterm2_prompt_end
            printf "\033]133;B\007"
        end

        # Tell terminal to create a mark at this location
        function iterm2_preexec --on-event fish_preexec
            # For other shells we would output status here but we can't do that in fish.
            if [ "$TERM_PROGRAM" = "iTerm.app" ]
                printf "\033]133;C;\r\007"
            else
                printf "\033]133;C;\007"
            end
        end

        # Usage: iterm2_set_user_var key value
        # These variables show up in badges (and later in other places). For example
        # iterm2_set_user_var currentDirectory "$PWD"
        # Gives a variable accessible in a badge by \(user.currentDirectory)
        # Calls to this go in iterm2_print_user_vars.
        function iterm2_set_user_var
            printf "\033]1337;SetUserVar=%s=%s\007" $argv[1] (printf "%s" $argv[2] | base64 | tr -d "\n")
        end

        function iterm2_write_remotehost_currentdir_uservars
            if not set -q -g iterm2_hostname
                printf "\033]1337;RemoteHost=%s@%s\007\033]1337;CurrentDir=%s\007" $USER (hostname -f 2>/dev/null) $PWD
            else
                printf "\033]1337;RemoteHost=%s@%s\007\033]1337;CurrentDir=%s\007" $USER $iterm2_hostname $PWD
            end

            # Users can define a function called iterm2_print_user_vars.
            # It should call iterm2_set_user_var and produce no other output.
            if functions -q -- iterm2_print_user_vars
                iterm2_print_user_vars
            end
        end

        functions -c fish_prompt iterm2_fish_prompt

        function iterm2_common_prompt
            set -l last_status $status

            iterm2_status $last_status
            iterm2_write_remotehost_currentdir_uservars
            if not functions iterm2_fish_prompt | grep -q iterm2_prompt_mark
                iterm2_prompt_mark
            end
            return $last_status
        end

        function iterm2_check_function -d "Check if function is defined and non-empty"
            test (functions $argv[1] | grep -cvE '^ *(#|function |end$|$)') != 0
        end

        if iterm2_check_function fish_mode_prompt
            # Only override fish_mode_prompt if it is non-empty. This works around a problem created by a
            # workaround in starship: https://github.com/starship/starship/issues/1283
            functions -c fish_mode_prompt iterm2_fish_mode_prompt
            function fish_mode_prompt --description 'Write out the mode prompt; do not replace this. Instead, change fish_mode_prompt before sourcing .iterm2_shell_integration.fish, or modify iterm2_fish_mode_prompt instead.'
                iterm2_common_prompt
                iterm2_fish_mode_prompt
            end

            function fish_prompt --description 'Write out the prompt; do not replace this. Instead, change fish_prompt before sourcing .iterm2_shell_integration.fish, or modify iterm2_fish_prompt instead.'
                # Remove the trailing newline from the original prompt. This is done
                # using the string builtin from fish, but to make sure any escape codes
                # are correctly interpreted, use %b for printf.
                printf "%b" (string join "\n" (iterm2_fish_prompt))

                iterm2_prompt_end
            end
        else
            # fish_mode_prompt is empty or unset.
            function fish_prompt --description 'Write out the mode prompt; do not replace this. Instead, change fish_mode_prompt before sourcing .iterm2_shell_integration.fish, or modify iterm2_fish_mode_prompt instead.'
                iterm2_common_prompt

                # Remove the trailing newline from the original prompt. This is done
                # using the string builtin from fish, but to make sure any escape codes
                # are correctly interpreted, use %b for printf.
                printf "%b" (string join "\n" (iterm2_fish_prompt))

                iterm2_prompt_end
            end
        end

        # If hostname -f is slow for you, set iterm2_hostname before sourcing this script
        if not set -q -g iterm2_hostname
            # hostname -f is fast on macOS so don't cache it. This lets us get an updated version when
            # it changes, such as if you attach to a VPN.
            if [ (uname) != Darwin ]
                set -g iterm2_hostname (hostname -f 2>/dev/null)
                # some flavors of BSD (i.e. NetBSD and OpenBSD) don't have the -f option
                if test $status -ne 0
                    set -g iterm2_hostname (hostname)
                end
            end
        end

        iterm2_write_remotehost_currentdir_uservars
        printf "\033]1337;ShellIntegrationVersion=18;shell=fish\007"
    end
    # TheFuck command correction tool setup, with check if installed
    thefuck --alias | source
    # Setup PATH for Homebrew, ensuring no duplication with fish_add_path
    # Homebrew autojump integration
    source /opt/homebrew/share/autojump/autojump.fish
    set -gx HOMEBREW_PREFIX /opt/homebrew
    set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
    set -gx HOMEBREW_REPOSITORY /opt/homebrew
    #Corrected the PATH concatenation
    set -gx PATH /opt/homebrew/bin:/opt/homebrew/sbin:$PATH
    # Simplified MANPATH setting
    set -gx MANPATH /opt/homebrew/share/man:$MANPATH
    set -gx INFOPATH /opt/homebrew/share/info:$INFOPATH
    # Correctly setting Pyenv
    set -gx PYENV_ROOT "$HOME/.pyenv"
    pyenv init --path | source
    pyenv init - | source
    set -gx PATH "$HOME/.rbenv/bin" $PATH
    status --is-interactive; and source (rbenv init -|psub)
    # Chruby Initialization
    bass source /opt/homebrew/Cellar/chruby/0.3.9/share/chruby/chruby.sh
    bass source /opt/homebrew/Cellar/chruby/0.3.9/share/chruby/auto.sh
    chruby ruby-3.1.3
    # Virtualenvwrapper configuration
    set -gx WORKON_HOME $HOME/.virtualenvs
    set -gx PROJECT_HOME $HOME/Devel
    set -gx VIRTUALENVWRAPPER_PYTHON /opt/homebrew/bin/python3
    set -U XDG_DATA_DIRS /opt/homebrew/share
    # Setup NVM (Node Version Manager) with Bass, if installed
    set -gx NVM_DIR "$HOME/.nvm"
    if type bass >/dev/null 2>&1
        bass source (brew --prefix nvm)/nvm.sh
        bass source (brew --prefix nvm)/etc/bash_completion.d/nvm
    else
        echo "Bass is not installed. NVM will not be available."
    end
    # Custom Aliases
    alias ll="ls -lGaf"
    alias shutdown="say 'As you wish, sir.' ; sudo shutdown -h now"
    alias restart="sudo shutdown -r now ; say 'The system has been restarted, Sir. We are online and ready to resume.'"
    alias updateall="brew update && brew upgrade && brew cleanup; say 'Updates complete, sir.'"
    alias expresso="brew update --verbose && brew doctor && brew upgrade --verbose && brew cleanup && brew cleanup -s"
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
    function code
        set VSCODE_CWD "$PWD"
        open -n -b "com.microsoft.VSCode" --args $argv
    end
    function fish_greeting -d "Display a fish greeting with logos and versions"
        if type neofetch >/dev/null 2>&1
            neofetch --stdout | lolcat
        end
        # Display the fish logo with specified colors
        fish_logo blue cyan green
        echo -n
        echo (set_color normal)
        echo -n (chain.links.node_version) (chain.links.python_version) (chain.links.ruby_version)
    end
    # asdf version manager
    source /opt/homebrew/opt/asdf/libexec/asdf.fish
    if test -s (brew --prefix asdf)/asdf.sh
        source (brew --prefix asdf)/asdf.sh
    end
    if string match -q "$TERM_PROGRAM" vscode
        . (code --locate-shell-integration-path fish)
    end
    function chain.links.git_branch
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
            set git_branch (command git branch --show-current 2>/dev/null)
            if test -n "$git_branch"
                set git_status (command git status --porcelain=v1 2>/dev/null | wc -l)
                if test "$git_status" -gt 0
                    set git_state "[]"
                else
                    set git_state ""
                end
                set_color purple
                echo -n " $git_branch $git_state "
                set_color normal
            end
        end
    end
    function chain.links.python_version
        set python_version (python3 --version 2>/dev/null | string match -r 'Python \K[^\s]+' | string trim)
        if test -n "$python_version"
            set_color normal
            echo -n "🐍 v$python_version "
            set_color normal
        end
    end
    function chain.links.node_version
        set node_version (node --version 2>/dev/null | sed 's/^v//')
        if test -n "$node_version"
            set_color green
            echo -n ""
            set_color normal
            echo " v$node_version "
            set_color normal
        end
    end
    function chain.links.ruby_version
        # Use `ruby -v` to get the version information, then parse it to extract the version number
        set ruby_version (ruby --version 2>/dev/null | string match -r 'ruby \K[\d.]+')
        # Check if the ruby_version variable is not empty and display it
        if test -n "$ruby_version"
            #set_color EC3B86
            echo -n "💎 v$ruby_version"
            set_color normal
        end
    end
    function chain.links.vcs.present
        # Check for a .git directory in the current or parent directories
        if test -d .git || git rev-parse --git-dir >/dev/null 2>&1
            return 0 # Success, VCS present
        else
            return 1 # Failure, VCS not present
        end
    end
    function chain.links.git_branch_status
        # Check if inside a Git repository
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
            # Get the current branch
            set -l branch (git branch --show-current)
            # Count the number of changes
            set -l changes (git status --short | wc -l)

            # Display branch and indicate if there are changes
            if test "$changes" -gt 0
                echo -n " $branch" # Display branch with changes indicator
            else
                echo -n "$branch" # Display branch only
            end
        end
        # Implicit else: Do nothing if not inside a Git repository
    end
    function chain.links.battery
        # Assuming macOS; adjust for Linux if needed
        set battery (pmset -g batt | grep -Eo "\d+%" | sed 's/%//')
        set charging_status (pmset -g batt | grep -o 'AC Power' > /dev/null; and echo "⚡"; or echo "🔋")
        echo -n " $battery%"
    end
    function chain.links.venv
        if set -q VIRTUAL_ENV
            echo -n (basename $VIRTUAL_ENV)
        end
    end
    function chain.links.load
        set -l load (uptime | sed 's/.*load averages: //' | awk '{print $1}')
        echo -n "Load: $load"
    end
    function chain.links.k8s
        if type -q kubectl
            set -l context (kubectl config current-context 2>/dev/null)
            if test $status -eq 0
                echo -n "K8s: $context"
            end
        end
    end
    function chain.links.timestamp
        echo -n (date "+%H:%M")
    end
    function chain.links.docker_machine
        if type -q docker-machine
            set -l machine (docker-machine active)
            echo -n "Docker: $machine"
        end
    end
    function srcconfig
        source ~/.config/fish/config.fish
    end
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
    end
EOF
  print_success "Fish configuration written to ~/.config/fish/config.fish"
}

print_banner
install_command_line_tools
install_homebrew
install_iterm
install_fish_shell
install_fisher_and_plugins
setup_fish_config
print_post_installation
