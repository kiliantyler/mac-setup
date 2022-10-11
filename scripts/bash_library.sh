#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
mainDir=${SCRIPT_DIR%/*}
export PATH="${SCRIPT_DIR}/../bin:${PATH}"
libName="bash_library.sh"
scriptName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
logDir="${mainDir}/logs"
libraryBackupDir="${mainDir}/backup"
mkdir -p "${logDir}" >/dev/null 2>&1
logFile="${logDir}/${scriptName}.log"
dotFileDir=$(
  cd "${mainDir}" || exit 1
  make EXPORT_DOTFILES_DIR V=
)
installFile=$(
  cd "${mainDir}" || exit 1
  make EXPORT_INSTALLFILE V=
)
fullInstallFile="${dotFileDir}/${installFile}"
NOLOG=0

# https://en.wikipedia.org/wiki/Syslog#Severity_level
LOG_LEVELS=([0]="EMERG " [1]="ALERT " [2]="CRIT  " [3]="ERROR " [4]="WARN  " [5]="NOTICE" [6]="INFO  " [7]="DEBUG ")
LOG_COLORS=([0]="red" [1]="red" [2]="red" [3]="lred" [4]="yellow" [5]="cyan" [6]="green" [7]="lgrey")

# Input Params
# OPTIONAL: -l|--level = Level of Log from ${LOG_LEVELS} (default: '7' [DEBUG])
# OPTIONAL: -n|--no-exit = Do not fail even when above the CRIT (2) threshold (default: false)
# $@ = Log text to output
function .log() {
  # All locals so that variables are always reset
  local NOFAIL=0
  local LEVEL=7
  local subshellNum
  subshellNum="${BASH_SUBSHELL}"
  while [[ $# -gt 1 ]]; do
    local key="$1"
    case $key in
    -l | --level)
      LEVEL="$2"
      shift
      ;;
    -n | --no-exit) NOFAIL=1 ;;
    *) ;;
    esac
    shift
  done
  local message="${1}"
  local failMessage=" | NOFAIL not set, EXITING"
  # Validate Verbosity is set, if not set to reasonable level: Error (3)
  if [ -z ${V:+x} ]; then V=3; fi
  # Validate ${Level} is in correct format (INT 0-9)
  if ! is-int "${LEVEL}"; then
    local errorText="Log level setup incorrectly from input '${FUNCNAME[1]}' (This is not an error with '${FUNCNAME[0]}' nor '${libName}')"
    .log -l 2 "${errorText}"
  fi
  local failed=0
  if [ "${LEVEL}" -le 2 ]; then
    if [ ${NOFAIL} -eq 0 ]; then
      message="${message}${failMessage}"
      failed=1
    fi
  fi
  if [ ${V} -ge "${LEVEL}" ]; then
    logMessage="$(log_format "${LEVEL}" ""${subshellNum} "${message}")"
    # By sending this to /dev/tty we can use .log in functions that return text (like find_files)
    echo -e "${logMessage}" >/dev/tty
    if ! is-true ${NOLOG}; then
      echo -e "${output}" | decolor >>"${logFile}"
    fi
  fi
  if is-true ${failed}; then
    call_stack 1
    exit 1
  fi
}

call_stack() {
  local i=0
  local FRAMES=${#BASH_LINENO[@]}
  local OFFSET=${1:-0}
  # FRAMES-2 skips main, the last one in arrays
  for ((i = FRAMES - 2; i >= OFFSET; i--)); do
    echo "  File \"${BASH_SOURCE[i + 1]}\", line ${BASH_LINENO[i]}, in ${FUNCNAME[i + 1]}"
    # Grab the source code of the line
    sed -n "${BASH_LINENO[i]}{s/^[ \t]*/    /;p}" "${BASH_SOURCE[i + 1]}"
    # TODO extract arugments from "${BASH_ARGC[@]}" and "${BASH_ARGV[@]}"
    # It requires `shopt -s extdebug'
  done
}

# $1 = Level of log (used to determine color)
# $2 = Subshell Number
# $3 = Message
function log_format() {
  local LEVEL="${1}"
  local subshellNum="${2}"
  local message="${3}"
  local color
  local date
  date=$(date '+%Y-%m-%d %H:%M:%S')
  local restore
  restore=$(color "restore")
  local subshellText=""
  local dateText="[${date}]"
  local funcText="(${FUNCNAME[2]})"
  color=$(color "${LOG_COLORS[$LEVEL]}")
  local logLevelText="[${color}${LOG_LEVELS[$LEVEL]}${restore}]"
  if [ "${subshellNum}" -gt 0 ]; then color=$(color red) subshellText="{${color}SUBSHELL: ${subshellNum}${restore}}"; fi
  output="${logLevelText}${dateText}${subshellText}${funcText} ${message}"
  # Only log Date & Function if Info or Debug to tty
  if [ "${V}" -lt 6 ]; then
    dateText=""
    funcText=""
  fi
  output="${logLevelText}${dateText}${subshellText}${funcText} ${message}"
  echo -e "${output}"
}

