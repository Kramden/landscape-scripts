#!/bin/bash
# Description: Safely clears package cache, orphaned dependencies, and old system logs.

echo "Starting Disk Rescue..."

# 1. Clear the apt cache (downloaded package archives)
echo "Clearing apt cache..."
apt-get clean

# 2. Remove orphaned packages (dependencies no longer needed)
echo "Removing orphaned packages..."
apt-get autoremove -y

# 3. Vacuum systemd journal logs (keep only the last 7 days)
echo "Vacuuming system logs..."
journalctl --vacuum-time=7d

# 4. Empty the root user's trash (if any)
if [ -d "/root/.local/share/Trash" ]; then
    rm -rf /root/.local/share/Trash/*
fi

echo "Disk Rescue Complete. Current Disk Space:"
df -h /
