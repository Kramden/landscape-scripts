#!/bin/bash
# Description: Fixes broken apt installations and dpkg interruptions.

echo "Attempting package manager repair..."

# 1. Configure any unpacked but unconfigured packages
echo "Running dpkg --configure -a..."
dpkg --configure -a

# 2. Fix broken dependencies
echo "Running apt-get install -f..."
apt-get install -f -y

# 3. Update package lists to ensure everything is synced
echo "Updating package lists..."
apt-get update

echo "Repair complete. Please check Landscape packages tab to confirm."
