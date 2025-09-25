# Enable Audit on Bastion VM

### Steps to Enable Audit logs on VM

Below are the steps done to configure auditing on bastion VM and push the audit logs to blob storage

1. Install auditd

```
sudo apt update
sudo apt install auditd audispd-plugins
```

2. Enable basic audit rules to log executed commands

```
sudo bash -c 'echo "-a always,exit -F arch=b64 -S execve -k command-log" >> /etc/audit/rules.d/audit.rules'
sudo bash -c 'echo "-a always,exit -F arch=b32 -S execve -k command-log" >> /etc/audit/rules.d/audit.rules'
```

3. Restart audit daemon

```
sudo systemctl restart auditd
sudo systemctl enable auditd
```

4. Verify its working

```
sudo ausearch -k command-log
```

5. Check current config for log rotation

```
sudo grep -E 'max_log_file|num_logs|rotate|max_log_file_action' /etc/audit/auditd.conf
```

Make sure it has below configs:

```ini
max_log_file = 8       # Rotate when 8MB is reached
num_logs = 5            # Keep 5 logs: audit.log, audit.log.1, ..., audit.log.4
max_log_file_action = ROTATE
```

6. Restart auditd to apply, if changes done

```
sudo systemctl restart auditd
```

### Steps to Upload logs to Azure Blob (via Cron Job)

#### Prerequisites

- Storage account + container created in Azure
- Azure CLI
- Azure creds, by running command `az ad sp create-for-rbac --name audit-cron-sp --sdk-auth`

#### Sync script

1. Create a sync script (e.g. /usr/local/bin/sync-audit-logs.sh)

```
#!/bin/bash

# Azure credentials
APP_ID="418e2228-fa4c-453f-9761-bfadef274117"
PASSWORD="some_password"
TENANT_ID="095ce29a-6c40-4daa-82a4-52009df3f543"
STORAGE_ACCOUNT_NAME="jaguarauditlogs"
CONTAINER_NAME="bastionauditlogs"
AUDIT_DIR="/var/log/audit"
ARCHIVE_DIR="$AUDIT_DIR/archive"

# Login to Azure
az login --service-principal \
  --username "$APP_ID" \
  --password "$PASSWORD" \
  --tenant "$TENANT_ID" >/dev/null 2>&1

if [ $? -ne 0 ]; then
  echo "Azure login failed. Exiting."
  exit 1
fi

# Get Storage Account Key
ACCOUNT_KEY=$(az storage account keys list --account-name "$STORAGE_ACCOUNT_NAME" --query '[0].value' -o tsv)

if [ -z "$ACCOUNT_KEY" ]; then
  echo "Failed to fetch storage account key. Exiting."
  exit 1
fi

# Ensure archive dir exists
sudo mkdir -p "$ARCHIVE_DIR"

# Move rotated logs to archive
sudo find "$AUDIT_DIR" -maxdepth 1 -type f -name "audit.log.*" -exec mv {} "$ARCHIVE_DIR/" \;

# Upload logs
for file in "$ARCHIVE_DIR"/audit.log.*; do
  [ -e "$file" ] || continue
  az storage blob upload \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$ACCOUNT_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "$(hostname)/$(basename "$file")_$(date -u +'%Y%m%dT%H%M%SZ')" \
    --file "$file" \
    --overwrite

  if [ $? -eq 0 ]; then
    sudo rm -f "$file"
  fi
done
```

2. Make it executable

```
sudo chmod +x /usr/local/bin/sync-audit-logs.sh
```

3. Setup Cron Job (every 2 hours)

```
sudo crontab -e
```

Add:

```
0 */2 * * * /usr/local/bin/sync-audit-logs.sh >> /var/log/audit-sync.log 2>&1
```

4. Set log retention via lifecycle management for Blob Storage Account in Azure portal. We could also run below command:

```
az storage account management-policy create \
  --account-name $STORAGE_ACCOUNT_NAME \
  --policy '{
    "rules": [
      {
        "enabled": true,
        "name": "delete-after-90-days",
        "type": "Lifecycle",
        "definition": {
          "filters": {
            "blobTypes": ["blockBlob"]
          },
          "actions": {
            "baseBlob": {
              "delete": {
                "daysAfterModificationGreaterThan": 90
              }
            }
          }
        }
      }
    ]
  }'
```

