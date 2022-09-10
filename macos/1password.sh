#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/../scripts/bash_library.sh"

agentSock="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
dotFolder="${HOME}/.1password"
shortSock="${dotFolder}/agent.sock"

if [ ! -d "${dotFolder}" ]; then
  .log 5 "${dotFolder} does not exist, creating"
  mkdir -p "${dotFolder}"
fi

shorthandSockExists=0
shorthandSockSymLink=0
symOrgFile="/dev/null"
if [ -a  "${shortSock}" ]; then
  shorthandSockExists=1
  .log 7 "${shortSock} exists, continuing"
  if [ -L "${shortSock}" ]; then
    shorthandSockSymLink=1
    .log 7 "${shortSock} is a symlink already, continuing"
    symOrgFile=$(readlink -f "${shortSock}")
  fi
fi

if [ -a  "${agentSock}" ]; then
  .log 7 "${agentSock} exists, continuing"
else
  echo "Original 1password Agent does not exist, cannot continue"
  exit 1
fi

if [ ${shorthandSockSymLink} -eq 1 ]; then
  if [ "${symOrgFile}" == "${agentSock}" ]; then
    .log 7 "Symlink already exists, nothing to do"
    .log 7 "${shortSock} -> ${agentSock}"
    exit 0
  else
    .log 5 "Symlink does not match expected target, unlinking"
    unlink "${shortSock}"
  fi 
else
  if [ ${shorthandSockExists} -eq 1 ]; then
    .log 1 "Sock file (${shortSock}) is not a symlink, cannot continue"
    exit 1
  fi
fi

unlink "${shortSock}" > /dev/null 2>&1
.log 6 "Creating symlink from ${shortSock} to ${agentSock}"
ln -s "${agentSock}" "${shortSock}"
exit 0