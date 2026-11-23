#! /usr/bin/env bash
set -euo pipefail

HOSTNAME=$1
PORT=$2

ssh -t -o UserKnownHostsFile=~/.ssh/stage1_known_hosts -p $2 root@"$1" 'cryptsetup-askpass'

