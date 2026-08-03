#!/bin/bash
# Description: Retrieves battery health, current charge status, and capacity for remote diagnostics.

echo "=== BATTERY HEALTH REPORT ==="

# Locate all battery devices on the system
BATTERIES=$(upower -e | grep -i 'battery')

# Check if any batteries were found
if [ -z "$BATTERIES" ]; then
    echo "RESULT: No battery detected."
    echo "Note: This machine may be a desktop, or the battery is completely dead/disconnected."
else
    # Loop through each battery found (some laptops have two)
    for BAT in $BATTERIES; do
        echo -e "\n--- Device: $(basename $BAT) ---"
        
        # Display specific metrics: vendor, model, current state, charge %, full design vs actual, and overall capacity
        upower -i "$BAT" | grep -E "vendor:|model:|state:|percentage:|energy-full:|energy-full-design:|capacity:"
        
    done
fi

echo -e "\n=== END REPORT ==="
