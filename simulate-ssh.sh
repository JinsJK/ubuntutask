#!/bin/bash
set -e

echo "🚀 Starting SSH chaos simulation (kill sshd randomly)..."

while true; do
  sleep $(( RANDOM % 10 + 5 ))  # Sleep between 5–15 seconds
  echo "⚡ Killing sshd at $(date)"
  pkill sshd
  service ssh start
done
