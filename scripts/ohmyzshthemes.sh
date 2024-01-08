#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

yamlfile=$1

themes=$(yq '.zsh.oh-my-zsh.themes | to_entries | .[] | (.key + "|" +.value)' "$yamlfile")


for theme in ${themes}; do
    echo "Theme: ${theme}"
    folder="$(echo $theme | cut -f1 -d'|')"
    gitrepo="$(echo $theme | cut -f2 -d'|')"
    echo "Folder: ${folder}, GitRepo: ${gitrepo}"
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/${folder}" ]; then
        echo "Cloning ${folder}"
        git clone --depth=1 ${gitrepo} ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/${folder}
    else
        echo "Updating ${folder}: "
        git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/${folder}" pull
    fi
done
