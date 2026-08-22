#!/bin/sh
# Runs as root. Prepare the Railway volume, then drop privileges to the sftpgo user.
set -e

DATA_DIR=/var/lib/sftpgo

mkdir -p "$DATA_DIR/data" "$DATA_DIR/backups" "$DATA_DIR/keys"
chown -R 1000:1000 "$DATA_DIR"
echo "[railway-entrypoint] $DATA_DIR owner=$(stat -c %u:%g "$DATA_DIR") data=$(stat -c %u:%g "$DATA_DIR/data")"

if [ -z "$SFTPGO_DEFAULT_ADMIN_PASSWORD" ]; then
    echo "[railway-entrypoint] FATAL: SFTPGO_DEFAULT_ADMIN_PASSWORD is empty." >&2
    echo "[railway-entrypoint] Refusing to start an admin panel that any visitor could claim." >&2
    exit 1
fi

exec su-exec 1000:1000 "$@"
