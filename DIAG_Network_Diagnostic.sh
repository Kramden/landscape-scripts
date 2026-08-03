#!/bin/bash
# Description: Tests external connectivity and DNS resolution.

echo "=== NETWORK DIAGNOSTICS ==="

echo -e "\n--- Network Interfaces ---"
ip -br a

echo -e "\n--- Default Route ---"
ip route | grep default

echo -e "\n--- DNS Resolution Test (pinging google.com) ---"
if ping -c 3 google.com &> /dev/null; then
    echo "SUCCESS: DNS is resolving google.com"
else
    echo "FAIL: Cannot resolve google.com. Possible DNS issue."
fi

echo -e "\n--- Direct IP Connection Test (pinging 8.8.8.8) ---"
if ping -c 3 8.8.8.8 &> /dev/null; then
    echo "SUCCESS: Direct IP routing is working."
else
    echo "FAIL: Cannot reach external IP. Network connection is down."
fi

echo -e "\n--- Current DNS Servers ---"
resolvectl status | grep "DNS Servers" -A 2 || cat /etc/resolv.conf | grep nameserver

echo -e "\n=== END DIAGNOSTICS ==="
