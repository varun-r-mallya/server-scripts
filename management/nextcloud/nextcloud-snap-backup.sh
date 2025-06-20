#!/bin/bash
set -e

BORG_REPO="/mnt/data/bbackup"
SNAP_BACKUP_DIR="/var/snap/nextcloud/common/backups"
TAR_TMP="/tmp"

# === Step 1: Run nextcloud.export ===
echo "📦 Exporting Nextcloud..."
sudo nextcloud.export -abcd

# === Step 2: Find most recent export folder ===
EXPORT_DIR=$(ls -td "$SNAP_BACKUP_DIR"/20* | head -n 1)
FOLDER_NAME=$(basename "$EXPORT_DIR")
TAR_FILE="$TAR_TMP/nextcloud-backup-$FOLDER_NAME.tar"

echo "✅ Found export directory: $EXPORT_DIR"

# === Step 3: Tar the export directory ===
sudo tar -cvf "$TAR_FILE" -C "$SNAP_BACKUP_DIR" "$FOLDER_NAME"

# === Step 4: Create Borg backup ===
borg create --verbose --stats --compression zstd \
  "$BORG_REPO::nextcloud-export-$FOLDER_NAME" \
  "$TAR_FILE"

# === Step 5: Prune old backups ===
borg prune -v --list "$BORG_REPO" \
  --keep-daily=7 --keep-weekly=4 --keep-monthly=6

# === Step 6: Clean up ===
sudo rm -f "$TAR_FILE"
sudo rm -rf "$EXPORT_DIR"

