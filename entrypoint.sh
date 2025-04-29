#!/bin/bash

: > /var/log/fake-large-log.log
: > /var/log/resource-monitor.log
: > /var/log/node-monitor.log


# # Start crashing Node app
# node /opt/crash-app.js &

# # Start resource monitor (kills stress and app on overload)
# nohup /usr/local/bin/resource-monitor.sh >/var/log/resource-monitor.log 2>&1 &

# /usr/local/bin/simulate-load.sh &

# # Monitor the Node.js app every second
# nohup /usr/local/bin/monitor-node.sh >/dev/null 2>&1 &

# Simulate disk usage
/usr/local/bin/simulate-disk.sh &

# Start disk monitor script in background
/usr/local/bin/monitor-log.sh &

# Schedule log export every 30 minutes (if cron is installed and used)
echo "*/30 * * * * root /usr/local/bin/usb-logger.sh" >> /etc/crontab

# # Start SSH service
# service ssh start

# # Start SSH chaos simulation
# /usr/local/bin/simulate-ssh.sh &

# Keep container alive
tail -f /dev/null
