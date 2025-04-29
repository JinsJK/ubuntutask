#!/bin/bash
# resource-monitor.sh
sleep 20
# Configurable thresholds (as percentages or absolute)
CPU_THRESHOLD=${CPU_THRESHOLD:-80}        # 80% of one core
MEM_THRESHOLD=${MEM_THRESHOLD:-75}        # 75% of total RAM
DISK_THRESHOLD=${DISK_THRESHOLD:-90}      # 90% of /var

CHECK_INTERVAL=${CHECK_INTERVAL:-5}       # seconds between checks

log() { echo "$(date '+%F %T') [resource-monitor] $*"; }

while true; do
  # --- 1) Check CPU usage ---
  cpu_idle=$(top -bn1 | awk '/^%Cpu/ {print $8}' | grep -Eo '[0-9]+([.][0-9]+)?') 2>/dev/null
  if [[ -n "$cpu_idle" ]]; then
    cpu_used=$(awk "BEGIN{printf \"%.0f\", 100 - $cpu_idle}")
  else
    cpu_used=0
  fi

  # --- 2) Check Memory usage ---
  read mem_total mem_used <<<$(free -m | awk '/^Mem:/ {print $2, $3}')
  mem_pct=$(awk "BEGIN{printf \"%.0f\", $mem_used/$mem_total*100}")

  # --- 3) Check Disk usage on /var ---
  disk_pct=$(df /var --output=pcent | tail -1 | tr -dc '0-9')

  if (( cpu_used > CPU_THRESHOLD )) || (( mem_pct > MEM_THRESHOLD )) || (( disk_pct > DISK_THRESHOLD )); then
    log "Threshold exceeded: CPU=${cpu_used}%, MEM=${mem_pct}%, DISK=${disk_pct}%"

    # Find and kill the main 'stress' process if it exists
    hog_pid=$(pgrep -x stress | head -n 1)

    if [[ -n "$hog_pid" ]]; then
      log "Killing main stress process PID=$hog_pid"
      pkill -P "$hog_pid"
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
