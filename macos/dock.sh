#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

# Move dock to left side of screen (Horizonal realestate is larger than vertical)
.log -l 6 "Setting dock to left side of screen"
defaults write com.apple.Dock orientation left

# Enable autohide
.log -l 6 "Setting dock to autohide"
defaults write com.apple.Dock autohide 1

# Autohide delay effectively 0
.log -l 6 "Setting dock to no delay when showing"
defaults write com.apple.Dock autohide-delay -float 0.001

# Instant disappearing dock
.log -l 6 "Setting dock to no delay when hiding"
defaults write com.apple.Dock autohide-time-modifier -int 1

# Scroll to see open windows on application (or open folder on dock)
.log -l 6 "Setting dock to show application when scrolled"
defaults write com.apple.Dock scroll-to-open -bool TRUE

# Better animation than "Genie"
.log -l 6 "Setting dock to have hidden 'suck' effect"
defaults write com.apple.Dock mineffect suck

# Show "Hidden" applications transparent
.log -l 6 "Setting dock to show hidden applications as transparent"
defaults write com.apple.Dock showhidden -bool TRUE

.log -l 6 "Restarting dock to apply changes"
killall Dock

# TODO: dockutil -- setup apps
