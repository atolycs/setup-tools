#!/usr/bin/env bash

echo "Welcome macOS Setup tools"
echo "   create by Atolycs 2025"

echo "Setup Show extension"

defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Setup show path and status bar"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

echo "Setup Don't Create .DS_Store file on Network folder"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "Completed"
