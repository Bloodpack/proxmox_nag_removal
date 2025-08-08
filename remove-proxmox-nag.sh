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
# VERSION: 2.00 from 08.08.2025 #
#################################



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
else
    echo "[no-nag] Patch failed. Restoring from backup..."
    cp "$BACKUP_FILE" "$JS_FILE"
    echo "[no-nag] Original restored from: $BACKUP_FILE"
    exit 1
fi


