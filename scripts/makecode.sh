#!/usr/bin/env bash
# shellcheck source=/dev/null
if ! source "bash_library.sh" 2>/dev/null; then
  echo 'Please run via make command'
  exit 1
fi

yamlfile=$1

extensions=$(yq '.code.extensions.[]' "$yamlfile")
codefile=install/Codefile

echo -n "" >${codefile}

for extension in ${extensions}; do
  echo "${extension}" >>${codefile}
done

exit 0
