#!/usr/bin/env bash

yamlfile=$1

yq '.asdf.[]' "${yamlfile}" | while read -r program; do
  if [[ "$program" == *":"* ]]; then
    executable=$(echo "${program}" | cut -f2 -d: | cut -c2-)
    program=$(echo "${program}" | cut -f1 -d: )
  else
    executable="${program}"
  fi 
  if ! bin/is-executable "${executable}"; then
    asdf plugin add "${program}"
    asdf install "${program}" latest
    asdf global "${program}" latest
  fi
done