# dotfiles-example

## dotfiles
This is the general idea on how your `dotfiles` repo should be set up

All files in folders will be backed up if they exist, deleted, then symlinked to the file in the `dotfiles` directory
This allows you to keep all of your config files in source control, keeping then in sync with your various machines or in event of restore you have a simple way to start again.

## installs.yaml
This lets the `Makefile` know what to install for the various commands
Every section isn't manditory, but without a `brew` section you can't install homebrew formulas
