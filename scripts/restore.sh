#!/bin/bash

# =====================================================
# Restore Script untuk Database Apotek Modern
# =====================================================

# Konfigurasi
DB_USER="root"
DB_PASS="root"
DB_NAME="apotek_modern"
BACKUP_DIR="/var/backups/mysql"

# Cek parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 apotek_20241201_020000.sql.gz"
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/$1"
LOG_FILE="$BACKUP_DIR/restore.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Cek file backup
if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Backup file not found: $BACKUP_FILE"
    exit 1
fi

log "Starting restore from $BACKUP_FILE"

# Konfirmasi
read -p "WARNING: This will OVERWRITE existing database. Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Restore cancelled by user"
    exit 1
fi

# Restore database
log "Dropping existing database..."
mysql -u $DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS $DB_NAME" 2>> $LOG_FILE
mysql -u $DB_USER -p$DB_PASS -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci" 2>> $LOG_FILE

# Restore from backup
if [[ $BACKUP_FILE == *.gz ]]; then
    gunzip -c $BACKUP_FILE | mysql -u $DB_USER -p$DB_PASS $DB_NAME 2>> $LOG_FILE
else
    mysql -u $DB_USER -p$DB_PASS $DB_NAME < $BACKUP_FILE 2>> $LOG_FILE
fi

if [ $? -eq 0 ]; then
    log "Restore completed successfully!"
    
    # Verifikasi
    TABLE_COUNT=$(mysql -u $DB_USER -p$DB_PASS -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME'" -s -N 2>/dev/null)
    log "Database restored with $TABLE_COUNT tables"
else
    log "ERROR: Restore failed!"
    exit 1
fi