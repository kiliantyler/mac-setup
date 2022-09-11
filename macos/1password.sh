#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/../scripts/bash_library.sh"

agentSock="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
dotFolder="${HOME}/.1password"
shortSock="${dotFolder}/agent.sock"

if [ ! -d "${dotFolder}" ]; then
  .log -l 5 "${dotFolder} does not exist, creating"
  mkdir -p "${dotFolder}"
fi

shorthandSockExists=0
shorthandSockSymLink=0
if [ -a  "${shortSock}" ]; then
  shorthandSockExists=1
  .log -l 6 "${shortSock} exists, continuing"
  if is-symlink "${shortSock}"; then
    shorthandSockSymLink=1
    .log -l 6 "${shortSock} is a symlink already, continuing"
  fi
fi

if [ -a  "${agentSock}" ]; then
  .log -l 6 "${agentSock} exists, continuing"
else
  .log -l 2 "Original 1password agent.sock (${agentSock}) does not exist, cannot continue"
fi

if [ ${shorthandSockSymLink} -eq 1 ]; then
  if check_filelink "${shortSock}" "${agentSock}"; then
    .log -l 5 "Symlink already exists, nothing to do"
    .log -l 6 "${shortSock} -> ${agentSock}"
    exit 0
  else
    .log -l 5 "Symlink does not match expected target, unlinking"
    unlink "${shortSock}"
  fi
else
  if [ ${shorthandSockExists} -eq 1 ]; then
    .log -l 2 "Sock file (${shortSock}) is not a symlink, cannot continue"
  fi
fi

unlink "${shortSock}" > /dev/null 2>&1
.log -l 5 "Creating symlink from ${shortSock} to ${agentSock}"
ln -s "${agentSock}" "${shortSock}"
exit 0
