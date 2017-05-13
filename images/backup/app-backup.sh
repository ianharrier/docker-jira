#!/bin/sh
set -e

TIMESTAMP=$(date +%Y%m%dT%H%M%S%z)
START_TIME=$(date +%s)

cd "$HOST_PATH"

if [ "$OPERATION" = "disable" ]; then
  echo "[W] Backups are disabled."
  XML_RETENTION=$RETENTION
else
  XML_RETENTION=0

  if [ ! -d backups ]; then
    echo "[I] Creating backup directory."
    mkdir backups
  fi

  if [ -d backups/tmp_backup ]; then
    echo "[W] Cleaning up from a previously-failed execution."
    rm -rf backups/tmp_backup
  fi

  echo "[I] Creating working directory."
  mkdir -p backups/tmp_backup

  echo "[I] Backing up JIRA database."
  docker exec -i "$(docker-compose ps -q db 2>/dev/null)" su postgres -c 'pg_dump $POSTGRES_DB' > backups/tmp_backup/db.sql

  echo "[I] Backing up JIRA home directory."
  cp -a volumes/web/data backups/tmp_backup/home

  echo "[I] Compressing backup."
  tar -zcf backups/$TIMESTAMP.tar.gz -C backups/tmp_backup .

  echo "[I] Removing working directory."
  rm -rf backups/tmp_backup

  EXPIRED_BACKUPS=$(ls -1tr backups/*.tar.gz 2>/dev/null | head -n -$RETENTION)
  if [ "$EXPIRED_BACKUPS" ]; then
    echo "[I] Cleaning up expired backup(s):"
    for BACKUP in $EXPIRED_BACKUPS; do
      echo "      $BACKUP"
      rm "$BACKUP"
    done
  fi
fi

EXPIRED_XML_BACKUPS=$(ls -1tr volumes/web/data/export/*.zip 2>/dev/null | head -n -$XML_RETENTION)
if [ "$EXPIRED_XML_BACKUPS" ]; then
  echo "[I] Cleaning up expired XML backup(s):"
  for BACKUP in $EXPIRED_XML_BACKUPS; do
    echo "      $BACKUP"
    rm "$BACKUP"
  done
fi

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."
