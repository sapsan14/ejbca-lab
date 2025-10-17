If snapshots/backups are needed

For safety, you can create volume backups:

## Backup MariaDB volume

```bash
podman run --rm -v ejbca-lab_ejbca-db-data:/data -v $(pwd):/backup alpine \
    tar czf /backup/ejbca-db-backup.tar.gz -C /data .
```

## Restore

```bash
podman run --rm -v ejbca-lab_ejbca-db-data:/data -v $(pwd):/backup alpine \
    tar xzf /backup/ejbca-db-backup.tar.gz -C /data
```


This way you can even completely reset the EJBCA container and then restart it without any data loss.


