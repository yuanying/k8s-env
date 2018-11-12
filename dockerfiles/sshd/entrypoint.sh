#!/bin/sh -e

if [ "${ROOT_PASSWORD}" != "" ]; then
    echo "root:${ROOT_PASSWORD}" |chpasswd
fi

exec "$@"