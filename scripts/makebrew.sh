#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

yamlfile=$1
installDir="install"

check_file "${yamlfile}"
create_dir "${installDir}"

brewfile="${installDir}/Brewfile"
.log -l 5 "Brewfile: ${brewfile}"

taps=$(yq '.brew.taps.[]' "$yamlfile")
.log "Taps: ${taps}"
casks=$(yq '.brew.casks.[]' "$yamlfile")
.log "Casks: ${casks}"
brews=$(yq '.brew.formulas.[]' "$yamlfile")
.log "Brews: ${brews}"

.log -l 6 "Emptying Brewfile (${brewfile})"
echo -n "" >${brewfile}

for tap in ${taps}; do
  .log -l 6 "Tap (${tap}) >> Brewfile (${brewfile})"
  echo "tap \"${tap}\"" >>${brewfile}
done
.log -l 6 "New line to Brewfile (${brewfile})"
echo "" >>${brewfile}
for brew in ${brews}; do
  .log -l 6 "Brew (${brew}) >> Brewfile (${brewfile})"
  echo "brew \"${brew}\"" >>${brewfile}
done
.log -l 6 "New line to Brewfile (${brewfile})"
echo "" >>${brewfile}
for cask in ${casks}; do
  .log -l 6 "Cask (${cask}) >> Brewfile (${brewfile})"
  echo "cask \"${cask}\"" >>${brewfile}
done

exit 0
