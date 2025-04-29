#!/bin/bash
# monitor-node.sh

LOG_FILE="/var/log/node-monitor.log"

# Header (only once)
if [ ! -f "$LOG_FILE" ]; then
  echo "timestamp,pid,cpu_percent,mem_percent,rss_kb,status" >> "$LOG_FILE"
fi

while true; do
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  # look for the crash-app.js process
  pid=$(pgrep -f "node /opt/crash-app.js")

  if [ -n "$pid" ]; then
    # pull CPU%, MEM%, RSS in KB
    read cpu mem rss < <(ps -p "$pid" -o %cpu,%mem,rss --no-headers)
    status="running"
  else
    cpu=0
    mem=0
    rss=0
    status="crashed"
  fi

  echo "$timestamp,$pid,$cpu,$mem,$rss,$status" >> "$LOG_FILE"
    if [ "$status" == "crashed" ]; then
    echo "$timestamp - Node app crashed. Attempting restart..." >> "$LOG_FILE"
    nohup node /opt/crash-app.js >> /var/log/crash-app.out 2>&1 &
    echo "$timestamp - Restart command issued." >> "$LOG_FILE"
  fi
  sleep 1
done
