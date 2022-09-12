#!/usr/bin/env bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/../scripts/bash_library.sh"

yamlfile=$1

"${yamlfile}"

yq '.asdf.[]' "${yamlfile}" | while read -r program; do
  .log "Program input: '${program}'"
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
    .log -l 5 "${executable} does not need to be installed"
  fi
done

exit 0
