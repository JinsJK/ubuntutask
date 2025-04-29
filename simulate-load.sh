#!/bin/bash

# Calculate 90% CPU load
TOTAL_CPUS=$(nproc)
CPU_LOAD=$(awk "BEGIN { printf \"%d\", $TOTAL_CPUS * 0.9 }")

# Calculate ~50% of total RAM
TOTAL_RAM_MB=$(free -m | awk '/Mem:/ { print $2 }')
RAM_TO_USE_MB=$(awk "BEGIN { printf \"%d\", $TOTAL_RAM_MB * 0.5 }")
VM_WORKERS=$(awk "BEGIN { printf \"%d\", $RAM_TO_USE_MB / 256 }")
[ "$VM_WORKERS" -lt 1 ] && VM_WORKERS=1

echo "Starting stress with:"
echo "  CPU: $CPU_LOAD of $TOTAL_CPUS cores"
echo "  RAM: ~$RAM_TO_USE_MB MB using $VM_WORKERS workers"

# Start stress normally (blocking)
stress --cpu "$CPU_LOAD" --vm "$VM_WORKERS" --vm-bytes 256M --io 4

# After stress ends, exit cleanly without restarting
echo "Stress ended. simulate-load.sh exiting normally."
exit 0
