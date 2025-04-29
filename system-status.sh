#!/bin/bash

TARGET="/var"
SSH_HOST="localhost"
THRESHOLD=90

log() {
  echo "$(date '+%F %T') [system-status] $*"
}

while true; do
  echo "==== SYSTEM STATUS ($(date '+%F %T')) ===="

  # CPU Usage
  CPU_USED=$(top -bn1 | grep '^%Cpu' | awk '{print 100 - $8}')
  if [[ -n "$CPU_USED" ]]; then
    echo "CPU Usage: ${CPU_USED}%"
  else
    echo "CPU Usage: Unable to determine"
  fi

  # Memory Usage
  read -r mem_total mem_used <<<$(free -m | awk '/^Mem:/ {print $2, $3}')
  mem_pct=$(awk "BEGIN{printf \"%.1f\", $mem_used/$mem_total*100}")
  echo "Memory Usage: ${mem_pct}% (${mem_used}MB used of ${mem_total}MB)"

  # Disk Usage
  disk_pct=$(df "$TARGET" --output=pcent | tail -1 | tr -dc '0-9')
  echo "/var Disk Usage: ${disk_pct}%"

  # SSH Check
  timeout 2 bash -c "</dev/tcp/${SSH_HOST}/22" &>/dev/null
  if [ $? -eq 0 ]; then
    echo "SSH: Responding ✅"
  else
    echo "SSH: Not responding ⚠️"
  fi

  echo "=========================================="
  
  sleep 30
done
