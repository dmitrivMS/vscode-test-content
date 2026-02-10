#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/backup.log"
BACKUP_DIR="/backups/$(date +%Y-%m-%d)"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log "Created backup directory: $BACKUP_DIR"
fi

for db in postgres mysql; do
    log "Starting backup of $db..."
    pg_dump "$db" | gzip > "$BACKUP_DIR/${db}.sql.gz"
    log "Completed backup of $db"
done

find /backups -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
log "Cleaned up backups older than 30 days"
