#!/bin/bash
set -e

echo "🔧 [1/3] Finding and killing background SSHD chaos processes..."

# Kill simulate-ssh.sh processes (chaos loop)
pkill -f "simulate-ssh.sh" || true

# Extra safety: kill any leftover ssh chaos commands
ps aux | grep "[s]ervice ssh start" | awk '{print $2}' | xargs -r kill -9 || true

echo "🔧 [2/3] Stabilizing SSHD configuration..."

# Clean old UseDNS configs
sed -i '/^UseDNS/d' /etc/ssh/sshd_config
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Increase client alive intervals
echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 5" >> /etc/ssh/sshd_config

# Restart sshd
service ssh restart

echo "🔧 [3/3] Verifying SSHD is running..."
ps aux | grep [s]shd

echo "✅ Stabilization Complete! SSH should now stay up reliably."
