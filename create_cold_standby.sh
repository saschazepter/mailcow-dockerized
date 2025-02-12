#!/bin/bash

# Check if script is triggered via bash not ash or else to work properly
if [ -z "$BASH_VERSION" ]; then
  echo "This script must be run with bash!" >&2
  exit 1
fi

export REMOTE_SSH_KEY=/root/.ssh/id_rsa
export REMOTE_SSH_PORT=22
export REMOTE_SSH_HOST=my.remote.host

/opt/mailcow-dockerized/helper-scripts/_cold-standby.sh
