OS := $(shell bin/is-supported bin/is-macos macos)
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local)
export PATH := /usr/local/bin:$(HOME)/.asdf/shims:$(HOMEBREW_PREFIX)/bin:$(DOTFILES_DIR)/bin:$(PATH)
export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)
export ACCEPT_EULA=Y
USER := $(shell whoami)
IS_M1 := $(shell bin/is-supported bin/is-arm64 true false)
ifeq "$(IS_M1)" "true"
BREW=/opt/homebrew/bin/brew
BREW_CMD=arch -arm64 brew
else
BREW=/usr/local/bin/brew
BREW_CMD=brew
endif

HOMEFILES := $(shell ls -A $(HOME))
DOTFILES := $(addprefix $(HOME)/,$(HOMEFILES))

.PHONY: TEST

ifeq "$(OS)" "macos"

TEST:
	cat ~/.zprofile

DOTFILES:
	echo "Does nothing yet"

ADD_SUDO: SUDOERS_FILE=/private/etc/sudoers.d/$(USER)
ADD_SUDO:
	is-grep $(USER) $(SUDOERS_FILE) || (echo "$(USER)		ALL = (ALL) NOPASSWD: ALL" | sudo tee $(SUDOERS_FILE))

INSTALL_HOMEBREW: ADD_SUDO
	is-executable brew || (echo 'Installing Homebrew'; NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

POST_INSTALL_HOMEBREW: | INSTALL_HOMEBREW
	is-grep "/opt/homebrew/bin/brew" $(HOME)/.zprofile || (echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' | tee -a ~/.zprofile)

INSTALL_YQ: | POST_INSTALL_HOMEBREW
	is-executable yq || (echo "Installing yq"; $(BREW_CMD) install yq)

INSTALL_STOW: POST_INSTALL_HOMEBREW
	is-executable stow || (echo 'Installing stow'; $(BREW_CMD) install stow)

INSTALL_OHMYZSH:
	is-folder ~/.oh-my-zsh || (echo 'Installing Oh-my-zsh'; sh -c "$$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)")

INSTALL_OMZSH_THEMES:
	THEMES="$(shell yq '.zsh.oh-my-zsh.themes | to_entries | .[] | (.key + "|" +.value)' things.yaml)"; \
	for theme in $${THEMES}; do \
	folder="$$(echo $$theme | cut -f1 -d'|')"; \
	gitrepo="$$(echo $$theme | cut -f2 -d'|')"; \
	if [ ! -d "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/$${folder}" ]; then \
	echo "Cloning $${folder}"; \
	git clone --depth=1 $${gitrepo} $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/$${folder}; \
	else \
	echo "Updating $${folder}: "; \
	git -C "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/$${folder}" pull; \
	fi \
	done

INSTALL_OMZSH_PLUGINS:
	PLUGINS="$(shell yq '.zsh.oh-my-zsh.themes | to_entries | .[] | (.key + "|" +.value)' things.yaml)"; \
	for plugin in $${PLUGINS}; do \
	folder="$$(echo $$plugin | cut -f1 -d'|')"; \
	gitrepo="$$(echo $$plugin | cut -f2 -d'|')"; \
	if [ ! -d "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/$${folder}" ]; then \
	echo "Cloning $${folder}"; \
	git clone --depth=1 $${gitrepo} $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/$${folder}; \
	else \
	echo "Updating $${folder}: "; \
	git -C "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/$${folder}" pull; \
	fi \
	done

INSTALL_FORMULAS: INSTALL_HOMEBREW CREATE_BREWFILE
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true
	xattr -d -r com.apple.quarantine ~/Library/QuickLook

CREATE_BREWFILE:
	makebrew things.yaml || (echo "Error creating Brewfile"; exit 1)

CREATE_CODEFILE:
	makecode things.yaml || (echo "Error creating Codefile"; exit 1)

TFENV_SETUP:
	tfenv install latest; \
	tfenv use latest

INSTALL_PIP_PROGRAMS: PIPPROGRAMS="$(shell yq '.pip.[]' things.yaml)"
INSTALL_PIP_PROGRAMS:
	pip install "$(PIPPROGRAMS)"

INSTALL_ASDF_PROGRAMS: PROGRAMS="$(shell yq '.asdf.[]' things.yaml)"
INSTALL_ASDF_PROGRAMS:
	for program in "$(PROGRAMS)"; do \
		asdf plugin add $$program; \
		asdf install $$program latest; \
		asdf global $$program latest; \
	done

endif

$(V).SILENT: