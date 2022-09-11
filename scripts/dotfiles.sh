#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
mainDir=${SCRIPT_DIR%/*}
# shellcheck source=/dev/null
source "${mainDir}/scripts/bash_library.sh"

dotFolder="dotfiles"
ignoreFiles=("README.md" ".gitignore")

.log -l 7 "Looping through folders in ${dotFolder}"
for dir in "${dotFolder}"/*; do
  if [ ! -d "${dir}" ]; then
    .log -l 7 "Not a directory {$dir}"
    continue
  fi
  .log -l 7 "Working with Dir: ${dir}"
  find "${dir}" -type f -print0 | 
  while IFS= read -r -d '' file; do
    # shellcheck disable=SC2001
    file=$(echo "$file" | sed "s|${dir}/||")
    .log -l 6 "Found ${file}"
    if [[ "${ignoreFiles[*]}" =~ ${file} ]]; then
      .log -l 6 "Skipping $file since it's in 'ignoreFiles' list"
    fi
    homeFile="${HOME}/${file}"
    .log -l 7 "Looking for ${homeFile}"
    if [ -f "${homeFile}" ]; then
      .log -l 5 "File (${homeFile}) exists already"
      if [ -L "${homeFile}" ]; then
        .log -l 5 "File (${homeFile}) is already a symlink"
        expectedPath="${mainDir}/${dotFolder}/${file}"
        .log -l 7 "Discovering if ${homeFile} links to ${expectedPath}"
        if check_filelink "${homeFile}" "${expectedPath}"; then
          .log -l 1 "It's a match"
        fi
      else
        .log -l 4 "File (${homeFile}) is NOT a symlink"
        backup_file "${homeFile}" "${mainDir}"
      fi
    else
      .log -l 5 "File ($homeFile) does not exist"
    fi
  done
done