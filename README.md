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
| Push or remove an app on many/all machines at once | [Installing Software Fleet-Wide](#installing-or-removing-software-on-multiple-machines) | Packages |
| Set up automatic/recurring security patching | [4. Automating Security Patches](#4-automating-security-patches-upgrade-profiles) | Profiles |
| An app won't respond / is frozen | [5. Fixing Frozen Applications](#5-fixing-frozen-applications-the-processes-tab) | Processes |
| Need to see every running process, sorted, and kill one remotely | [5. Fixing Frozen Applications](#5-fixing-frozen-applications-the-processes-tab) | Processes |
| Need to run a diagnostic or repair tool | [6. Running Remote Repairs](#6-running-remote-repairs-the-scripts-tab) | Scripts |
| User reports general slowness | [7. Verifying Hardware Constraints](#7-verifying-hardware-constraints-the-hardware-tab) | Hardware |
| Need full hardware specs / asset info for a machine | [7. Verifying Hardware Constraints](#7-verifying-hardware-constraints-the-hardware-tab) | Hardware |
| Want proactive alerts (offline, reboot needed, security updates) | [8. Automated Monitoring & Alerts](#8-automated-monitoring--alerts) | Monitoring / Alerts |
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

### Installing or Removing Software on a Single Machine

1. Click the **Packages** tab.
2. In the search box, type the name of the software (e.g., "zoom").
3. Expand the search result.
4. Select the radio button for **Install** (or **Remove** if uninstalling).
5. Click **Apply Changes** at the bottom of the page.
6. Navigate to the **Activities** tab in the top menu to monitor the installation progress. Let the user know the software will appear in their applications menu shortly.

### Installing or Removing Software on Multiple Machines

Use this when a change needs to go out fleet-wide (e.g., every refurbished machine should ship with LibreOffice) instead of one beneficiary's computer at a time.

1. On the **Computers** tab, select the machines you want to target — either check them individually, or filter by an existing **tag**/**access group** (e.g., all machines tagged `KTS`).
2. With multiple computers selected, open the **Packages** page the same way as a single machine; search for the package and choose **Install** or **Remove**.
3. Click **Apply Changes**. This queues one package activity per selected machine — machines that are currently offline will pick up the change automatically the next time they check in, so you don't need everyone online at once.
4. For a change that should *stay* enforced going forward (not just a one-time push), create a **Package Profile** instead: under **Profiles**, define the packages that must be present (or must not be present) and associate the profile with an access group. Landscape then continuously keeps every machine in that group compliant — installing the package on any new or existing machine that's missing it — without you having to re-run the install manually.

## 4. Automating Security Patches (Upgrade Profiles)

Rather than manually installing updates machine-by-machine, use an **Upgrade Profile** to keep the whole fleet patched on a recurring schedule.

**How to set one up:**

1. Go to **Profiles** and create a new **Upgrade Profile**.
2. Associate it with the access group / tag of machines it should apply to (e.g., `KTS`).
3. Choose the update scope:
   - **Security only** — installs only patches tied to Ubuntu Security Notices (USNs), which are often mapped to CVEs. This is the safer default for unattended, recurring runs.
   - **All updates** — installs every available package upgrade, not just security fixes.
4. Set a weekly schedule (which days and what time window updates are allowed to run). You can randomize the exact delivery time across the fleet so machines don't all hammer the update servers at once.
5. Save the profile. From then on, Landscape applies matching updates automatically to every machine in that group during its scheduled window — no manual Packages-tab action needed.

**Note:** Kernel security patches normally require a reboot to take effect — that's what the "Reboot required" flag on the [Info tab](#2-initial-triage-the-info-tab) is telling you. Subscribing to the `SecurityUpgradesAlert` and `ComputerRebootAlert` (see [8. Automated Monitoring & Alerts](#8-automated-monitoring--alerts)) will tell you which machines still need a security update applied or a reboot to finish one.

## 5. Fixing Frozen Applications (The "Processes" Tab)

Use this tab when a user reports that an application is completely frozen and they cannot close it, or any time you need to see **every process currently running on the machine** — not just the app the user opened, but background services too.

**Viewing and Sorting the Process List:**

1. Click the **Processes** tab. This lists every running process as of the machine's last check-in with Landscape (it's a live snapshot, not a continuous real-time feed — reopen the tab to refresh it).
2. Click any column header — **PID**, process **Name**, **User**, **% CPU**, or **% RAM** — to sort by that column, ascending or descending. Sorting by % CPU or % RAM is the fastest way to spot the unresponsive or runaway process.

**How to Force-Close an App:**

1. Check the box next to the frozen process (e.g., "firefox" or "zoom").
2. In the dropdown menu labeled "Action," select **Send SIGTERM** (this asks the program to close nicely).
3. Click **Apply**.
4. If the application still does not close after 30 seconds, repeat the steps but select **Send SIGKILL** (this forces the program to terminate immediately).

## 6. Running Remote Repairs (The "Scripts" Tab)

Use this tab to run pre-approved IT repair and diagnostic scripts in the background.

**How to Execute a Script:**

1. Click the **Scripts** tab.
2. Under "Select a script to run," choose the appropriate tool from the Script Library (e.g., `FIX-DiskRescue` or `DIAG-SystemSnapshot`).
3. Leave the execution user as "root" unless the specific SOP for that script says otherwise.
4. If the script accepts a parameter (e.g., `FIX-PasswordReset` takes an optional username), enter it in the script's parameter/arguments field.
5. Set a timeout of "60 seconds" to ensure the script doesn't hang indefinitely.
6. Click **Run Script**.
7. A notification will appear at the top of the screen; click the link to go to the **Activities** tab.
8. Once the script finishes, click on the activity entry to view the exact output/results in your browser.

## 7. Verifying Hardware Constraints (The "Hardware" Tab)

Use this tab when a user reports general slowness, when you need to determine if a machine meets the requirements for a specific piece of software, or for general asset tracking/verification against the refurbishing database.

The Hardware tab reports everything Landscape can detect on the machine:

- **Processor:** Vendor, model, core count, clock speed, and CPU flags.
- **Memory (RAM):** Total installed memory and swap. If total RAM is 4GB or less, advise the user to keep fewer browser tabs open or purchase more RAM.
- **Storage:** Every disk and partition, with size and mount point. If the primary drive is 120GB or smaller, advise the user to store large files on a USB drive or in cloud storage, and mention the option to purchase a larger drive.
- **Network:** All network interfaces (Wi-Fi/Ethernet) with their MAC addresses.
- **PCI & USB devices:** Everything currently connected or built in (webcams, card readers, docking stations, etc.) — useful for confirming a reported peripheral is actually recognized by the OS.
- **BIOS/firmware:** Vendor and version — combine with the CPU model to cross-check the machine against the original refurbishing database records and confirm no parts were swapped or mismatched.
- **Video & audio:** Onboard graphics and sound hardware.

*Asset tracking tip:* Pair the Hardware tab's BIOS/serial-level detail with the Computers tab's K-Number tag when auditing donated inventory — this catches cases where a machine's physical parts (motherboard, drive) don't match what's on record for that K-Number.

## 8. Automated Monitoring & Alerts

Landscape gives you two related but separate tools for staying ahead of problems instead of waiting for a beneficiary to call in: **Monitoring graphs** (visual trends) and **Alerts** (email notifications on specific events).

### Monitoring Graphs

Under a computer's **Monitoring** page you can view graphs of CPU load, memory use, disk use, temperature, and network traffic over a selectable timeframe (1 day, 3 days, 1 week, or 4 weeks). You can also build **custom graphs** from your own collected metrics if you need to track something not covered by the defaults. These graphs are for visual trend-spotting — checking whether a specific machine's disk usage is climbing over time, for example — rather than automatic notification.

### Alerts (Email Notifications)

Alerts notify you automatically by email when a specific tracked event happens, without you having to go look. Configure subscriptions under **Account Settings → Alerts**. The alert types most relevant to day-to-day support are:

| Alert | Fires when |
| --- | --- |
| `ComputerOfflineAlert` | A machine hasn't checked in with Landscape in the last 5 minutes. |
| `ComputerRebootAlert` | A machine needs a reboot to finish applying an update (e.g., a new kernel). |
| `SecurityUpgradesAlert` | Security updates are available and waiting to be applied on a machine. |
| `PackageUpgradesAlert` | Any (non-security) package updates are available. |
| `PackageReporterAlert` | A machine's `apt-get update` is failing, so Landscape can't see accurate package status for it. |
| `UnapprovedActivitiesAlert` | An activity (like a script run or package change) is queued and waiting on manual approval. |

**Caution:** As of this writing, Landscape does not ship a built-in "alert me when free disk space drops below X" or generic custom-metric-threshold alert — disk, memory, and load are available as **graphs** (above) but not as configurable numeric-threshold alerts. Until/unless that's added, the practical way to stay ahead of low-disk-space issues is to (a) subscribe to `ComputerOfflineAlert` and `SecurityUpgradesAlert` so you're not blind on fleet health, (b) periodically skim the Monitoring graphs across the fleet, and (c) rely on the "Root filesystem full" check that's already part of [2. Initial Triage](#2-initial-triage-the-info-tab) on every support call. If proactive disk-space paging becomes a hard requirement, that would need a custom solution (e.g., a scheduled `DIAG-SystemSnapshot`-style script paired with external notification) rather than native Landscape alerting.

## Script Library

These are the pre-approved scripts available in the **Scripts** tab (see [6. Running Remote Repairs](#6-running-remote-repairs-the-scripts-tab)). Run diagnostics first to confirm the problem, then run fixes if needed.

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