# This must be second, the rest of the functions use it
# Input the *Last* needed argument from a function
# example: `init_func "${1}"` or `initFunc "${2}"` depending on arguments needed
function init_func() {
  .log "FUNC: '${FUNCNAME[1]}' from '${libName}'"
  if [ -z ${1:+x} ]; then .log -l 2 "Arguments for '${FUNCNAME[1]}' were not set correctly"; fi
  .log "Arguments for '${FUNCNAME[1]}' seemingly set correctly"
}

# $1 = directory to create
# OPTIONAL/INTERNAL $2 = Runtime attempts (default '1')
function create_dir() {
  init_func "${1}"
  local dir="${1}"
  if [ -z ${2:+x} ]; then runtime=1; else runtime=${2}; fi
  if [ "${runtime}" -ge 3 ]; then
    .log -l 2 "Attempted twice to create the directory (${dir}) and it has not worked"
  fi
  .log "Input directory: ${dir}"
  if is-folder "${dir}"; then
    .log -l 6 "Input directory (${dir}) exists"
  else
    .log -l 6 "Input directory (${dir}) does not exist, creating"
    mkdir -p "${dir}" >/dev/null 2>&1
    .log "Rerunning '${FUNCNAME[0]}' on ${dir}"
    ${FUNCNAME[0]} "${dir}" $((runtime + 1))
  fi
}

# $1 = file to check
function check_file() {
  init_func "${1}"
  local file="${1}"
  .log "File is '${file}'"
  if is-file "${file}"; then
    .log -l 6 "File ($file) found"
    return 0
  else
    .log -l 2 "File ($file) not found, exiting"
  fi
}

# $1 = file to be deleted
function delete_file() {
  init_func "${1}"
  local file="${1}"
  check_file "${file}"
  .log "Deleting '${file}'"
  if rm -f "${file}" >/dev/null 2>&1; then
    .log -l 5 "Deleted '${file}' successfully"
    return 0
  else
    .log -l 2 "Failed to delete '${file}'"
  fi
}

# $1 = file to copy (whole path)
# $2 = file copy destination (whole path)
function copy_file() {
  init_func "${2}"
  local filePreCopy="${1}"
  local filePostCopy="${2}"
  .log -l 6 "Copying '${filePreCopy}' -> '${filePostCopy}'"
  if cp -a "${filePreCopy}" "${filePostCopy}" >/dev/null 2>&1; then
    if check_file "${filePostCopy}"; then
      .log "${filePostCopy} copied successfully"
    fi
  else
    .log -l 2 "File (${filePreCopy}) failed to copy (${filePostCopy})"
  fi
}

# $1 = file to roll to an older backup
# $2 = copies to keep
# $3 = times run
function roll_file() {
  init_func "${3}"
  local orgFile="${1}"
  local copiesToKeep="${2}"
  local runTimes="${3}"
  local file="${orgFile}"
  if ! is-int "${copiesToKeep}"; then .log -l 2 "'copiesToKeep' not an INT"; fi
  if ! is-int "${runTimes}"; then .log -l 2 "'runTimes' not an INT"; fi
  if [ "${runTimes}" -gt 1 ]; then file="${orgFile}.$((runTimes - 1))"; fi
  if ! is-file "${file}"; then
    .log "File (${file}) not found, no roll needed"
    return 0
  fi
  .log -l 6 "File found '${file}"
  if [ "${runTimes}" -lt "${copiesToKeep}" ]; then
    if ${FUNCNAME[0]} "${orgFile}" "${copiesToKeep}" "$((runTimes + 1))"; then
      .log "${file} is ready to be rolled"
      copy_file "${file}" "${orgFile}.$((runTimes))"
      delete_file "${file}"
      return 0
    else
      .log -l 2 "'${FUNCNAME[0]} ${orgFile} ${copiesToKeep} $((runTimes + 1))' FAILED"
    fi
  fi
  .log "${file} needs to be deleted since it is the maximum backup number"
  delete_file "${file}"
  return 0
}

# $1 = File to backup
# Input Params
# OPTIONAL: --dir = Backup directory (default '${libraryBackupDir}')
# OPTIONAL: --count = Copies to keep (default '5')
function backup_file() {
  local count=5
  local backupDir=${libraryBackupDir}
  while [[ $# -gt 1 ]]; do
    local key="$1"
    case $key in
    -c | --count)
      count="${2}"
      shift
      ;;
    -d | --dir)
      backupDir="${2}"
      ;;
    *) ;;

    esac
    shift
  done
  init_func "${1}"
  local file="${1}"
  .log "Input file: '${file}'"
  .log "Backup directory set to '${backupDir}'"
  create_dir "${backupDir}"
  if ! is-file "${file}"; then .log -l 2 "File (${file}) not found, cannot continue"; fi
  local fileName
  fileName="$(basename "${file}")"
  .log "Filename found: '${fileName}'"
  backupFile="${backupDir}/${fileName}.old"
  roll_file "${backupFile}" "${count}" 1
  copy_file "${file}" "${backupFile}"
}

