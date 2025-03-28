# Script to remove the proxmox no subscription nag.
################################################
# !!!PLEASE USE THIS SCRIPT ONLY FOR HOMELAB!!!#
################################################
# Copyright (c) 2025 Bloodpack
# Author: Bloodpack 
# License: GPL-3.0 license
# Follow or contribute on GitHub here:
# https://github.com/Bloodpack/proxmox_nag_removal.git
#################################
# VERSION: 1.95 from 28.03.2025 #
#################################



#!/bin/bash

# Define file paths
PROXMOX_DIR="/usr/share/javascript/proxmox-widget-toolkit"
FILE="proxmoxlib.js"
BACKUP_FILE="proxmoxlib.js.bak"
TARGET_LINE="if (res === null || res === undefined || !res || res"

# Switch to the directory where the file is stored
cd "$PROXMOX_DIR" || { echo "Directory not found: $PROXMOX_DIR"; exit 1; }

# Backup the file before making any changes
cp "$FILE" "$BACKUP_FILE" || { echo "Failed to backup $FILE"; exit 1; }
echo "Backup created: $BACKUP_FILE"

# Ensure the target line exists in the file
if grep -q "$TARGET_LINE" "$FILE"; then
    # Use sed to replace the multiline block with "if (false)" with correct indentation
    sed -i '/if (res === null || res === undefined || !res || res/,/\.data.status.toLowerCase()/c\                    if (false) {' "$FILE"
    echo "Line replaced successfully in $FILE"

    # Optionally restart a service if needed (e.g., pveproxy) - uncomment if necessary
    systemctl restart pveproxy || { echo "Failed to restart pveproxy"; exit 1; }
    # echo "PVE service restarted successfully."

else
    echo "Target line not found. No changes made."
fi

# Exit the script
exit 0

