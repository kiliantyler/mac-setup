#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

yamlfile=$1

# Getting list here allow no subshell to be spawned for a while loop
programs=$(yq '.mas.[]' "${yamlfile}")
.log "Program list from '${yamlfile}':  ${programs}"
declare -a installedPrograms

function get_installed() {
  programList=$(mas list | sort -k2 | awk -F'(' '{print $1}')

  IFS=$'\n'
  for i in ${programList}; do
    key=$(awk 'BEGIN{split(ARGV[1],var," ");print var[1]}' "${i}")
    # value=$(awk 'BEGIN{split(ARGV[1],var," ");for (c=2; c<=NF; c++) printf var[c]; print $NF}' "${i}")
    value=$(echo "${i}" | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}')
    installedPrograms["${key}"]="${value}"
  done
}

function reset_appid() {
  appId=""
}

function appid_isint() {
  if [ -n "${appId:+x}" ]; then return; fi
  init_func "${1}"
  if is-int "${1}"; then
    .log "Found suspected AppID (${1})"
    appId="${1}"
  else
    .log "Identifier ($1) is not an AppID"
  fi
}

function appid_isurl() {
  if [ -n "${appId:+x}" ]; then return; fi
  init_func "${1}"
  if is-url "${1}"; then
    .log "Found URL (${1})"
    extract_appid "${1}"
  fi
}

function extract_appid() {
  init_func "${1}"
  lastPath="${1##*/}"
  removedParams="${lastPath%%\?*}"
  if [[ ${removedParams} =~ ^id* ]]; then
    .log "Found 'id' in string '${removedParams}"
    appId=${removedParams:2}
  else
    .log "Did not find 'id' in string '${removedParams}"
    appId=${removedParams}
  fi
}

function check_appid() {
  init_func "${1}"
  reset_appid
  appid_isint "${1}"
  appid_isurl "${1}"
}

function get_appname() {
  programName=""
  programInfo=$(mas info "${appId}" 2>&1)
  firstLine=$(echo "${programInfo}" | head -1)
  programName=$(echo "${firstLine}" | awk 'NF{NF-=2}1')
}

get_installed

# Setting IFS so we can have spaces in lines
IFS=$'\n'
for program in ${programs}; do
  .log "Input: '${program}'"
  if ! is-url "${program}" && [[ "$program" == *":"* ]]; then
    .log "Program is splitable"
    first=$(echo "${program}" | cut -f1 -d: | xargs)
    second=$(echo "${program}" | cut -f2- -d: | xargs)
    .log "First: ${first} | Second: '${second}'"
    check_appid "${first}"
    check_appid "${second}"
  else
    .log "Program does not need to be split"
    check_appid "${program}"
  fi
  if [ -n "${appId:+x}" ]; then
    .log "AppID: '${appId}'"
  else
    .log -l 3 "AppID not found for ${program}"
    continue
  fi
  if [ "${installedPrograms[${appId}]+x}" ]; then
    .log -l 5 "${installedPrograms[${appId}]} already installed"
    continue
  fi
  if get_appname "${appId}"; then
    .log -l 5 "'${programName}' is going to be installed"
  else
    .log -l 3 "${appId} not found in AppStore"
    continue
  fi
  if mas install "${appId}"; then
    .log -l 5 "'${programName}' has been installed"
  else
    .log -l 3 "'${programName}' installed failed!"
  fi
done
