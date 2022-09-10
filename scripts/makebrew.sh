#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/../scripts/bash_library.sh"

yamlfile=$1
installDir="install"

.log 7 "YAML File is '${yamlfile}'"
if is-file "${yamlfile}"; then
  .log 7 "File ($yamlfile) found"
else
  .log 3 "File ($yamlfile) not found, exiting"
  exit 1
fi
create_dir "${installDir}"

taps=$(yq '.brew.taps.[]' "$yamlfile")
.log 7 "Taps: ${taps}"
casks=$(yq '.brew.casks.[]' "$yamlfile")
.log 7 "Casks: ${casks}"
brews=$(yq '.brew.formulas.[]' "$yamlfile")
.log 7 "Brews: ${brews}"
brewfile="${installDir}/Brewfile"
.log 7 "Brewfile: ${brewfile}"

.log 7 "Emptying Brewfile (${brewfile})"
echo -n "" > ${brewfile}

for tap in ${taps}; do
  .log 7 "Tap (${tap}) >> Brewfile (${brewfile})"
  echo "tap \"${tap}\"" >> ${brewfile}
done
.log 7 "New line to Brewfile (${brewfile})"
echo "" >> ${brewfile}
for brew in ${brews}; do
  .log 7 "Brew (${brew}) >> Brewfile (${brewfile})"
  echo "brew \"${brew}\"" >> ${brewfile}
done
.log 7 "New line to Brewfile (${brewfile})"
echo "" >> ${brewfile}
for cask in ${casks}; do
  .log 7 "Cask (${cask}) >> Brewfile (${brewfile})"
  echo "cask \"${cask}\"" >> ${brewfile}
done

exit 0