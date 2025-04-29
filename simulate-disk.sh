#!/bin/bash

LOG_FILE1="/var/log/fake-large-log.log"
LOG_FILE2="/var/log/fake-large-log2.log"
TMP_DIR="/var/tmp/fake-temp"

mkdir -p "$TMP_DIR"

echo "[Simulate-All] Starting simulation..."

simulate_log1() {
    while true; do
        BLOCK_SIZE=$(( (RANDOM % 5000) + 100 ))  # 100KB - 5MB
        head -c "${BLOCK_SIZE}K" /dev/urandom | base64 >> "$LOG_FILE1"
        SLEEP_TIME=$(awk -v min=0.1 -v max=5 'BEGIN{srand(); print min+rand()*(max-min)}')
        sleep "$SLEEP_TIME"
    done
}

simulate_log2() {
    while true; do
        BLOCK_SIZE=$(( (RANDOM % 3000) + 50 ))  # 50KB - 3MB
        head -c "${BLOCK_SIZE}K" /dev/urandom | base64 >> "$LOG_FILE2"
        SLEEP_TIME=$(awk -v min=0.5 -v max=3 'BEGIN{srand(); print min+rand()*(max-min)}')
        sleep "$SLEEP_TIME"
    done
}

simulate_temp() {
    while true; do
        FILE_NAME="$TMP_DIR/tmpfile_$(date +%s%N)"
        BLOCK_SIZE=$(( (RANDOM % 2000) + 100 ))  # 100KB - 2MB
        head -c "${BLOCK_SIZE}K" /dev/urandom > "$FILE_NAME"

        if (( RANDOM % 5 == 0 )); then
            echo "[Simulate-Temp] Cleaning up old temp files..."
            find "$TMP_DIR" -type f -mmin +1 -delete
        fi

        SLEEP_TIME=$(awk -v min=0.2 -v max=2 'BEGIN{srand(); print min+rand()*(max-min)}')
        sleep "$SLEEP_TIME"
    done
}

# Start all simulators in background
simulate_log1 &
simulate_log2 &
simulate_temp &

# Wait forever (keep container alive)
wait
