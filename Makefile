OS := $(shell bin/is-supported bin/is-macos macos)
SETUP_DIR := $(shell dirname $(realpath $(MAKEFILE_LIST)))
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local)
DOTFILES_DIR := $(HOME)/dotfiles
INSTALL_FILE = installs.yaml
INSTALL_PATH = $(DOTFILES_DIR)/$(INSTALL_FILE)
export PATH := /usr/local/bin:$(HOME)/.asdf/shims:$(HOMEBREW_PREFIX)/bin:$(SETUP_DIR)/bin:$(SETUP_DIR)/scripts:$(SETUP_DIR)/macos:$(PATH)
export BASH_LIBRARY := $(SETUP_DIR)/scripts/bash_library.sh
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
TF_VER = latest

.PHONY: TEST DOTFILES

# We only support macs for now (Linux in the future?)
ifeq "$(OS)" "macos"

ALL:
	# Eventually everything will be listed here

DOTFILES: INSTALL_STOW
	dotfiles.sh || (echo "Error with dotfiles.sh"; exit 1)

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

INSTALL_OMZSH_THEMES: INSTALL_YQ
	THEMES="$(shell yq '.zsh.oh-my-zsh.themes | to_entries | .[] | (.key + "|" +.value)' $(INSTALL_PATH))"; \
	for theme in $${THEMES}; do \
	folder="$$(echo $$theme | cut -f1 -d'|')"; \
	gitrepo="$$(echo $$theme | cut -f2 -d'|')"; \
	if [ ! -d "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/$${folder}" ]; then \
	echo "Cloning $${folder}"; \
	git clone --depth=1 $${gitrepo} $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/$${folder}; \
	else \
	echo "Updating $${folder}: "; \
	git -C "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/themes/$${folder}" pull; \
	fi \
	done # TODO: move this to a script

INSTALL_OMZSH_PLUGINS: INSTALL_YQ
	PLUGINS="$(shell yq '.zsh.oh-my-zsh.plugins | to_entries | .[] | (.key + "|" +.value)' $(INSTALL_PATH))"; \
	for plugin in $${PLUGINS}; do \
	folder="$$(echo $$plugin | cut -f1 -d'|')"; \
	gitrepo="$$(echo $$plugin | cut -f2 -d'|')"; \
	if [ ! -d "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/$${folder}" ]; then \
	echo "Cloning $${folder}"; \
	git clone --depth=1 $${gitrepo} $${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/$${folder}; \
	else \
	echo "Updating $${folder}: "; \
	git -C "$${ZSH_CUSTOM:-$$HOME/.oh-my-zsh/custom}/plugins/$${folder}" pull; \
	fi \
	done # TODO: move this to a script

INSTALL_FORMULAS: INSTALL_HOMEBREW CREATE_BREWFILE INSTALL_YQ
	brew bundle --file=$(SETUP_DIR)/install/Brewfile || true

CREATE_BREWFILE: INSTALL_YQ
	makebrew.sh $(INSTALL_PATH) || (echo "Error creating Brewfile"; exit 1)

CREATE_CODEFILE: INSTALL_YQ
	makecode.sh $(INSTALL_PATH) || (echo "Error creating Codefile"; exit 1)

TFENV_SETUP:
	tfenv install $(TF_VER); \
	tfenv use $(TF_VER)

INSTALL_PIPX:
	is-executable pipx || (echo "Installing pipx"; pip install pipx)

INSTALL_PIP_PROGRAMS: INSTALL_PIPX INSTALL_YQ
	PIPPROGRAMS="$(shell yq '.pip.[]' $(INSTALL_PATH))"; \
	for i in $${PIPPROGRAMS}; do pipx install $$i; done

INSTALL_ASDF_PROGRAMS: INSTALL_YQ
	asdfinstall.sh $(INSTALL_PATH) || (echo "Error installing asdf programs"; exit 1)

SETUP_1PASSWORD:
	macos/1password.sh

INSTALL_MAS:
	is-executable mas || (echo "Installing mas"; $(BREW_CMD) install mas)

MAS: INSTALL_MAS
	mas.sh $(INSTALL_PATH) || (echo "Error installing mas programs"; exit 1)

TEST:
	echo "testies"

INSTALL_ALL: INSTALL_OMZSH_THEMES INSTALL_FORMULAS INSTALL_PIP_PROGRAMS INSTALL_ASDF_PROGRAMS MAS


endif

# This allows an import of an extending Makefile in your Dotfiles directory
# At the end to allow overwriting of commands
-include $(DOTFILES_DIR)/Makefile

$(V).SILENT:
