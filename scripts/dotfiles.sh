#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
mainDir=${SCRIPT_DIR%/*}
# shellcheck source=/dev/null
source "${mainDir}/scripts/bash_library.sh"

dotFolder="${HOME}/dotfiles"
backupDir="${HOME}/.dotfiles_backup"

while [[ $# -gt 1 ]]; do
  key="$1"
  case $key in
  -s | --source)
    dotFolder="$2"
    shift
    ;;
  -b | --backup)
    backupDir="${2}"
    shift
    ;;
  *) ;;

  esac
  shift
done

# Strip trailing slash if exists
# shellcheck disable=SC2001
dotFolder=$(echo "${dotFolder}" | sed 's:/*$::')
# .log -l 2 "Using '${dotFolder}' as source for dotfiles"

ignoreFiles=("README.md" ".gitignore")

.log "Looping through folders in ${dotFolder}"
for dir in "${dotFolder}"/*; do
  .log "------------------------------------"
  if ! is-folder "${dir}"; then
    .log "Not a directory {$dir}"
    continue
  fi
  .log "Working with Dir: ${dir}"
  # Loop through the files that exist in that folder
  # Backup + Delete any files that exist
  # find_files runs in a Subshell -- Cannot exit from main process if anything goes wrong

  for file in $(find_files "${dir}"); do
    .log "------------------"
    # shellcheck disable=SC2001
    file=$(echo "${file}" | sed "s|${dir}/||")
    .log -l 6 "Filename: ${file}"
    # shellcheck disable=SC2001
    internalDir=$(echo "${dir}" | sed "s|${dotFolder}/||")
    .log "Internal directory structure: ${internalDir}"
    fileDir=$(dirname "${file}")
    if [[ "${ignoreFiles[*]}" =~ ${file} ]]; then
      .log -l 6 "Skipping $file since it's in 'ignoreFiles' list"
    fi
    homeFile="${HOME}/${file}"
    .log "Looking for ${homeFile}"
    if [ -f "${homeFile}" ]; then
      .log -l 5 "File (${homeFile}) exists already"
      expectedPath="${mainDir}/${dir}/${file}"
      if [ -L "${homeFile}" ]; then
        .log -l 5 "File (${homeFile}) is already a symlink"
        .log "Discovering if ${homeFile} links to ${expectedPath}"
        if check_filelink "${homeFile}" "${expectedPath}"; then
          .log -l 6 "${homeFile} points to expected path (${expectedPath}) -- Nothing to do"
          continue
        else
          .log -l 3 "Link is set incorrectly"
          # TODO: link is set incorrectly
          # Set a linked file in the backup folder to the existing link
        fi
      else
        .log -l 4 "File (${homeFile}) is NOT a symlink"
        if is-same "${homeFile}" "${expectedPath}"; then
          .log -l 6 "'${homeFile}' and '${expectedPath}' have the same contents, not backing up"
        else
          .log -l 6 "'${homeFile}' and '${expectedPath}' are different, backing up original"
          backup_file -d "${backupDir}/${internalDir}/${fileDir}" "${homeFile}"
        fi
        # delete_file "${homeFile}"
      fi
    else
      .log -l 5 "File ($homeFile) does not exist"
    fi
  done
  # Finally run `stow` on that directory once we know all files are removed properly
  stow_folder "${dir}"
done
