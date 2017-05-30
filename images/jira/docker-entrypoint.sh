#!/bin/sh
set -e

echo "[I] Setting permissions on JIRA home directory."
chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_HOME}"
chmod -R u=rwx,go-rwx              "${JIRA_HOME}"

if [ "$PROXY_HOSTNAME" -a "$PROXY_PORT" -a "$PROXY_SCHEME" ]; then
    PROXY_STRING="proxyName=\"$PROXY_HOSTNAME\" proxyPort=\"$PROXY_PORT\" scheme=\"$PROXY_SCHEME\""
    if [ ! "$(cat ${JIRA_INSTALL}/conf/server.xml | grep "<Connector $PROXY_STRING")" ]; then
        echo "[I] Configuring Catalina to operate behind a reverse proxy."
        sed -i "s/\(<Connector\)/\1 $PROXY_STRING/" ${JIRA_INSTALL}/conf/server.xml
    fi
fi

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

echo "[I] Entrypoint tasks complete. Starting JIRA."
exec gosu ${RUN_USER} "$@"
