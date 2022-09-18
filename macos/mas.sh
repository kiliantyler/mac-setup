#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

yamlfile=$1

# Getting list here allow no subshell to be spawned for a while loop
programs=$(yq '.mas.[]' "${yamlfile}")
programList=$(mas list | sort -k2 | awk -F'(' '{print $1}')
# .log "Program list from '${yamlfile}':  ${programs}"

declare -a installedPrograms

IFS=$'\n'
for i in ${programList}; do
  key=$(awk 'BEGIN{split(ARGV[1],var," ");print var[1]}' "${i}")
  # echo "${key}"
  value="test"
  installedPrograms["${key}"]=${value}
done

function reset_appid() {
  declare -g appId
}

function check_appid() {
  init_func "${2}"
  reset_appid
  # local id="${1}"

  if is-int "${first}"; then
    appId="${first}"
    return
  else .log "Identifier ($first) is not an AppID"; fi
  if is-int "${second}"; then
    appId="${second}"
    return
  else .log "Identifier ($second) is not an AppID"; fi
  # if is-url "${first}"; then appId=$(extract_appid "${first}"); fi
}

# Setting IFS so we can have spaces in lines
IFS=$'\n'
for program in ${programs}; do
  .log "Input: '${program}'"
  if [[ "$program" == *":"* ]]; then
    .log "Program is splitable"
    first=$(echo "${program}" | cut -f2 -d: | cut -c2-)
    second=$(echo "${program}" | cut -f1 -d:)
    .log "Executable: ${first} | Program: ${second}"
  else
    .log "Program does not need to be split"
    first="${program}"
    second="${program}"
  fi
  check_appid "${first}" "${second}"
  # appId=check_appid "${first}" "${second}"
  echo "$appId"
  [ "${installedPrograms[${appId}]+x}" ] && echo "exists"

  # mas install "${appId}"
done
