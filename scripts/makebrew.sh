#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/../scripts/bash_library.sh"

yamlfile=$1
installDir="install"

check_yaml "${yamlfile}"
create_dir "${installDir}"

brewfile="${installDir}/Brewfile"
.log -l 5 "Brewfile: ${brewfile}"

taps=$(yq '.brew.taps.[]' "$yamlfile")
.log -l 7 "Taps: ${taps}"
casks=$(yq '.brew.casks.[]' "$yamlfile")
.log -l 7 "Casks: ${casks}"
brews=$(yq '.brew.formulas.[]' "$yamlfile")
.log -l 7 "Brews: ${brews}"

.log -l 6 "Emptying Brewfile (${brewfile})"
echo -n "" > ${brewfile}

for tap in ${taps}; do
  .log -l 6 "Tap (${tap}) >> Brewfile (${brewfile})"
  echo "tap \"${tap}\"" >> ${brewfile}
done
.log -l 6 "New line to Brewfile (${brewfile})"
echo "" >> ${brewfile}
for brew in ${brews}; do
  .log -l 6 "Brew (${brew}) >> Brewfile (${brewfile})"
  echo "brew \"${brew}\"" >> ${brewfile}
done
.log -l 6 "New line to Brewfile (${brewfile})"
echo "" >> ${brewfile}
for cask in ${casks}; do
  .log -l 6 "Cask (${cask}) >> Brewfile (${brewfile})"
  echo "cask \"${cask}\"" >> ${brewfile}
done

exit 0