#!/usr/bin/env bash
yamlfile=$1

taps=$(yq '.brew.taps.[]' "$yamlfile")
casks=$(yq '.brew.casks.[]' "$yamlfile")
brews=$(yq '.brew.formulas.[]' "$yamlfile")
brewfile=install/Brewfile

echo -n "" > ${brewfile}

for tap in ${taps}; do
  echo "tap \"${tap}\"" >> ${brewfile}
done
echo "" >> ${brewfile}
for brew in ${brews}; do
  echo "brew \"${brew}\"" >> ${brewfile}
done
for cask in ${casks}; do
  echo "cask \"${cask}\"" >> ${brewfile}
done

exit 0