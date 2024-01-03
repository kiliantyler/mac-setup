#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

yamlfile=$1

plugins=$(yq '.zsh.oh-my-zsh.plugins | to_entries | .[] | (.key + "|" +.value)' "$yamlfile")


for plugin in ${plugins}; do
    folder="$(echo $plugin | cut -f1 -d'|')"
    gitrepo="$(echo $plugin | cut -f2 -d'|')"
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${folder}" ]; then
        echo "Cloning ${folder}"
        git clone --depth=1 ${gitrepo} ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${folder}
    else
        echo "Updating ${folder}: "
        git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/${folder}" pull
    fi
done