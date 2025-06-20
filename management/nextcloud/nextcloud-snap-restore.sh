#!/bin/bash
set -e

# === Config ===
BORG_REPO="/mnt/data/bbackup"
RESTORE_BASE="/var/snap/nextcloud/common/restore"
TMP_DIR="/tmp/nextcloud_restore_tmp"

# === Step 1: List available Borg archives
echo "🔍 Available Nextcloud Backups:"
borg list "$BORG_REPO" | grep nextcloud-export- | nl

# === Step 2: Ask user to choose one
read -p "Enter the number of the backup to restore: " CHOICE

ARCHIVE_NAME=$(borg list "$BORG_REPO" | grep nextcloud-export- | sed -n "${CHOICE}p" | awk '{print $1}')

if [ -z "$ARCHIVE_NAME" ]; then
  echo "❌ Invalid selection"
  exit 1
fi

echo "✅ Selected archive: $ARCHIVE_NAME"

# === Step 3: Extract Borg archive
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

echo "📦 Extracting archive..."
borg extract "$BORG_REPO::$ARCHIVE_NAME"

cd ./tmp
# === Step 4: Extract tar into Snap-visible restore directory
TAR_FILE=$(ls nextcloud-backup-*.tar)
FOLDER_NAME="${TAR_FILE%.tar}"

sudo mkdir -p "$RESTORE_BASE/$FOLDER_NAME"
sudo tar -xvf "$TAR_FILE" -C "$RESTORE_BASE/$FOLDER_NAME"

# === Step 5: Run nextcloud.import
echo "🚀 Restoring Nextcloud from backup..."
sudo nextcloud.import "$RESTORE_BASE/$FOLDER_NAME"

echo "✅ Done restoring from $ARCHIVE_NAME"

