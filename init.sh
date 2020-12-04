#!/bin/bash

/fix_permissions_and_start_sshd.sh

if [ ! -z "$@" ]; then
  bash -c "$@"
else	
  /entrypoint.sh 
fi  
