FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Fix for tzdata non-interactive error
RUN apt-get update && apt-get install -y tzdata

# Basic tools & repositories
RUN apt-get update && \
    apt-get install -y \
    htop \
    nmon \
    iproute2 \
    curl \
    wget \
    sudo \
    gnupg \
    lsb-release \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Node.js 18 setup from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

# Install stress and other tools
RUN apt-get install -y \
    cron \
    rsync \
    stress \
    exfat-fuse \
    exfatprogs \
    && apt-get clean

# Install OpenSSH Server AFTER all basic setup
RUN apt-get update && apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'UseDNS no' >> /etc/ssh/sshd_config

# Create a basic SSH user
RUN useradd -m -s /bin/bash testuser && echo "testuser:testpass" | chpasswd

# Copy files into container
COPY crash-app.js /opt/crash-app.js
COPY simulate-disk.sh /usr/local/bin/simulate-disk.sh
COPY monitor-log.sh /usr/local/bin/monitor-log.sh
COPY cleanup-disk.sh /usr/local/bin/cleanup-disk.sh
COPY simulate-load.sh /usr/local/bin/simulate-load.sh
COPY resource-monitor.sh /usr/local/bin/resource-monitor.sh
COPY monitor-node.sh /usr/local/bin/monitor-node.sh
COPY simulate-ssh.sh /usr/local/bin/simulate-ssh.sh
COPY usb-logger.sh /usr/local/bin/usb-logger.sh
COPY entrypoint.sh /entrypoint.sh
COPY auto-log-export.sh /usr/local/bin/auto-log-export.sh
COPY emergency-fix.sh /usr/local/bin/emergency-fix.sh

# Install os-utils (after crash-app.js is copied)
RUN mkdir -p /tmp/crash-app && \
    cd /tmp/crash-app && \
    npm init -y && \
    npm install os-utils && \
    cp -r node_modules /opt/


# Make scripts executable
RUN chmod +x /opt/crash-app.js \
    && chmod +x /usr/local/bin/simulate-disk.sh \
    && chmod +x /usr/local/bin/monitor-log.sh \
    && chmod +x /usr/local/bin/cleanup-disk.sh \
    && chmod +x /usr/local/bin/simulate-load.sh \
    && chmod +x /usr/local/bin/resource-monitor.sh \
    &&  chmod +x /usr/local/bin/monitor-node.sh \
    && chmod +x /usr/local/bin/usb-logger.sh \
    && chmod +x /entrypoint.sh \
    && chmod +x /usr/local/bin/simulate-ssh.sh \
    && chmod +x /usr/local/bin/auto-log-export.sh \
    && chmod +x /usr/local/bin/emergency-fix.sh

# install ps/proc tools and add the monitor script
RUN apt-get update \
 && apt-get install -y procps \
 && rm -rf /var/lib/apt/lists/*

# install resource-monitor dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      procps coreutils util-linux \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 22 3000 

CMD ["/entrypoint.sh"]
