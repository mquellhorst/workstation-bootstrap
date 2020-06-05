#!/usr/bin/env bash

# Close any open System Preferences panes, to prevent them from overriding
# settings we're about to change
osascript -e 'tell application "System Preferences" to quit'

# Show remaining battery time; hide percentage
# This doesn't seem to work
defaults write com.apple.menuextra.battery ShowPercent -string "NO"
defaults write com.apple.menuextra.battery ShowTime -string "YES"

# Finder

# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true && \
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Sets default save target to be a local disk, not iCloud.
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false

# Avoid creation of .DS_Store and AppleDoubles files.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true


# Figure out how to show the bluetooth icon in the menu bar

