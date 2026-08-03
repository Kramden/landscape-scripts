#!/bin/bash
# Description: Generates a quick overview of system health for remote tech support.

echo "=== SYSTEM SNAPSHOT ==="
date

echo -e "\n--- Uptime & Load ---"
uptime

echo -e "\n--- Memory Usage ---"
free -h

echo -e "\n--- Disk Space (Top 5 Partitions) ---"
df -h -x tmpfs -x devtmpfs | head -n 6

echo -e "\n--- Top 5 CPU Consuming Processes ---"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6

echo -e "\n--- Top 5 Memory Consuming Processes ---"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

echo -e "\n--- Recent Hardware/Kernel Errors (dmesg) ---"
dmesg -T --level=err,crit,alert,emerg | tail -n 10

echo -e "\n=== END SNAPSHOT ==="
