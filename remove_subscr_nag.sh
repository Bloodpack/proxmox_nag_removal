# Script to remove the proxmox no subscription nag.
################################################
# !!!PLEASE USE THIS SCRIPT ONLY FOR HOMELAB!!!#
################################################
# Copyright (c) 2025 Bloodpack
# Author: Bloodpack 
# License: GPL-3.0 license
# Follow or contribute on GitHub here:
# https://github.com/Bloodpack/proxmox_nag_removal.git
################################
# VERSION: 1.0 from 08.03.2025 #
################################



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

# Read the file and look for the multiline pattern
new_content=""
inside_block=false
pattern="if (res === null || res === undefined || !res || res.data.status.toLowerCase() !== 'active') {"

while IFS= read -r line; do
    # Check if we're inside the target block
    if [[ "$inside_block" == true ]]; then
        if [[ "$line" =~ "}" ]]; then
            # Close the block, stop replacing
            new_content+="if (false) {\n"
            inside_block=false
        fi
        continue
    fi

    # Check if the current line matches the start of the target pattern
    if [[ "$line" =~ "$pattern" ]]; then
        inside_block=true
        new_content+="if (false) {\n"
    else
        new_content+="$line\n"
    fi
done < "$FILE"

# Save the modified content back into the file
echo -e "$new_content" > "$FILE"

# Check if a change was made
if [[ "$new_content" != "$(cat "$BACKUP_FILE")" ]]; then
    CHANGE_MADE=true
    echo "Line replaced successfully in $FILE"
else
    echo "No changes made."
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
