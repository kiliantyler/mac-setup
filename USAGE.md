# Usage

### Sample usage:
There needs to be 2 separate folders for this to work
1. This repo
2. dotfiles directory to read from (default `${HOME}/dotfiles`)

`git clone https://github.com/kiliantyler/mac-setup`

`git clone <dotfilesRepo> ~/dotfiles`

(or `mkdir ~/dotfiles && cd ~/dotfiles && git init` for a new repo)

### dotfiles Repo Structure Example
`dotfiles` folder should live in `${HOME}/dotfiles`
```
dotfiles
├── README.md
├── installs.yaml # Used for installing software
├── powerlevel10k # `stow` package folder
│   └── .p10k.zsh # Actual dotfile to be symlinked
└── pre-commit
    └── .git-template
        └── hooks
            └── pre-commit
```

### installs.yaml
Example here: [installs.yaml](https://github.com/kiliantyler/mac-setup/blob/main/dotfiles_example/installs.yaml)

### Example commands
```
# This reads from `${HOME}/dotfiles/installs.yaml` 'brew' section
❯ make INSTALL_FORMULAS

# This symlinks files from `${HOME}/dotfiles/${directory}` to `$HOME`
❯ make DOTFILES

❯ make TFENV_SETUP
Terraform v1.2.9 is already installed
Switching default version to v1.2.9
Default version (when not overridden by .terraform-version or TFENV_TERRAFORM_VERSION) is now: 1.2.9

❯ make TFENV_SETUP TF_VER=1.2.0
Installing Terraform v1.2.0
Downloading release tarball from https://releases.hashicorp.com/terraform/1.2.0/terraform_1.2.0_darwin_arm64.zip
############### 100.0%
Downloading SHA hash file from https://releases.hashicorp.com/terraform/1.2.0/terraform_1.2.0_SHA256SUMS
Not instructed to use Local PGP (/opt/homebrew/Cellar/tfenv/3.0.0/use-{gpgv,gnupg}) & No keybase install found, skipping OpenPGP signature verification
Archive:  /var/folders/9w/np5w8s8d7rs0j83mcvwtny300000gn/T/tfenv_download.XXXXXX.FqNfrCGa/terraform_1.2.0_darwin_arm64.zip
  inflating: /opt/homebrew/Cellar/tfenv/3.0.0/versions/1.2.0/terraform
Installation of terraform v1.2.0 successful. To make this your default version, run 'tfenv use 1.2.0'
Switching default version to v1.2.0
```

### Verbosity
Everything has been written with logging in mind -- You want to know what these scripts are doing.

Running any `make` command with `V=#` (0-7) after it will give you generous logs of everything that is happening.

* `V=0` being the least verbose
* `V=3` being the default
* `V=7` being the most verbose (lots and lots of info)

By default everything is logged in `./logs` and is _per_ script/function

Running `DOTFILES` with `V=6`
```
❯ make DOTFILES V=6
is-grep kilian /private/etc/sudoers.d/kilian || (echo "kilian		ALL = (ALL) NOPASSWD: ALL" | sudo tee /private/etc/sudoers.d/kilian)
is-executable brew || (echo 'Installing Homebrew'; NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")
is-grep "/opt/homebrew/bin/brew" /Users/kilian/.zprofile || (echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' | tee -a ~/.zprofile)
is-executable stow || (echo 'Installing stow'; arch -arm64 brew install stow)
dotfiles.sh || (echo "Error with dotfiles.sh"; exit 1)
[INFO  ][2022-09-12 09:45:08](create_dir): Input directory (/Users/kilian/Documents/GitHub/mac-setup/logs) exists
[INFO  ][2022-09-12 09:45:09](main): Filename: .p10k.zsh
[NOTICE][2022-09-12 09:45:09](main): File (/Users/kilian/.p10k.zsh) exists already
[NOTICE][2022-09-12 09:45:09](main): File (/Users/kilian/.p10k.zsh) is already a symlink
[INFO  ][2022-09-12 09:45:09](check_filelink): Symlinked file path (/Users/kilian/dotfiles/powerlevel10k/.p10k.zsh) and expected path (/Users/kilian/dotfiles/powerlevel10k/.p10k.zsh) match
[INFO  ][2022-09-12 09:45:09](main): /Users/kilian/.p10k.zsh points to expected path (/Users/kilian/dotfiles/powerlevel10k/.p10k.zsh) -- Nothing to do
[INFO  ][2022-09-12 09:45:09](stow_folder): '/Users/kilian/dotfiles/powerlevel10k' has been stowed successfully in '/Users/kilian'
[INFO  ][2022-09-12 09:45:10](main): Filename: .git-template/hooks/pre-commit
[NOTICE][2022-09-12 09:45:10](main): File (/Users/kilian/.git-template/hooks/pre-commit) exists already
[NOTICE][2022-09-12 09:45:10](main): File (/Users/kilian/.git-template/hooks/pre-commit) is already a symlink
[INFO  ][2022-09-12 09:45:10](check_filelink): Symlinked file path (/Users/kilian/dotfiles/pre-commit/.git-template/hooks/pre-commit) and expected path (/Users/kilian/dotfiles/pre-commit/.git-template/hooks/pre-commit) match
[INFO  ][2022-09-12 09:45:10](main): /Users/kilian/.git-template/hooks/pre-commit points to expected path (/Users/kilian/dotfiles/pre-commit/.git-template/hooks/pre-commit) -- Nothing to do
[INFO  ][2022-09-12 09:45:10](stow_folder): '/Users/kilian/dotfiles/pre-commit' has been stowed successfully in '/Users/kilian'
```

Running `DOTFILES` with `V=7`
```
❯ make DOTFILES V=7
is-grep kilian /private/etc/sudoers.d/kilian || (echo "kilian		ALL = (ALL) NOPASSWD: ALL" | sudo tee /private/etc/sudoers.d/kilian)
is-executable brew || (echo 'Installing Homebrew'; NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")
is-grep "/opt/homebrew/bin/brew" /Users/kilian/.zprofile || (echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' | tee -a ~/.zprofile)
is-executable stow || (echo 'Installing stow'; arch -arm64 brew install stow)
dotfiles.sh || (echo "Error with dotfiles.sh"; exit 1)
[DEBUG ][2022-09-12 09:43:17](init_func): FUNC: 'create_dir' from 'bash_library.sh'
[DEBUG ][2022-09-12 09:43:17](init_func): Arguments for 'create_dir' seemingly set correctly
[DEBUG ][2022-09-12 09:43:17](create_dir): Input directory: /Users/kilian/Documents/GitHub/mac-setup/logs
[INFO  ][2022-09-12 09:43:17](create_dir): Input directory (/Users/kilian/Documents/GitHub/mac-setup/logs) exists
[DEBUG ][2022-09-12 09:43:17](source_file): Successfully sourced bash_library.sh
[DEBUG ][2022-09-12 09:43:17](source_file): Running script: dotfiles.sh
[DEBUG ][2022-09-12 09:43:17](main): Looping through folders in /Users/kilian/dotfiles
[DEBUG ][2022-09-12 09:43:17](main): ------------------------------------
[DEBUG ][2022-09-12 09:43:17](main): Not a directory {/Users/kilian/dotfiles/README.md}
[DEBUG ][2022-09-12 09:43:17](main): ------------------------------------
[DEBUG ][2022-09-12 09:43:17](main): Not a directory {/Users/kilian/dotfiles/installs.yaml}
[DEBUG ][2022-09-12 09:43:17](main): ------------------------------------
[DEBUG ][2022-09-12 09:43:17](main): Working with Dir: /Users/kilian/dotfiles/powerlevel10k
[DEBUG ][2022-09-12 09:43:17]{SUBSHELL: 1}(init_func): FUNC: 'find_files' from 'bash_library.sh'
[DEBUG ][2022-09-12 09:43:17]{SUBSHELL: 1}(init_func): Arguments for 'find_files' seemingly set correctly
[DEBUG ][2022-09-12 09:43:17]{SUBSHELL: 1}(find_files): Searching '/Users/kilian/dotfiles/powerlevel10k'
[DEBUG ][2022-09-12 09:43:17](main): ------------------
[INFO  ][2022-09-12 09:43:17](main): Filename: .p10k.zsh
[DEBUG ][2022-09-12 09:43:17](main): Internal directory structure: powerlevel10k
[DEBUG ][2022-09-12 09:43:17](main): Looking for /Users/kilian/.p10k.zsh
[NOTICE][2022-09-12 09:43:17](main): File (/Users/kilian/.p10k.zsh) exists already
[NOTICE][2022-09-12 09:43:17](main): File (/Users/kilian/.p10k.zsh) is already a symlink
[DEBUG ][2022-09-12 09:43:17](main): Discovering if /Users/kilian/.p10k.zsh links to /Users/kilian/dotfiles/powerlevel10k/.p10k.zsh
[DEBUG ][2022-09-12 09:43:17](init_func): FUNC: 'check_filelink' from 'bash_library.sh'
[DEBUG ][2022-09-12 09:43:17](init_func): Arguments for 'check_filelink' seemingly set correctly
[INFO  ][2022-09-12 09:43:17](check_filelink): Symlinked file path (/Users/kilian/dotfiles/powerlevel10k/.p10k.zsh) and expected path (/Users/kilian/dotfiles/powerlevel10k/.p10k.zsh) match
[INFO  ][2022-09-12 09:43:17](main): /Users/kilian/.p10k.zsh points to expected path (/Users/kilian/dotfiles/powerlevel10k/.p10k.zsh) -- Nothing to do
[DEBUG ][2022-09-12 09:43:17](init_func): FUNC: 'stow_folder' from 'bash_library.sh'
[DEBUG ][2022-09-12 09:43:17](init_func): Arguments for 'stow_folder' seemingly set correctly
[DEBUG ][2022-09-12 09:43:18](stow_folder): Looking to 'stow' directory '/Users/kilian/dotfiles'
[DEBUG ][2022-09-12 09:43:18](stow_folder): Stowing files in '/Users/kilian'
[INFO  ][2022-09-12 09:43:18](stow_folder): '/Users/kilian/dotfiles/powerlevel10k' has been stowed successfully in '/Users/kilian'
[DEBUG ][2022-09-12 09:43:18](main): ------------------------------------
[DEBUG ][2022-09-12 09:43:18](main): Working with Dir: /Users/kilian/dotfiles/pre-commit
[DEBUG ][2022-09-12 09:43:18]{SUBSHELL: 1}(init_func): FUNC: 'find_files' from 'bash_library.sh'
[DEBUG ][2022-09-12 09:43:18]{SUBSHELL: 1}(init_func): Arguments for 'find_files' seemingly set correctly
[DEBUG ][2022-09-12 09:43:18]{SUBSHELL: 1}(find_files): Searching '/Users/kilian/dotfiles/pre-commit'
[DEBUG ][2022-09-12 09:43:18](main): ------------------
[INFO  ][2022-09-12 09:43:18](main): Filename: .git-template/hooks/pre-commit
[DEBUG ][2022-09-12 09:43:18](main): Internal directory structure: pre-commit
[DEBUG ][2022-09-12 09:43:18](main): Looking for /Users/kilian/.git-template/hooks/pre-commit
[NOTICE][2022-09-12 09:43:18](main): File (/Users/kilian/.git-template/hooks/pre-commit) exists already
[NOTICE][2022-09-12 09:43:18](main): File (/Users/kilian/.git-template/hooks/pre-commit) is already a symlink
[DEBUG ][2022-09-12 09:43:18](main): Discovering if /Users/kilian/.git-template/hooks/pre-commit links to /Users/kilian/dotfiles/pre-commit/.git-template/hooks/pre-commit
[DEBUG ][2022-09-12 09:43:18](init_func): FUNC: 'check_filelink' from 'bash_library.sh'
[DEBUG ][2022-09-12 09:43:18](init_func): Arguments for 'check_filelink' seemingly set correctly
[INFO  ][2022-09-12 09:43:18](check_filelink): Symlinked file path (/Users/kilian/dotfiles/pre-commit/.git-template/hooks/pre-commit) and expected path (/Users/kilian/dotfiles/pre-commit/.git-template/hooks/pre-commit) match
[INFO  ][2022-09-12 09:43:18](main): /Users/kilian/.git-template/hooks/pre-commit points to expected path (/Users/kilian/dotfiles/pre-commit/.git-template/hooks/pre-commit) -- Nothing to do
[DEBUG ][2022-09-12 09:43:18](init_func): FUNC: 'stow_folder' from 'bash_library.sh'
[DEBUG ][2022-09-12 09:43:18](init_func): Arguments for 'stow_folder' seemingly set correctly
[DEBUG ][2022-09-12 09:43:18](stow_folder): Looking to 'stow' directory '/Users/kilian/dotfiles'
[DEBUG ][2022-09-12 09:43:18](stow_folder): Stowing files in '/Users/kilian'
[INFO  ][2022-09-12 09:43:18](stow_folder): '/Users/kilian/dotfiles/pre-commit' has been stowed successfully in '/Users/kilian'
```
