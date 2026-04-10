#!/usr/bin/env bash

set -euo pipefail

log_file="/var/log/myapp.log"

touch "$log_file"
printf '%s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" >> "$log_file"
