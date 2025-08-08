
# No subscription popup remover for Proxmox VE

# This works only on versions below above V.9

📦 Disable Proxmox Subscription Nag with Auto-Patching Script

This script removes the subscription nag screen from the Proxmox VE Web UI, and automatically reapplies the patch after package upgrades. It also keeps a backup of the original file with rotation (last 3 backups only).
⚙️ Features

    ✅ Removes the "No valid subscription" popup in the Proxmox Web UI.

    ✅ Automatically reapplies after APT/DPKG updates via an APT hook.

    ✅ Creates a timestamped backup of the original file before patching.

    ✅ Keeps only the last 3 backups to avoid clutter.

📁 File Structure

```shell
/usr/local/sbin/remove-proxmox-nag.sh       # Patch script
/etc/apt/apt.conf.d/99-pve-no-nag           # APT hook
/usr/share/javascript/proxmox-widget-toolkit/  # Target JS file + backups
```

🛠️ Installation Instructions

You must be logged in as root (no sudo required).

1. Create the patch script
```
nano /usr/local/sbin/remove-proxmox-nag.sh
```

Paste this script:

```bash
#!/bin/bash

# Path to original JS file
JS_FILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

# Backup directory (same as JS file)
BACKUP_DIR="/usr/share/javascript/proxmox-widget-toolkit"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/proxmoxlib.js.bak.${TIMESTAMP}"

# Make sure JS file exists
if [ ! -f "$JS_FILE" ]; then
    echo "[no-nag] ERROR: $JS_FILE not found."
    exit 1
fi

# Skip if already patched
if grep -q "NoMoreNagging" "$JS_FILE"; then
    echo "[no-nag] Already patched: $JS_FILE"
    exit 0
fi

# Create backup
cp "$JS_FILE" "$BACKUP_FILE"
echo "[no-nag] Backup created at: $BACKUP_FILE"

# Rotate backups (keep only last 3)
BACKUPS=($(ls -1t ${BACKUP_DIR}/proxmoxlib.js.bak.* 2>/dev/null))
NUM_BACKUPS=${#BACKUPS[@]}

if [ "$NUM_BACKUPS" -gt 3 ]; then
    echo "[no-nag] Rotating backups. Keeping latest 3..."
    for ((i=3; i<NUM_BACKUPS; i++)); do
        rm -f "${BACKUPS[$i]}"
        echo "[no-nag] Deleted old backup: ${BACKUPS[$i]}"
    done
fi

# Apply patch
sed -i '/data\.status/{s/!//;s/active/NoMoreNagging/}' "$JS_FILE"

# Confirm patch
if grep -q "NoMoreNagging" "$JS_FILE"; then
    echo "[no-nag] Patch applied successfully to $JS_FILE"
    
    # Restart pveproxy to reload patched JS
    if systemctl restart pveproxy; then
        echo "[no-nag] Restarted pveproxy successfully."
    else
        echo "[no-nag] Failed to restart pveproxy!"
        exit 1
    fi
else
    echo "[no-nag] Patch failed. Restoring from backup..."
    cp "$BACKUP_FILE" "$JS_FILE"
    echo "[no-nag] Original restored from: $BACKUP_FILE"
    exit 1
fi
```
Make the script executable:

```
chmod +x /usr/local/sbin/remove-proxmox-nag.sh
```
2. Create the APT hook

```
nano /etc/apt/apt.conf.d/99-pve-no-nag
```
Paste:

```bash
DPkg::Post-Invoke {
  "if [ -x /usr/local/sbin/remove-proxmox-nag.sh ]; then /usr/local/sbin/remove-proxmox-nag.sh; fi";
};
```

3. Test it manually (optional)

Run the script directly:

```shell
/usr/local/sbin/remove-proxmox-nag.sh
```
Check that backups exist:

```shell
ls -lt /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak.*
```
🧠 Notes

    This script does not affect any Proxmox functionality — it only bypasses the UI nag.

    Backups are stored in the same directory as the original JS file.

    Be sure to clear your browser cache after patching.

🛑 Disclaimer

Use at your own risk. This script modifies Proxmox UI files, which could be overwritten during updates. The APT hook helps to reapply the patch automatically, but always check after major upgrades.

This is intended for homelab or non-production environments where the subscription nag is undesired.