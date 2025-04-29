#!/bin/bash

THRESHOLD_PERCENT=80  # Use percentage of /var usage

echo "[Monitor-Var] Monitoring /var usage..."

while true; do
    USAGE_PERCENT=$(df /var | awk 'NR==2 {gsub("%",""); print $5}')
    echo "[Monitor-Var] /var usage: ${USAGE_PERCENT}%"

    if [ "$USAGE_PERCENT" -ge "$THRESHOLD_PERCENT" ]; then
        echo "[Monitor-Var] WARNING: /var usage exceeded! Triggering cleanup..."
        bash /usr/local/bin/cleanup-disk.sh
    fi

    sleep 5
done
