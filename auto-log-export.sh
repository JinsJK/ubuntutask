#!/bin/bash
set -euo pipefail

# Assume USB is mounted at /mnt/e
MOUNT_DIR="/mnt/e"
TARGET_DIR="logs_$(date +%Y%m%d_%H%M%S)"
LOG_DIRS=("/var/log" "/etc" "/home/*/.config")

copy_logs() {
    mkdir -p "$MOUNT_DIR/$TARGET_DIR"

    echo "Copying system logs to $MOUNT_DIR/$TARGET_DIR..."
    for dir in "${LOG_DIRS[@]}"; do
        sudo cp -r $dir "$MOUNT_DIR/$TARGET_DIR/" 2>/dev/null || true
    done

    echo "Saving dmesg and journalctl output..."
    sudo dmesg > "$MOUNT_DIR/$TARGET_DIR/dmesg.log"
    sudo journalctl > "$MOUNT_DIR/$TARGET_DIR/journal_full.log"

    echo "Logs successfully saved at $MOUNT_DIR/$TARGET_DIR"
}

# MAIN
echo "Starting log export to USB at $MOUNT_DIR..."
copy_logs
echo "USB log export completed!"
