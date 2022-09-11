# mac-setup

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
![maintained - yes](https://img.shields.io/badge/maintained-yes-blue)
[![contributions - welcome](https://img.shields.io/badge/contributions-welcome-blue)](/CONTRIBUTING.md "Go to contributions doc")
![Kilian - Approved](https://img.shields.io/badge/Kilian-Approved-blue)

[![OS - macOS](https://img.shields.io/badge/OS-macOS-blue?logo=apple&logoColor=white)](https://www.apple.com/macos/ "Go to Apple homepage")
![CMake](https://img.shields.io/badge/CMake-%23008FBA.svg?logo=cmake&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-%23121011.svg?logo=gnu-bash&logoColor=white)
![VS Code](https://img.shields.io/badge/VS%20Code-0078d7.svg?logo=visual-studio-code&logoColor=white)
![ESLint](https://img.shields.io/badge/ESLint-4B3263?logo=eslint&logoColor=white)

#### Table of Contents
<!--TOC-->

- [Installation](#installation)
- [File Contents](#file-contents)
  - [Makefile](#makefile)
    - [DOTFILES:](#dotfiles)
    - [ADD_SUDO:](#add_sudo)
    - [INSTALL_HOMEBREW:](#install_homebrew)
    - [POST_INSTALL_HOMEBREW:](#post_install_homebrew)
    - [INSTALL_YQ:](#install_yq)
    - [INSTALL_STOW:](#install_stow)
    - [INSTALL_OHMYZSH:](#install_ohmyzsh)
    - [INSTALL_OMZSH_THEMES:](#install_omzsh_themes)
    - [INSTALL_OMZSH_PLUGINS:](#install_omzsh_plugins)
    - [INSTALL_FORMULAS:](#install_formulas)
    - [CREATE_BREWFILE:](#create_brewfile)
    - [CREATE_CODEFILE:](#create_codefile)
    - [TFENV_SETUP:](#tfenv_setup)
    - [INSTALL_PIPX:](#install_pipx)
    - [INSTALL_PIP_PROGRAMS:](#install_pip_programs)
    - [INSTALL_ASDF_PROGRAMS:](#install_asdf_programs)
    - [SETUP_1PASSWORD:](#setup_1password)
  - [Helper executables](#helper-executables)
    - [decolor](#decolor)
    - [is-arm64](#is-arm64)
    - [is-executable](#is-executable)
    - [is-file](#is-file)
    - [is-folder](#is-folder)
    - [is-grep](#is-grep)
    - [is-macos](#is-macos)
    - [is-supported](#is-supported)
    - [is-symlink](#is-symlink)
  - [Helper scripts](#helper-scripts)
    - [bash_library.sh](#bash_librarysh)
    - [asdfinstall](#asdfinstall)
    - [makebrew.sh](#makebrewsh)
    - [makecode.sh](#makecodesh)
  - [MacOS Scripts](#macos-scripts)
    - [1password.sh](#1passwordsh)
    - [dock.sh](#docksh)
    - [finder.sh](#findersh)
    - [generic.sh](#genericsh)
    - [mas.sh](#massh)

<!--TOC-->

## Installation

## File Contents

### Makefile

###### DOTFILES:
Copies config files from the `dotfiles` directory into their respective locations. This is a separate repo to allow others to use this easily

###### ADD_SUDO:
Adds yourself as a sudoer with NOPASSWD enabled

###### INSTALL_HOMEBREW:
Installs homebrew from brew.sh using their install script

###### POST_INSTALL_HOMEBREW:
Temporarialy installs the `brew` shim to `.zprofile` so the rest of the makefile works before symlinking dotfiles (Needs to install `stow` using homebrew to do the symlinking)

###### INSTALL_YQ:
`yq` is a YAML compliant version of `jq` -- `things.yaml` is read using this

###### INSTALL_STOW:
`stow` helps with the symlinking of dotfiles

###### INSTALL_OHMYZSH:
ZSH Plugin/Theme manager

###### INSTALL_OMZSH_THEMES:
Installs Oh-my-zsh Themes defined in `things.yaml`

###### INSTALL_OMZSH_PLUGINS:
Installs Oh-my-zsh plugins defined in `things.yaml`

###### INSTALL_FORMULAS:
Installs all formulas/taps/casks using homebrew

###### CREATE_BREWFILE:
Helper for `INSTALL_FORMULAS` -- creates a Brewfile to pass in so that it does not have to install 1 at a time

###### CREATE_CODEFILE:
[Unused] Eventually will install VSCode extensions

###### TFENV_SETUP:
Installs/uses latest version of terraform

###### INSTALL_PIPX:
Install `pipx` using `pip` -- so that all pip installs will use `pipx`

###### INSTALL_PIP_PROGRAMS:
Installs all pip programs listed in `things.yaml` using `pipx`

###### INSTALL_ASDF_PROGRAMS:
Installs all tools listed in `things.yaml` for `asdf` and uses the latest version of each (`asdf` needs to be in `brew` installs)

###### SETUP_1PASSWORD:
Sets up the `agent.sock` symlink for 1Password -- this allows a Unix normal version of the `agent.sock` to be used for SSH Keys

---

### Helper executables
Located in the `bin` directory, *most* return true (`exit 0`) or false (`exit 1`)

###### decolor
Strips color coding from echo statements (used for logging)

###### is-arm64
Checks if the mac running the makefile is `ARM64` or not (`intel`)

###### is-executable
Checks if input program is installed and executable

###### is-file
Checks if input file exists

###### is-folder
Checks if input folder exists

###### is-grep
Greps for string (`$1`) in file (`$2`)

###### is-macos
Verifies if running on `macos` or not (`linux`/`wsl2`)

###### is-supported
Runs `eval` on input program to see if it runs

###### is-symlink
Checks if a file is a symlink or not

---

### Helper scripts
Located in `scripts` -- run various things, like installs or checks

###### bash_library.sh
functions for other scripts

###### asdfinstall
Installs asdf programs from `things.yaml` and sets them as global default to the latest

###### makebrew.sh
Creates a `brew` readable `Brewfile` from `things.yaml`

###### makecode.sh
Creates a `codefile` from `things.yaml` for future VSCode use

---

### MacOS Scripts

###### 1password.sh
Setup 1password to be usable by SSH for keys

###### dock.sh
Sets up the dock in the way that is most productive (for me)

###### finder.sh
[Unused] Sets up finder in the way that is most productive (for me)

###### generic.sh
Various other Mac toggles

###### mas.sh
[Unused] Mac App Store installer, if `mas` gets updated to work with Ventura then this will function
