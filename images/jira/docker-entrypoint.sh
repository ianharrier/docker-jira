#!/bin/sh
set -e

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

if [ "$PROXY_HOSTNAME" -a "$PROXY_PORT" -a "$PROXY_SCHEME" ]; then
    PROXY_STRING="proxyName=\"$PROXY_HOSTNAME\" proxyPort=\"$PROXY_PORT\" scheme=\"$PROXY_SCHEME\""
    if [ ! "$(cat ${JIRA_INSTALL}/conf/server.xml | grep "<Connector $PROXY_STRING")" ]; then
        echo "[I] Configuring Catalina to operate behind a reverse proxy."
        sed -i "s/\(<Connector\)/\1 $PROXY_STRING/" ${JIRA_INSTALL}/conf/server.xml
    fi
fi

if [ "$JVM_MINIMUM_MEMORY" ]; then
    echo "[I] Setting JVM_MINIMUM_MEMORY."
    sed -i "s/^JVM_MINIMUM_MEMORY=.*/JVM_MINIMUM_MEMORY=\"$JVM_MINIMUM_MEMORY\"/g" ${JIRA_INSTALL}/bin/setenv.sh
fi

if [ "$JVM_MAXIMUM_MEMORY" ]; then
    echo "[I] Setting JVM_MAXIMUM_MEMORY."
    sed -i "s/^JVM_MAXIMUM_MEMORY=.*/JVM_MAXIMUM_MEMORY=\"$JVM_MAXIMUM_MEMORY\"/g" ${JIRA_INSTALL}/bin/setenv.sh
fi

echo "[I] Setting permissions on JIRA home directory."
chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_HOME}"
chmod -R u=rwx,go-rwx              "${JIRA_HOME}"

echo "[I] Entrypoint tasks complete. Starting JIRA."
exec gosu ${RUN_USER} "$@"
