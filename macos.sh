#!/usr/bin/env bash

# Adapted from https://mths.be/macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2> /dev/null &

###############################################################################
# System Preferences                                                          #
###############################################################################

# Set standby delay and hibernation mode
# sudo pmset -a hibernatemode 3
# sudo pmset -a standby 1
# sudo pmset -a standbydelaylow 60
# sudo pmset -a standbydelayhigh 60

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

# Expand save and print panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to iCloud by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool true

###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Pictures"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "JPG"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Enable HiDPI display modes (requires restart)
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Reset Launchpad
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

# Add a spacer to the left and right side of the Dock
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

# Set hot corners
# Top left screen corner → Mission Control
defaults write com.apple.dock wvous-tl-corner -int 4
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Desktop
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom right screen corner → Start screen saver
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 0
# Bottom left screen corner → Launchpad
defaults write com.apple.dock wvous-bl-corner -int 11
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q
defaults write com.apple.finder QuitMenuItem -bool true

# Hide icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Finder: show hidden files and all filename extensions
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status and path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search the entire Disk Drive by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCev"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# To have mds ignore all external volumes including network volumes
sudo defaults write /Library/Preferences/com.apple.SpotlightServer.plist ExternalVolumesIgnore -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use column view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Enable AirDrop over Ethernet and on unsupported Macs
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Expand the following File Info panes:
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

###############################################################################
# Miscellaneous                                                               #
###############################################################################

# Disable “natural” scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Miscellaneous appearance settings
defaults write -g NSRequiresAquaSystemAppearance -bool No  # Allows custom appearance settings for all applications

# Accent and highlight color settings
defaults write -globalDomain "AppleAquaColorVariant" -int 1
defaults write -globalDomain "AccentColor" -int 0
defaults write -globalDomain "AppleHighlightColor" -string "1.000000 0.733333 0.721569 Red"

# Configure press-and-hold behavior for text editors
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false  # VS Code
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false  # VS Code Insiders
defaults write com.vscodium ApplePressAndHoldEnabled -bool false  # VSCodium
defaults write com.microsoft.VSCodeExploration ApplePressAndHoldEnabled -bool false  # VS Code Exploration
defaults delete -g ApplePressAndHoldEnabled  # Resets the global press-and-hold setting to default

# Dock modifications
defaults write com.apple.dock autohide-time-modifier -float 0.5; killall Dock  # Speeds up Dock auto-hiding
defaults write com.apple.dock mineffect -string "suck"; killall Dock  # Changes the minimize effect in the Dock to 'suck'
defaults write com.apple.dock static-only -bool true; killall Dock  # Restricts the Dock to only static items

# Finder behavioral settings
defaults write com.apple.finder QuitMenuItem -bool true  # Enables quitting Finder via ⌘ + Q

# Enable debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true

# Expand save and print panels by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true  # Always expanded save panel
defaults write -g PMPrintingExpandedStateForPrint -bool true  # Always expanded print dialog

# Show additional system info at the login screen
defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Enable the developer mode for Dashboard widgets
defaults write com.apple.dashboard devmode -bool true

# Use verbose boot mode
sudo nvram boot-args="-v"

# Restart Finder and Dock to apply all settings
killall Finder
killall Dock
