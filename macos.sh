#!/usr/bin/env bash

# Adapted from https://mths.be/macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'
# Ask for the administrator password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2> /dev/null &

# Set standby delay and hibernation mode
#sudo pmset -a hibernatemode 3
#sudo pmset -a standby 1
#sudo pmset -a standbydelaylow 60
#sudo pmset -a standbydelayhigh 60

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Always show scrollbars, Possible values: `WhenScrolling`, `Automatic` and `Always`
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to iCloud (not to disk) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool true

###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
 defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/downloads"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs
 defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Enable HiDPI display modes (requires restart)
 sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Set the icon size of Dock items to 72 pixels
# defaults write com.apple.dock tilesize -int 72

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Disable Dashboard
#defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
#defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
#defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
#defaults write com.apple.dock autohide-delay -float 0

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Reset Launchpad, but keep the desktop wallpaper intact
# find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

# Add a spacer to the left side of the Dock (where the applications are)
# defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'

# Add a spacer to the right side of the Dock (where the Trash is)
# defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

# Hot corners                        |  Modifier keys
# Possible values:                   |  Possible values:
#  0: no-op                          |   0: No modifier keys
#  2: Mission Control                |   131072: Shift
#  3: Show application windows       |   262144: Control
#  4: Desktop                        |   524288: Option (Alt)
#  5: Start screen saver             |   1048576: Command (⌘)
#  6: Disable screen saver           |
#  7: Dashboard                      |
# 10: Put display to sleep           |
# 11: Launchpad                      |
# 12: Notification Center            |
# Top left screen corner + Option (Alt) →    Put display to sleep
 defaults write com.apple.dock wvous-tl-corner -int 10
 defaults write com.apple.dock wvous-tl-modifier -int 524288
# # Top right screen corner → no-op
 defaults write com.apple.dock wvous-tr-corner -int 0
 defaults write com.apple.dock wvous-tr-modifier -int 0
# # Bottom right screen corner → no-op
 defaults write com.apple.dock wvous-br-corner -int 0
 defaults write com.apple.dock wvous-br-modifier -int 0
# # bottom left screen corner + Option (Alt) → Launchpad
defaults write com.apple.dock wvous-bl-corner -int 11
defaults write com.apple.dock wvous-bl-modifier -int 524288

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Set $HOME directory as the default location for new Finder windows
# More options here: https://github.com/mathiasbynens/dotfiles/blob/96edd4b57047f34ffbcbb708e1e4de3a2e469925/.macos#L233
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Hide icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the entire Disk Drive by default
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

# Disable disk image verification
 defaults write com.apple.frameworks.diskimages skip-verify -bool true
 defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
 defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted
 defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
 defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
 defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use column view in all Finder windows by default
# Four-letter codes for all view modes: `icnv`, `clmv`, `Flwv`, `Nlsv`
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Enable AirDrop over Ethernet and on unsupported Macs running Lion
 defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true

  # Remove existing Downloads directory
rm -r ~/Downloads

# Create symbolic link to iCloud Downloads
ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/Downloads ~/Downloads


echo "Downloads folder has been linked to iCloud."

###############################################################################

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
mas install 442397431 # Address Book Clearout 2.1.10
mas install 1451544217 # Adobe Lightroom 7.2
mas install 6447312365 # AI Chat Bot 14.1.2
mas install 1037126344 # Apple Configurator 2.17
mas install 1028905953 # Betternet VPN 3.6.0
mas install 1518425043 # Boop 1.4.0
mas install 6449970704 # Brand Identity - Stylescape 1.0
mas install 897446215 # Canva 1.84.0
mas install 1500855883 # CapCut 3.7.0
mas install 1456386228 # Clockology 1.4.8
mas install 1130254674 # CloudMounter 4.5
mas install 1516894961 # Codye 2.0.3
mas install 1531594277 # Color Widgets 4.5.1
mas install 6476814377 # com.xavyx.Easy-Face-Blur 1.4.2
mas install 595191960 # CopyClip 1.9.8
mas install 1487937127 # Craft 2.7.8
mas install 6476924627 # Create Custom Symbols 1.6
mas install 980888073 # Crypto Pro 8.0.0
mas install 640199958 # Developer 10.5.1
mas install 1588151344 # Essentials 1.5.2
mas install 923463607 # Faviconer 1.1.2
mas install 1462114288 # Grammarly for Safari 9.73
mas install 1460330618 # Hype 4 4.1.16
mas install 1487860882 # iMazing Profile Editor 1.9.0
mas install 408981434 # iMovie 10.4
mas install 409183694 # Keynote 14.0
mas install 1602158108 # Logo Maker 2.4
mas install 6445850897 # Logo Maker & Creator 3.7
mas install 1369145272 # Logo Maker - Design Monogram 10.2.3
mas install 1458866808 # MacFamilyTree 9 9.3.3
mas install 441258766 # Magnet 2.14.0
mas install 1480068668 # Messenger 208.0
mas install 462058435 # Microsoft Excel 16.83
mas install 784801555 # Microsoft OneNote 16.83
mas install 985367838 # Microsoft Outlook 16.83.3
mas install 462062816 # Microsoft PowerPoint 16.83
mas install 462054704 # Microsoft Word 16.83
mas install 1464222390 # Model Pro 1.2
mas install 1551462255 # MouseBoost 3.3.8
mas install 1592917505 # Noir 2024.1.9
mas install 409203825 # Numbers 14.0
mas install 1471867429 # OTP Auth 2.18.0
mas install 409201541 # Pages 14.0
mas install 600925318 # Parallels Client 19.3.24686
mas install 1085114709 # Parallels Desktop 1.9.2
mas install 1472777122 # PayPal Honey 16.5.1
mas install 715483615 # Picture Collage Maker 3 Lite 3.7.10
mas install 1289583905 # Pixelmator Pro 3.5.8
mas install 1571283503 # Redirect Web for Safari 5.1.1
mas install 403195710 # Remote Mouse 3.302
mas install 1503136033 # Service Station 2020.9
mas install 1095562398 # Shopping for Amazon 3.3.1
mas install 442168834 # SiteSucker 5.3.2
mas install 863015334 # Sparkle 5.5.1
mas install 1633701470 # Sticklets 1.1.1
mas install 1150887374 # Sticky Notes 2.1.2
mas install 1082989794 # Templates for Pixelmator 3.0.0
mas install 899247664 # TestFlight 3.5.1
mas install 425424353 # The Unarchiver 4.3.6
mas install 1241342461 # Transcribe 4.18.13
mas install 1450874784 # Transporter 1.2.5
mas install 1482454543 # Twitter 9.30
mas install 1211437633 # Universe 2023.47
mas install 497799835 # Xcode 15.3

