#!/bin/sh -e

DAEMON=keepalived
KEEPALIVED_CONFIG=${KEEPALIVED_CONFIG:-"/etc/keepalived/keepalived.cfg"}
POD_IP=${POD_IP:-""}

if [ "${POD_IP}" != "" ]; then
    echo "POD_IP: ${POD_IP}"
    NET_IFACE=$(ip -f inet -o addr | grep ${POD_IP} | cut -d' ' -f 2)
    echo "NET_IFACE: ${NET_IFACE}"
    echo "$(sed s/__NET_IFACE__/${NET_IFACE}/g ${KEEPALIVED_CONFIG})" > ${KEEPALIVED_CONFIG}
else
    echo "POD_IP is null"
fi



stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -TERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}

echo "Running $*"
if [ "$(basename $1)" = "$DAEMON" ]; then
    trap "stop; exit 0" INT TERM
    "$@" &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    exec "$@"
fi
