# sftpgo-railway

Wrapper image for deploying [SFTPGo](https://github.com/drakkan/sftpgo) on Railway.

Upstream `drakkan/sftpgo` is pinned by digest (2.7.5). This image changes three things:

1. **The volume is made writable.** Railway mounts volumes as uid 0 and upstream runs as
   uid 1000, so the stock image cannot write its own data directory.
2. **Everything stateful is moved onto the single Railway volume** at `/var/lib/sftpgo` —
   SQLite data provider, user home directories, backups, and the SSH host keys. Upstream
   puts user homes at `/srv/sftpgo/data` and host keys in `/etc/sftpgo`, neither of which
   is on the mount, so both are lost on every redeploy.
3. **The container refuses to start without an admin password**, so the deploy cannot
   silently expose a claimable admin panel.

Built and pushed by GitHub Actions to `ghcr.io/bon5co/sftpgo-railway`.
