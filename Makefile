# all: ADD_SUDO INSTALL_HOMEBREW POST_INSTALL_HOMEBREW INSTALL_YQ

USER := $(shell whoami)
export PATH:=/usr/local/bin:/opt/homebrew/bin:$(PATH)

IS_M1=$(shell uname -v | grep -i arm > /dev/null && echo true || echo false)
BREW_PREFIX=$(shell brew --prefix 2> /dev/null)
ifeq "$(IS_M1)" "true"
BREW=/opt/homebrew/bin/brew
BREW_CMD=arch -arm64 brew
else
BREW=/usr/local/bin/brew
BREW_CMD=brew
endif

OS=$(shell uname)

ifeq "$(OS)" "Darwin"

all: \
INSTALL_YQ INSTALL_FORMULAS INSTALL_CASKS \
TFENV_SETUP INSTALL_ASDF_PROGRAMS INSTALL_OMZSH_THEMES \
INSTALL_OMZSH_PLUGINS INSTALL_CASKS

ADD_SUDO:
	echo "Adding user to SUDOERS file"
	echo "$(USER)		ALL = (ALL) NOPASSWD: ALL" | sudo tee /private/etc/sudoers.d/$(USER)

DOTFILES:
	echo "Does nothing yet"

CURL_HOMEBREW: ADD_SUDO
	echo "Installing Homebrew"
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o install_homebrew.sh
	chmod +x install_homebrew.sh

INSTALL_HOMEBREW: | CURL_HOMEBREW
	NONINTERACTIVE=1 /bin/bash -c ./install_homebrew.sh

POST_INSTALL_HOMEBREW: | INSTALL_HOMEBREW
	if grep "brew shellenv" ~/.zprofile; then \
	echo 'Brew already in zprofile'; \
	else \
	echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile; \
	fi
	rm -f install_homebrew.sh
	echo "Homebrew installed"

INSTALL_YQ: | POST_INSTALL_HOMEBREW
	echo "Installing yq to parse the config file"
	$(BREW_CMD) install yq

INSTALL_OHMYZSH:
	sh -c "$$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

INSTALL_FORMULAS:
	echo "Installing Homebrew Formulas"
	FORMULAS="$(shell yq '.brew.formulas.[]' things.yaml)"; \
	for formula in $${FORMULAS}; do \
	$(BREW_CMD) install $$formula; \
	done

INSTALL_TAPS:
	echo "Installing Homebrew Taps"
	TAPS="$(shell yq '.brew.taps.[]' things.yaml)"; \
	for tap in $${TAPS}; do \
	  $(BREW_CMD) tap $${tap}; \
	done

INSTALL_CASKS:
	echo "Installing Casks"
	CASKS="$(shell yq '.brew.casks.[]' things.yaml)"; \
	for cask in $${CASKS}; do \
	  $(BREW_CMD) install --cask $${cask}; \
	done

TFENV_SETUP:
	tfenv install latest; \
	tfenv use latest

INSTALL_ASDF_PROGRAMS:
	PROGRAMS="$(shell yq '.asdf.[]' things.yaml)"; \
	for program in $${PROGRAMS}; do \
	asdf plugin add $$program; \
	asdf install $$program latest; \
	asdf global $$program latest; \
	done

endif

$(V).SILENT: