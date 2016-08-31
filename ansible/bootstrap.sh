#! /bin/bash

readonly Cmd="$*"

if [ -z "$Cmd" ]
then
  bash
else
  eval "$Cmd"
fi
