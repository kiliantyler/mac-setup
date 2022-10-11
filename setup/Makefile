OS := $(shell bin/is-supported bin/is-macos macos)
VIRTUAL := $(shell bin/is-virtual vm)
SETUP_DIR := $(shell dirname $(firstword $(realpath $(MAKEFILE_LIST))))
DOTFILES_DIR := $(HOME)/dotfiles
INSTALL_FILE = installs.yaml
INSTALL_PATH = $(DOTFILES_DIR)/$(INSTALL_FILE)
ZSH_LOCATION = $(shell which zsh)
ifeq "$(OS)" "macos"
  HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local)
  SUDOERS_FILE=/private/etc/sudoers.d/$(USER)
else
  HOMEBREW_PREFIX := /home/linuxbrew/.linuxbrew
  SUDOERS_FILE=/etc/sudoers.d/$(USER)
endif

export PATH := /usr/local/bin:$(HOME)/.asdf/shims:$(HOMEBREW_PREFIX)/bin:$(SETUP_DIR)/bin:$(SETUP_DIR)/scripts:$(SETUP_DIR)/macos:$(PATH)
export BASH_LIBRARY := $(SETUP_DIR)/scripts/bash_library.sh
export ACCEPT_EULA=Y
USER := $(shell whoami)
IS_M1 := $(shell bin/is-supported bin/is-arm64 true false)
ifeq "$(IS_M1)" "true"
BREW = /opt/homebrew/bin/brew
BREW_CMD = arch -arm64 brew
else
BREW = /usr/local/bin/brew
BREW_CMD = brew
endif
TF_VER = latest
FORMULA=

EXPORT_INSTALLFILE:
	echo $(INSTALL_FILE)

EXPORT_DOTFILES_DIR:
	echo $(DOTFILES_DIR)
