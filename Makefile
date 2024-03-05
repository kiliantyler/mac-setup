include ./setup/Makefile

ALL: RUN_TASKS

DOTFILES: INSTALL_STOW
	dotfiles.sh || (echo "Error with dotfiles.sh"; exit 1)

ADD_SUDO:
	is-grep $(USER) $(SUDOERS_FILE) || (echo "$(USER)		ALL = (ALL) NOPASSWD: ALL" | sudo tee $(SUDOERS_FILE))

INSTALL_HOMEBREW: ADD_SUDO
	is-executable brew || (echo 'Installing Homebrew'; NONINTERACTIVE=1 /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")

INSTALL_GOTASK: | INSTALL_HOMEBREW
	is-executable task || (echo "Installing go-task"; $(BREW_CMD) install go-task)

RUN_TASKS: | INSTALL_GOTASK
	task hello || (echo 'Failed to run tasks using go-task')

# INSTALL_YQ: | INSTALL_HOMEBREW
# 	is-executable yq || (echo "Installing yq"; $(BREW_CMD) install yq)

# INSTALL_ASDF: | INSTALL_HOMEBREW
# 	is-executable asdf || (echo "Installing asdf"; $(BREW_CMD) install asdf)

# INSTALL_TFENV: | INSTALL_HOMEBREW
# 	is-executable tfenv || (echo "Installing tfenv"; $(BREW_CMD) install tfenv)

INSTALL_STOW: INSTALL_HOMEBREW
	is-executable stow || (echo 'Installing stow'; $(BREW_CMD) install stow)

# INSTALL_OHMYZSH:
# 	is-folder ~/.oh-my-zsh || (echo 'Installing Oh-my-zsh'; sh -c "$$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended)

INSTALL_OMZSH_THEMES: INSTALL_OHMYZSH INSTALL_YQ
	ohmyzshthemes.sh $(INSTALL_PATH) || (echo "Error installing ZSH Theme"; exit 1)

INSTALL_OMZSH_PLUGINS: INSTALL_OHMYZSH INSTALL_YQ
	ohmyzshplugins.sh $(INSTALL_PATH) || (echo "Error installing ZSH Plugins"; exit 1)


# CREATE_CODEFILE: INSTALL_YQ
# 	makecode.sh $(INSTALL_PATH) || (echo "Error creating Codefile"; exit 1)

# TFENV_SETUP: INSTALL_TFENV
# 	tfenv install $(TF_VER); \
# 	tfenv use $(TF_VER)

# INSTALL_PIPX: INSTALL_HOMEBREW
# 	is-executable pipx || (echo "Installing pipx"; pip3 install pipx)

# INSTALL_PIP_PROGRAMS: INSTALL_PIPX INSTALL_YQ
# 	PIPPROGRAMS="$(shell yq '.pip.[]' $(INSTALL_PATH))"; \
# 	for i in $${PIPPROGRAMS}; do pipx install $$i; done

# INSTALL_ASDF_PROGRAMS: INSTALL_ASDF INSTALL_YQ
# 	asdfinstall.sh $(INSTALL_PATH) || (echo "Error installing asdf programs"; exit 1)

# SETUP_1PASSWORD:
# 	macos/1password.sh

# INSTALL_MAS: INSTALL_HOMEBREW
# 	is-executable mas || (echo "Installing mas"; $(BREW_CMD) install mas)

# MAS: INSTALL_MAS INSTALL_YQ
# 	mas.sh $(INSTALL_PATH) || (echo "Error installing mas programs"; exit 1)

# INSTALL_ALL: INSTALL_FORMULAS INSTALL_ASDF_PROGRAMS INSTALL_OMZSH_THEMES INSTALL_OMZSH_PLUGINS INSTALL_PIP_PROGRAMS
# ifeq "$(OS)" "macos"
# ifneq "$(VIRTUAL)" "vm"
# INSTALL_ALL: MAS
# endif
# endif

# ZSH_SHELL:
# 	sudo chsh -s $(ZSH_LOCATION) $(USER)

# EXECUTE_ZSH:
# 	exec zsh

EXPORT_INSTALLFILE:
	echo $(INSTALL_FILE)

EXPORT_DOTFILES_DIR:
	echo $(DOTFILES_DIR)

# # This allows an import of an extending Makefile in your Dotfiles directory
# # At the end to allow overwriting of commands
# -include $(DOTFILES_DIR)/Makefile

$(V).SILENT:
