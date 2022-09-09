#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=./macos/bash_library
source "${SCRIPT_DIR}/bash_library"

# Move dock to left side of screen (Horizonal realestate is larger than vertical)
defaults write com.apple.Dock orientation left

# Enable autohide
defaults write com.apple.Dock autohide 1

# Autohide delay effectively 0
defaults write com.apple.Dock autohide-delay -float 0.001

# Instant disappearing dock
defaults write com.apple.Dock autohide-time-modifier -int 1

# Scroll to see open windows on application (or open folder on dock)
defaults write com.apple.Dock scroll-to-open -bool TRUE

# Better animation than "Genie"
defaults write com.apple.Dock mineffect suck

# Show "Hidden" applications transparent
defaults write com.apple.Dock showhidden -bool TRUE




killall Dock