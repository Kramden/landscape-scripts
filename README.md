# Using Landscape for Remote Tech Support

This guide outlines exactly how the Kramden IT team should utilize the Canonical Landscape dashboard to diagnose and resolve beneficiary issues remotely.

## Quick Lookup: Symptom → Section

Mid-call and not sure where to start? Match the symptom to a section below.

| Symptom / Request | Go to | Tab in Landscape |
| --- | --- | --- |
| Can't find the machine to start a session | [1. Locating the Machine](#1-locating-the-beneficiarys-machine) | Computers |
| Not sure where the problem is yet | [2. Initial Triage](#2-initial-triage-the-info-tab) | Info |
| Machine seems offline / not responding | [2. Initial Triage](#2-initial-triage-the-info-tab) | Info |
| System feels laggy, apps crashing | [2. Initial Triage](#2-initial-triage-the-info-tab) → [Disk Rescue](#script-library) | Info → Scripts |
| User needs an app installed/removed | [3. Resolving Software Requests](#3-resolving-software-requests-the-packages-tab) | Packages |
| An app won't respond / is frozen | [4. Fixing Frozen Applications](#4-fixing-frozen-applications-the-processes-tab) | Processes |
| Need to run a diagnostic or repair tool | [5. Running Remote Repairs](#5-running-remote-repairs-the-scripts-tab) | Scripts |
| User reports general slowness | [6. Verifying Hardware Constraints](#6-verifying-hardware-constraints-the-hardware-tab) | Hardware |
| Laptop battery draining fast / won't hold charge | [Script Library](#script-library) (`DIAG-BatteryReport`) | Scripts |
| Wi-Fi/internet connectivity issues | [Script Library](#script-library) (`DIAG-NetworkDiagnostic`) | Scripts |
| `apt`/software updates failing or stuck | [Script Library](#script-library) (`FIX-PackageManager`) | Scripts |
| User forgot their password / is locked out | [Script Library](#script-library) (`FIX-PasswordReset`) | Scripts |

## 1. Locating the Beneficiary's Machine

When a customer contacts support, your first step is to locate their specific machine in Landscape.

1. Log into the Landscape Dashboard.
2. Navigate to the **Computers** tab in the top navigation bar.
3. In the **Search** bar, enter the identifying information provided by the user.
   - *Best Practice:* Search by the machine's K-Number.
4. Click on the computer's title to enter its detailed management view.

## 2. Initial Triage (The "Info" Tab)

Always check the **Info** tab first before asking the user complex questions. This tab provides a snapshot of system health.

**What to look for:**

- **Last ping:** If this is older than 5-10 minutes, the machine is offline. Shift your support strategy to helping the user connect to Wi-Fi.
- **Reboot required:** If flagged "Yes," ask the user to reboot. This often solves minor glitches and completes pending kernel updates.
- **Root filesystem full:** Check the free space. If it is below 5GB, the system will lag and applications will crash. (See the Scripts tab to run the Disk Rescue tool).

## 3. Resolving Software Requests (The "Packages" Tab)

Use this tab when a user needs an application installed (like Zoom or LibreOffice) or if an application is failing to update.

**How to Install or Remove Software:**

1. Click the **Packages** tab.
2. In the search box, type the name of the software (e.g., "zoom").
3. Expand the search result.
4. Select the radio button for **Install** (or **Remove** if uninstalling).
5. Click **Apply Changes** at the bottom of the page.
6. Navigate to the **Activities** tab in the top menu to monitor the installation progress. Let the user know the software will appear in their applications menu shortly.

## 4. Fixing Frozen Applications (The "Processes" Tab)

Use this tab when a user reports that an application is completely frozen and they cannot close it.

**How to Force-Close an App:**

1. Click the **Processes** tab.
2. Sort the list by clicking the **% CPU** or **% RAM** column headers to easily find the unresponsive application.
3. Check the box next to the frozen process (e.g., "firefox" or "zoom").
4. In the dropdown menu labeled "Action," select **Send SIGTERM** (this asks the program to close nicely).
5. Click **Apply**.
6. If the application still does not close after 30 seconds, repeat the steps but select **Send SIGKILL** (this forces the program to terminate immediately).

## 5. Running Remote Repairs (The "Scripts" Tab)

Use this tab to run pre-approved IT repair and diagnostic scripts in the background.

**How to Execute a Script:**

1. Click the **Scripts** tab.
2. Under "Select a script to run," choose the appropriate tool from the Script Library (e.g., "FIX-DiskRescue" or "DIAG-SystemSnapshot").
3. Leave the execution user as "root" unless the specific SOP for that script says otherwise.
4. If the script accepts a parameter (e.g., `FIX-PasswordReset` takes an optional username), enter it in the script's parameter/arguments field.
5. Set a timeout of "60 seconds" to ensure the script doesn't hang indefinitely.
6. Click **Run Script**.
7. A notification will appear at the top of the screen; click the link to go to the **Activities** tab.
8. Once the script finishes, click on the activity entry to view the exact output/results in your browser.

## 6. Verifying Hardware Constraints (The "Hardware" Tab)

Use this tab when a user reports general slowness, or if you need to determine if a machine meets the requirements for a specific piece of software.

**What to check:**

- **Memory (RAM):** Confirm the total installed memory. If it is 4GB or less, advise the user to keep fewer browser tabs open or purchase more RAM.
- **Storage:** Check the total disk size. If it is a 120GB drive, advise the user to store large files on a USB drive, in cloud storage, and inform them of the option to purchase a larger drive.
- **Processors:** Verify the CPU model to ensure it matches the original refurbishing database records.

## Script Library

These are the pre-approved scripts available in the **Scripts** tab (see [5. Running Remote Repairs](#5-running-remote-repairs-the-scripts-tab)). Run diagnostics first to confirm the problem, then run fixes if needed.

| Script | Type | What it does | When to run it |
| --- | --- | --- | --- |
| `DIAG-SystemSnapshot` | Diagnostic | Reports uptime, memory usage, disk space, top CPU/RAM-consuming processes, and recent kernel errors. | First stop for "the whole machine feels slow" — pinpoints whether it's memory, disk, or a runaway process. |
| `DIAG-NetworkDiagnostic` | Diagnostic | Checks network interfaces, default route, DNS resolution, direct-IP connectivity, and configured DNS servers. | User reports Wi-Fi or "can't get online" issues, or a specific site/app won't load. |
| `DIAG-BatteryReport` | Diagnostic | Reports battery vendor/model, charge state, charge percentage, and health (current capacity vs. original design capacity). | Laptop won't hold a charge, drains quickly, or user asks if the battery needs replacing. |
| `FIX-DiskRescue` | Fix | Clears the apt package cache, removes orphaned packages, vacuums system logs older than 7 days, and empties the root trash. | Root filesystem is below 5GB free (see [Initial Triage](#2-initial-triage-the-info-tab)). |
| `FIX-PackageManager` | Fix | Runs `dpkg --configure -a`, repairs broken dependencies with `apt-get install -f`, and refreshes package lists. | Software installs/updates are failing or stuck, or the Packages tab reports errors. |
| `FIX-PasswordReset` | Fix | Resets the target user's password to the temporary default `kramden` and expires it so they're forced to set a new one at next login. Accepts an optional username parameter; if omitted, auto-detects the machine's user account — but refuses to guess if it finds more than one. | User forgot their password or is locked out of their account. |

**Tip:** Run the matching `DIAG-*` script before a `FIX-*` script when possible — it confirms the fix is actually needed and gives you a "before" snapshot to compare against once the fix completes.

**Using `FIX-PasswordReset` on a machine with multiple accounts:** If the script fails with "Multiple user accounts found," ask the beneficiary for their username, or check the **Info** tab for the logged-in/primary user. Then re-run the script from the **Scripts** tab, entering that username in the script's parameter/arguments field before clicking **Run Script**. After the reset, tell the user to log in with the temporary password `kramden`; they'll be prompted to choose their own password immediately.
