#!/bin/bash

/run/start_sshd.sh

if [ -n "$@" ]; then
  bash -c "$@"
else
  /run/entrypoint.sh
fi  
