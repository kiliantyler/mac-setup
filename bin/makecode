#!/usr/bin/env bash
yamlfile=$1

extensions=$(yq '.code.extensions.[]' "$yamlfile")
codefile=install/Codefile

echo -n "" > ${codefile}

for extension in ${extensions}; do
  echo "${extension}" >> ${codefile}
done

exit 0