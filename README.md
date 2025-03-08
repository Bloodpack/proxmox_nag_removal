
# Proxmox Script for File Modification

This script is designed to automate the process of modifying a specific file (`proxmoxlib.js`) in the Proxmox system and restarting the Proxmox Proxy service (`pveproxy`). It is intended for use in **homelab** environments only.

### Important Warning:
**This script is intended for homelab use only.**  
**Do not use this script in a production environment.**  
Running this script in a production system could have unintended consequences and is **not recommended**.

### What Does This Script Do?
The script performs the following actions:

1. **Navigates to the directory** where the `proxmoxlib.js` file is located:
   - `/usr/share/javascript/proxmox-widget-toolkit`

2. **Creates a backup** of the `proxmoxlib.js` file as a safety measure:
   - `proxmoxlib.js.bak` will be created in the same directory.

3. **Modifies a specific line** in the `proxmoxlib.js` file:
   - The script searches for the following line:
     ```javascript
     if (res === null || res === undefined || !res || res.data.status.toLowerCase() !== 'active') {
     ```
   - If it is found, the script will replace it with:
     ```javascript
     if (false) {
     ```

4. **Restarts the Proxmox Proxy service** (`pveproxy`):
   - The script restarts the service **only if the file has been modified**. If the file is already modified, it skips the restart.

### Why Is This Script Needed?
In some scenarios, modifications to the `proxmoxlib.js` file are required to adjust Proxmox behavior in a non-production environment. This script automates that process and ensures that any necessary changes are made with a backup and service restart.

### How to Use the Script
1. **Clone or Download the Repository:**

   Clone this repository to your Proxmox server or download the script manually.

   ```bash
   git clone https://github.com/Bloodpack/proxmox_nag_removal.git

2. **Modify the premission of the file**

   ```bash
   chmod +x remove_subscr_nag.sh

3. **Run the script with this command**

   ```bash
   ./remove_subscr_nag.sh