#!/bin/bash

# https://en.wikipedia.org/wiki/Syslog#Severity_level
LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")
function .log () {
  local LEVEL=${1}
  shift

  # Validate Verbosity is set, if not set to reasonable level
  if [ -z ${V+x} ]; then V=2; fi

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