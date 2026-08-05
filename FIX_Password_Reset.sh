#!/bin/bash
# Description: Resets a user's password to 'kramden' and forces a reset on next login.
# Optional parameter: username to target. If omitted, auto-detects the machine's
# primary human user, but refuses to guess if more than one account is found.

echo "=== PASSWORD RESET INITIATED ==="

TARGET_USER="$1"

if [ -n "$TARGET_USER" ]; then
    # A username was supplied as a script parameter, confirm it actually exists.
    if ! id "$TARGET_USER" &> /dev/null; then
        echo "FAIL: User '$TARGET_USER' does not exist on this machine."
        exit 1
    fi
else
    # No username supplied, auto-detect human user accounts (UID between 1000 and 60000).
    CANDIDATES=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd)
    CANDIDATE_COUNT=$(echo "$CANDIDATES" | grep -c .)

    if [ "$CANDIDATE_COUNT" -eq 0 ]; then
        echo "FAIL: Could not automatically detect a standard user account."
        exit 1
    elif [ "$CANDIDATE_COUNT" -gt 1 ]; then
        echo "FAIL: Multiple user accounts found on this machine, cannot guess which one to reset:"
        echo "$CANDIDATES"
        echo "Ask the beneficiary for their username (or check the Info tab), then re-run this script with that username as a parameter."
        exit 1
    fi

    TARGET_USER="$CANDIDATES"
fi

echo "Target user identified as: $TARGET_USER"

# 2. Set the password to the temporary default ("kramden")
# chpasswd reads from standard input in the format username:password
echo "$TARGET_USER:kramden" | chpasswd

if [ $? -eq 0 ]; then
    echo "SUCCESS: Password has been reset to the default."
else
    echo "FAIL: The chpasswd command encountered an error."
    exit 1
fi

# 3. Expire the password immediately
# This forces Ubuntu to prompt the user to create a new password as soon as they type 'kramden'
passwd --expire "$TARGET_USER"

if [ $? -eq 0 ]; then
    echo "SUCCESS: Password expired."
    echo "RESOLUTION: Tell the user to log in with the password 'kramden'. They will immediately be asked to type a new password of their choice."
else
    echo "FAIL: Could not expire the password."
    exit 1
fi

echo "=== END TASK ==="
