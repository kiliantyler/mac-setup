#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

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
ignoreFiles=("README.md" ".gitignore")
noStowList=("dotfiles_extention" ".ignore")

.log "Looping through folders in ${dotFolder}"
for dir in "${dotFolder}"/*; do
  stowNeeded=0
  .log -l 6 "------------------------------------"
  if ! is-folder "${dir}"; then
    .log "Not a directory {$dir}"
    continue
  fi
  .log "Working with Dir: ${dir}"
  if [[ "${noStowList[*]}" =~ $(basename "${dir}") ]]; then
    .log -l 6 "Skipping '${dir}' since it's on the noStowList"
    continue
  fi

  files=$(find_files "${dir}")
  .log "Files: (${files})"
  # Loop through the files that exist in that folder
  # Backup + Delete any files that exist
  # find_files runs in a Subshell -- Cannot exit from main process if anything goes wrong
  for file in ${files}; do
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
      continue
    fi
    homeFile="${HOME}/${file}"
    .log "Looking for ${homeFile}"
    if [ -f "${homeFile}" ]; then
      .log -l 6 "File (${homeFile}) exists already"
      expectedPath="${dir}/${file}"
      if [ -L "${homeFile}" ]; then
        .log -l 6 "File (${homeFile}) is already a symlink"
        .log "Discovering if ${homeFile} links to ${expectedPath}"
        if check_filelink "${homeFile}" "${expectedPath}"; then
          .log -l 6 "${homeFile} points to expected path (${expectedPath}) -- Nothing to do"
          continue
        else
          .log -l 4 "Link is set incorrectly, backing up and deleting"
          backup_file -d "${backupDir}/${internalDir}/${fileDir}" "${homeFile}"
          delete_file "${homeFile}"
          stowNeeded=1
        fi
      else
        .log -l 4 "File (${homeFile}) is NOT a symlink"
        if is-same "${homeFile}" "${expectedPath}"; then
          .log -l 6 "'${homeFile}' and '${expectedPath}' have the same contents, not backing up"
        else
          .log -l 6 "'${homeFile}' and '${expectedPath}' are different, backing up original"
          backup_file -d "${backupDir}/${internalDir}/${fileDir}" "${homeFile}"
        fi
        delete_file "${homeFile}"
        stowNeeded=1
      fi
    else
      .log -l 5 "File ($homeFile) does not exist yet"
      stowNeeded=1
    fi
  done
  # Finally run `stow` on that directory once we know all files are removed properly
  if is-true ${stowNeeded}; then
    stow_folder "${dotFolder}" "${internalDir}"
  else
    .log -l 5 "No stow needed for ${internalDir}"
  fi
done
