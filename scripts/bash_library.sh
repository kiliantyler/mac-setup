#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PATH="${SCRIPT_DIR}/../bin:${PATH}"
libName="bash_library.sh"

# https://en.wikipedia.org/wiki/Syslog#Severity_level
LOG_LEVELS=([0]="EMERG " [1]="ALERT " [2]="CRIT  " [3]="ERROR " [4]="WARN  " [5]="NOTICE" [6]="INFO  " [7]="DEBUG ")
LOG_COLORS=([0]="red"    [1]="red"    [2]="red"    [3]="lred"    [4]="yellow" [5]="cyan"  [6]="green"  [7]="lgrey")
function .log () {
  local NOFAIL=0
  local LEVEL=7
  while [[ $# -gt 1 ]]; do
    local key="$1";
    case $key in
        -l|--level)
            LEVEL="$2"
            shift
        ;;
        -n|--no-exit)
            NOFAIL=1
        ;;
        *)
        ;;
    esac
    shift
  done

  # Validate Verbosity is set, if not set to reasonable level
  if [ -z ${V+x} ]; then V=3; fi

  # Validate input is in correct format
  re='^[0-9]+$'
  if ! [[ ${LEVEL} =~ $re ]] ; then
    local color
    color=$(color "red")
    echo "[error ] Log level setup incorrectly in input script (This is not an error with bash_library)" >&2; exit 1
  fi

  # Print with level added
  # shellcheck disable=SC2086
  if [ ${V} -ge ${LEVEL} ]; then
    local date
    date=$(date '+%Y-%m-%d %H:%M:%S')
    local color
    color=$(color ${LOG_COLORS[$LEVEL]})
    restore='\033[0m'
    echo -e "[${color}${LOG_LEVELS[$LEVEL]}${restore}][${date}]" "$1"
    if [ ${NOFAIL} -eq 0 ]; then
      if [ ${LEVEL} -lt 4 ]; then
      echo -e "[${color}${LOG_LEVELS[$LEVEL]}${restore}][${date}]" "NOFAIL not set, EXITING"
        exit 1
      fi
    fi
  fi
}

function create_dir() {
  .log -l 7 "Running 'check_dir' from '${libName}'"
  local dir="${1}"
  if [ -z ${2+x} ]; then runtime=1; else runtime=${2}; fi
  if [ "${runtime}" -ge 3 ]; then
    .log -l 2 "Attempted twice to create the directory (${dir}) and it has not worked"
  fi
  .log -l 7 "Input directory: ${dir}"
  if is-folder "${dir}"; then
    .log -l 6 "Input directory (${dir}) exists"
  else
    .log -l 6 "Input directory (${dir}) does not exist, creating"
    mkdir -p "${dir}" > /dev/null 2>&1
    .log -l 7 "Rerunning check_dir on ${dir}"
    create_dir "${dir}" $((runtime+1))
  fi
}

function check_yaml() {
  .log -l 7 "Running 'check_yaml' from '${libName}'"
  local yamlfile="${1}"
  .log -l 7 "YAML File is '${yamlfile}'"
  if is-file "${yamlfile}"; then
    .log -l 6 "File ($yamlfile) found"
  else
    .log -l 2 "File ($yamlfile) not found, exiting"
  fi
}

function color() {
  local color=${1}
  case "${color}" in
  "red")
    echo '\033[38;5;196m' ;;
  "lred")
    echo '\033[38;5;198m' ;;
  "green")
    echo '\033[38;5;10m' ;;
  "yellow")
    echo '\033[38;5;226m' ;;
  "lyellow")
    echo '\033[38;5;228m' ;;
  "cyan")
    echo '\033[38;5;6m' ;;
  "white")
    echo '\033[01;37m' ;;
  "lgrey")
    echo '\033[00;37m' ;;
  *) ;;
  esac
}

function backup_file() {
  .log -l 7 "Running backup_file from '${libName}'"
  if [ -z ${2+x} ]; then .log -l 3 "Arguments for 'backup_file' were not set correctly"; fi
  local file="${1}"
  local rootDir="${2}"
  echo " Nothing yet: ${file} ${rootDir}"
}

function check_filelink() {
  .log -l 7 "Running check_filelink from '${libName}'"
  if [ -z ${2+x} ]; then .log -l 3 "Arguments for 'check_filelink' were not set correctly"; fi
  local symLinkedFile=${1}
  local expectedPath=${2}
  if ! is-symlink "${symLinkedFile}"; then .log -l 3 "File (${symLinkedFile}) is not a Symlink!"; fi
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

.log -l 7 "Successfully sourced bash_library.sh"
scriptName="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
.log -l 7 "Running ${scriptName}"