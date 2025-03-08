#!/bin/bash

# Define file paths
PROXMOX_DIR="/usr/share/javascript/proxmox-widget-toolkit"
FILE="proxmoxlib.js"
BACKUP_FILE="proxmoxlib.js.bak"
TARGET_LINE="if (false) {"
CHANGE_MADE=false

# Switch to the directory where the file is stored
cd "$PROXMOX_DIR" || { echo "Directory not found: $PROXMOX_DIR"; exit 1; }

# Backup the file before making any changes
cp "$FILE" "$BACKUP_FILE" || { echo "Failed to backup $FILE"; exit 1; }
echo "Backup created: $BACKUP_FILE"

# Check if the target line is already in the file
if grep -q "$TARGET_LINE" "$FILE"; then
    echo "The line is already replaced with '$TARGET_LINE'. No changes needed."
else
    # Edit the file using sed to replace the line if it's not already replaced
    sed -i '/if (res === null || res === undefined || !res || res\.data\.status\.toLowerCase() !== "active") {/c\if (false) {' "$FILE" || { echo "Failed to edit $FILE"; exit 1; }
    echo "Line replaced successfully in $FILE"
    CHANGE_MADE=true
fi

# Restart the PVE service to apply changes, only if a change was made
if $CHANGE_MADE; then
    systemctl restart pveproxy || { echo "Failed to restart pveproxy"; exit 1; }
    echo "PVE service restarted successfully."
else
    echo "No changes made. PVE service not restarted."
fi

# Exit the script
exit 0