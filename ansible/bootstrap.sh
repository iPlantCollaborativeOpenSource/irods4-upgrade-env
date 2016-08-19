#! /bin/bash

readonly Cmd="$*"

if [ -f requirements.yml ]
then
  printf 'Installing required roles ...\n'
  ansible-galaxy install --role-file requirements.yml
fi

if [ -z "$Cmd" ]
then
  bash
else
  eval "$Cmd"
fi
