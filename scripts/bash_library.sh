#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PATH="${SCRIPT_DIR}/../bin:${PATH}"

# https://en.wikipedia.org/wiki/Syslog#Severity_level
LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")
function .log () {
  local LEVEL=${1}
  shift

  # Validate Verbosity is set, if not set to reasonable level
  if [ -z ${V+x} ]; then V=3; fi

  # Validate input is in correct format
  re='^[0-9]+$'
  if ! [[ ${V} =~ $re ]] ; then
    echo "[err] Log level setup incorrectly in input script (This is not an error with bash_library)" >&2; exit 1
  fi

  # Print with level added
  # shellcheck disable=SC2086
  if [ ${V} -ge ${LEVEL} ]; then
    echo "[${LOG_LEVELS[$LEVEL]}]" "$@"
  fi
}

function create_dir() {
  .log 7 "Running 'check_dir' from 'bash_library.sh'"
  dir="${1}"
  if [ -z ${2+x} ]; then runtime=1; else runtime=${2}; fi
  if [ "${runtime}" -ge 3 ]; then
    .log 2 "Attempted twice to create the directory (${dir}) and it has not worked"
    exit 1
  fi
  .log 7 "Input directory: ${dir}"
  if is-folder "${dir}"; then
    .log 6 "Input directory (${dir}) exists"
  else
    .log 6 "Input directory (${dir}) does not exist, creating"
    mkdir -p "${dir}" > /dev/null 2>&1
    .log 7 "Rerunning check_dir on ${dir}"
    check_dir "${dir}" $((runtime+1))
  fi
}

function check_yaml() {
  .log 7 "Running 'check_yaml' from 'bash_library.sh'"
  yamlfile="${1}"
  .log 7 "YAML File is '${yamlfile}'"
  if is-file "${yamlfile}"; then
    .log 6 "File ($yamlfile) found"
  else
    .log 3 "File ($yamlfile) not found, exiting"
    exit 1
  fi
}