# $1 = File to check
# $2 = Expected path of symlink
function check_filelink() {
  init_func "${2}"
  local symLinkedFile=${1}
  local expectedPath=${2}
  if ! is-symlink "${symLinkedFile}"; then .log -l 2 "File (${symLinkedFile}) is not a Symlink!"; fi
  local symLinkLocation
  symLinkLocation=$(readlink -f "${symLinkedFile}")
  if [ "${symLinkLocation}" == "${expectedPath}" ]; then
    .log -l 6 "Symlinked file path (${symLinkLocation}) and expected path (${expectedPath}) match"
    return 0
  else
    .log -l 4 "Symlinked file path (${symLinkLocation}) does not match Expected path (${expectedPath})"
    return 1
  fi
}

# $1 = input directory to search
function find_files() {
  init_func "${1}"
  local dir="${1}"
  .log "Searching '${dir}'"
  find "${dir}" -type f -print
}

# $1 = source directory
# $2 = package to stow
# OPTIONAL: $3 = directory to stow INTO (default: ${HOME})
function stow_folder() {
  init_func "${1}"
  local dir="${1}"
  local package="${2}"
  .log "Looking to 'stow' directory '${dir}'"
  local stowDir="${HOME}"
  if [ -n "${3:+x}" ]; then stowDir=${3}; fi
  .log "Stowing files in '${stowDir}'"
  if ! is-folder "${dir}"; then .log -2 "'${dir}' is NOT a directory!"; fi
  if stow --no-folding -d "${dir}" -D "${package}"; then .log "Unstowed ${package}"; else .log -l 2 "stow -D ${package} FAILED"; fi
  if stow --no-folding -d "${dir}" -t "${stowDir}" "${package}"; then
    .log -l 5 "'${dir}/${package}' has been stowed successfully in '${stowDir}'"
  else
    .log -l 2 "'${dir}/${package}' unable to be stowed in '${stowDir}'"
  fi
}

# TODO: use this but don't spawn a subshell
# $1 = text to split
# OPTIONAL: $2 = the separator between the splits (default: ': ')
function split_key_value() {
  init_func "${1}"
  input="${1}"
  separator=": "
  if [ -n "${2:+x}" ]; then separator=${2}; fi
  .log "Input: ${input}, Seperator: ${separator}"
  local split1 split2
  if [[ "${input}" == *"${separator}"* ]]; then
    .log "Input (${input}) is splitable"
    split1=$(echo "${input}" | cut -f2 -d: | cut -c2-)
    split2=$(echo "${input}" | cut -f1 -d:)
  else
    .log "Input (${input}) does not need to be split"
    split1="${input}"
    split2="${input}"
  fi
  .log -l 1 "Split 1: ${split1} | Split 2: ${split2}"
  echo "${split1} ${split2}"
}

function brew_install() {
  init_func "${1}"
  app="${1}"
  if brew install "${app}"; then
    return 0
  else
    .log -l 3 "Could not brew install ${app}!"
  fi
}

function brew_uninstall() {
  init_func "${1}"
  app="${1}"
  if brew uninstall "${app}"; then
    return 0
  else
    .log -l 3 "Could not brew uninstall ${app}!"
  fi
}

# $1 = location in file to add to
# $2 = install to add
function add_install() {
  init_func "${2}"
  local yamlLocation="${1}"
  local installProgram="${2}"
  .log "${fullInstallFile}"
  if ! yq -I4 e "${yamlLocation} |= . + \"${installProgram}\"" "${fullInstallFile}" --inplace; then
    .log -l 2 "Could not add ${installProgram} to ${yamlLocation} in ${fullInstallFile}"
  fi
  yq -I4 e "${yamlLocation} |=  unique" "${fullInstallFile}" --inplace
}

# $1 = location in file to remove from
# $2 = install to remove
function remove_install() {
  init_func "${2}"
  local yamlLocation="${1}"
  local removeProgram="${2}"
  .log "${fullInstallFile}"
  if ! yq -I4 "del(${yamlLocation}.[] | select(. == \"${removeProgram}\"))" "${fullInstallFile}" --inplace; then
    .log -l 2 "Could not add ${removeProgram} to ${yamlLocation} in ${fullInstallFile}"
  fi
}

# Runs when file is sourced
function source_file() {
  NOLOG=1 roll_file "${logFile}" 5 1
  # Just to verify the log directory exists, fails if it cannot create
  create_dir "${logDir}"
  # Run some Debug logs on every script that sources
  .log "Successfully sourced ${libName}"
  .log -l 6 "Running script: ${scriptName}"
}
source_file
