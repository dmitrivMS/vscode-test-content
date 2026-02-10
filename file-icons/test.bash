#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/var/log/backup"
BACKUP_DIR="/mnt/backups/$(date +%Y-%m-%d)"
RETENTION_DAYS=30

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/backup.log"
}

log "Starting database backup..."

if pg_dump -U postgres -F c -Z 9 appdb > "$BACKUP_DIR/appdb.dump"; then
    log "Database backup completed successfully."
else
    log "ERROR: Database backup failed with exit code $?."
    exit 1
fi

find /mnt/backups -type d -mtime +$RETENTION_DAYS -exec rm -rf {} + 2>/dev/null || true
log "Cleaned up backups older than $RETENTION_DAYS days."
