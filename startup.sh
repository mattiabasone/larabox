#!/usr/bin/env bash

CONTAINER_GATEWAY=`/sbin/ip route|awk '/default/ { print $3 }'`

# Adding host machine hostname
echo -e "\n# Hostname for gateway" >> /etc/hosts
echo -e "${CONTAINER_GATEWAY}\tdocker.host.internal\n" >> /etc/hosts

# Override timezone by env
if [ "$TZ" != "" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# Override host user uid by env
if [ "$HOST_USER_UID" != "" ] || [ $HOST_USER_UID != 1000 ]; then
    usermod -u $HOST_USER_UID app && groupmod app -g $HOST_USER_UID
fi

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf