#!/bin/bash

# =====================================================
# Auto Backup Script untuk Database Apotek Modern
# =====================================================

# Konfigurasi
DB_USER="root"
DB_PASS="root"
DB_NAME="apotek_modern"
BACKUP_DIR="/var/backups/mysql"
RETENTION_DAYS=30
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/apotek_$DATE.sql"
LOG_FILE="$BACKUP_DIR/backup.log"

# Buat direktori jika belum ada
mkdir -p $BACKUP_DIR

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE
}

# Mulai backup
log "Starting backup of database $DB_NAME"

# Backup dengan mysqldump
mysqldump -u $DB_USER -p$DB_PASS \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    $DB_NAME > $BACKUP_FILE 2>> $LOG_FILE

# Cek hasil backup
if [ $? -eq 0 ]; then
    # Kompress backup
    gzip $BACKUP_FILE
    log "Backup completed successfully: $BACKUP_FILE.gz"
    
    # Hitung ukuran
    SIZE=$(du -h $BACKUP_FILE.gz | cut -f1)
    log "Backup size: $SIZE"
    
    # Hapus backup lama
    find $BACKUP_DIR -name "apotek_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    log "Removed backups older than $RETENTION_DAYS days"
else
    log "ERROR: Backup failed!"
    exit 1
fi

# Optional: Upload ke cloud storage (S3, Google Drive, dll)
# aws s3 cp $BACKUP_FILE.gz s3://your-bucket/backups/

log "Backup process completed"