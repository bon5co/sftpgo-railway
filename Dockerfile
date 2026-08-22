# SFTPGo for Railway.
#
# Upstream runs as uid 1000 and Railway mounts volumes owned by uid 0, so the stock
# image cannot write its own data directory. This wrapper starts as root, prepares
# and chowns the mount, then drops back to the sftpgo user before exec'ing the server.
#
# It also relocates everything that must survive a redeploy onto the single Railway
# volume at /var/lib/sftpgo: the SQLite data provider, every user's home directory
# (upstream defaults to /srv/sftpgo/data, which is NOT on the mount), the backup
# directory, and the SSH host keys (upstream regenerates them into /etc/sftpgo on
# every boot, which makes every SFTP client report a changed host key).
FROM drakkan/sftpgo@sha256:d1e2877600aba270ac395bf76fc7c8a2a0bb4ac83c3e6c180a0540f5d4c3efb2

USER root
RUN apk add --no-cache su-exec

ENV SFTPGO_DATA_PROVIDER__DRIVER=sqlite \
    SFTPGO_DATA_PROVIDER__NAME=/var/lib/sftpgo/sftpgo.db \
    SFTPGO_DATA_PROVIDER__USERS_BASE_DIR=/var/lib/sftpgo/data \
    SFTPGO_DATA_PROVIDER__BACKUPS_PATH=/var/lib/sftpgo/backups \
    SFTPGO_DATA_PROVIDER__CREATE_DEFAULT_ADMIN=1 \
    SFTPGO_DEFAULT_ADMIN_USERNAME=admin \
    SFTPGO_SFTPD__BINDINGS__0__ADDRESS= \
    SFTPGO_SFTPD__BINDINGS__0__PORT=2022 \
    SFTPGO_SFTPD__HOST_KEYS=/var/lib/sftpgo/keys/id_ecdsa,/var/lib/sftpgo/keys/id_ed25519,/var/lib/sftpgo/keys/id_rsa \
    SFTPGO_HTTPD__BINDINGS__0__ADDRESS= \
    SFTPGO_HTTPD__BINDINGS__0__PORT=8080 \
    SFTPGO_HTTPD__BINDINGS__0__ENABLE_WEB_ADMIN=1 \
    SFTPGO_HTTPD__BINDINGS__0__ENABLE_WEB_CLIENT=1 \
    SFTPGO_HTTPD__BINDINGS__0__PROXY_ALLOWED=0.0.0.0/0 \
    SFTPGO_HTTPD__BINDINGS__0__CLIENT_IP_PROXY_HEADER=X-Forwarded-For \
    SFTPGO_HTTPD__BINDINGS__0__CLIENT_IP_HEADER_DEPTH=0 \
    SFTPGO_HTTPD__TOKEN_VALIDATION=1 \
    SFTPGO_TELEMETRY__BIND_PORT=0 \
    SFTPGO_LOG_FILE_PATH=

COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod +x /usr/local/bin/railway-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
CMD ["sftpgo", "serve"]
