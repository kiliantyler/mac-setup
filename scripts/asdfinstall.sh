#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

yamlfile=$1

programs=$(yq '.asdf.[]' "${yamlfile}")
.log "Program list from '${yamlfile}' ${programs}"

IFS=$'\n'
for program in ${programs}; do
  .log "Input: '${program}'"
  if [[ "$program" == *":"* ]]; then
    .log "Program is splitable"
    executable=$(echo "${program}" | cut -f2 -d: | cut -c2-)
    program=$(echo "${program}" | cut -f1 -d:)
    .log "Executable: ${executable} | Program: ${program}"
  else
    .log "Program does not need to be split"
    executable="${program}"
  fi
  if ! bin/is-executable "${executable}"; then
    .log -l 5 "${executable} needs to be installed"
    .log -l 6 "asdf plugin add ${program}"
    asdf plugin add "${program}"
    .log -l 6 "asdf install ${program} latest"
    asdf install "${program}" latest
    .log -l 6 "asdf global ${program} latest"
    asdf global "${program}" latest
  else
    .log -l 6 "${executable} does not need to be installed"
  fi
done

exit 0
