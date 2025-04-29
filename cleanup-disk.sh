#!/bin/bash

# Cleanup script to free up space on /var

echo "[Cleanup-Disk] Running cleanup..."

# Truncate both log files
for file in /var/log/fake-large-log.log /var/log/fake-large-log2.log; do
    if [ -f "$file" ]; then
        echo "[Cleanup-Disk] Truncating $file..."
        : > "$file"
        echo "[Cleanup-Disk] $file truncated."
    else
        echo "[Cleanup-Disk] No file found at $file"
    fi
done

# Clean temp files
echo "[Cleanup-Disk] Deleting temp files in /var/tmp/fake-temp/..."
rm -f /var/tmp/fake-temp/tmpfile_*

#clean apt cache
echo "[Cleanup-Disk] Cleaning APT cache..."
apt-get clean

#show free space after cleanup
df -h /var
