#!/usr/bin/env zsh
# Script to find and archive old log files

setopt extended_glob null_glob

LOG_DIR="${1:-/var/log}"
ARCHIVE_DIR="${LOG_DIR}/archive"
MAX_AGE_DAYS=30

[[ -d "$ARCHIVE_DIR" ]] || mkdir -p "$ARCHIVE_DIR"

typeset -a old_logs
old_logs=( ${LOG_DIR}/**/*.log(.m+${MAX_AGE_DAYS}) )

if (( ${#old_logs} == 0 )); then
    print "No log files older than ${MAX_AGE_DAYS} days found."
    exit 0
fi

print "Found ${#old_logs} log files to archive..."

for logfile in $old_logs; do
    archive_name="${ARCHIVE_DIR}/${logfile:t:r}_$(date +%Y%m%d).gz"
    gzip -c "$logfile" > "$archive_name" && rm "$logfile"
    print "  Archived: ${logfile:t} -> ${archive_name:t}"
done

print "Done. Archived ${#old_logs} files."
