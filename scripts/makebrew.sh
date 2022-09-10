#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/../scripts/bash_library.sh"

yamlfile=$1
installDir="install"

check_yaml "${yamlfile}"
create_dir "${installDir}"

brewfile="${installDir}/Brewfile"
.log 6 "Brewfile: ${brewfile}"

taps=$(yq '.brew.taps.[]' "$yamlfile")
.log 7 "Taps: ${taps}"
casks=$(yq '.brew.casks.[]' "$yamlfile")
.log 7 "Casks: ${casks}"
brews=$(yq '.brew.formulas.[]' "$yamlfile")
.log 7 "Brews: ${brews}"

.log 6 "Emptying Brewfile (${brewfile})"
echo -n "" > ${brewfile}

for tap in ${taps}; do
  .log 6 "Tap (${tap}) >> Brewfile (${brewfile})"
  echo "tap \"${tap}\"" >> ${brewfile}
done
.log 6 "New line to Brewfile (${brewfile})"
echo "" >> ${brewfile}
for brew in ${brews}; do
  .log 6 "Brew (${brew}) >> Brewfile (${brewfile})"
  echo "brew \"${brew}\"" >> ${brewfile}
done
.log 6 "New line to Brewfile (${brewfile})"
echo "" >> ${brewfile}
for cask in ${casks}; do
  .log 6 "Cask (${cask}) >> Brewfile (${brewfile})"
  echo "cask \"${cask}\"" >> ${brewfile}
done

exit 0