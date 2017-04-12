
## Prerequsite

Enable dm_* modules

    modprobe dm_snapshot
    modprobe dm_mirror
    modprobe dm_thin_pool

    cat <<EOT > /etc/modules-load.d/dm_snapshot.conf
    dm_snapshot
    dm_mirror
    dm_thin_pool
    EOT
