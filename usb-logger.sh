#!/bin/bash

LOG_SRC="/var/log"
USB_MOUNT="/mnt/usb"
mkdir -p "$USB_MOUNT"

# Simulate mount
if mount | grep -q "$USB_MOUNT"; then
  echo "USB already mounted"
else
  mount -t ext4 /dev/sdb1 "$USB_MOUNT" 2>/dev/null || echo "Simulated mount for /dev/sdb1"
fi

# Simulate log collection
LOG_DIR="$USB_MOUNT/logs_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"
rsync -a "$LOG_SRC" "$LOG_DIR"

echo "Logs copied to $LOG_DIR"