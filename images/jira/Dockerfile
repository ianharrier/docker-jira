FROM debian:9

#-------------------------------------------------------------------------------
#  AdoptOpenJDK (https://adoptopenjdk.net/releases.html)
#-------------------------------------------------------------------------------

ARG JAVA_VERSION
ARG JAVA_UPDATE
ARG JAVA_BUILD

ENV JAVA_HOME="/usr/java/jdk${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}-jre"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && mkdir -p "${JAVA_HOME}" \
        && curl --location --retry 3 \
               https://github.com/AdoptOpenJDK/openjdk"${JAVA_VERSION}"-binaries/releases/download/jdk"${JAVA_VERSION}"u"${JAVA_UPDATE}"-b"${JAVA_BUILD}"/OpenJDK"${JAVA_VERSION}"U-jre_x64_linux_hotspot_"${JAVA_VERSION}"u"${JAVA_UPDATE}"b"${JAVA_BUILD}".tar.gz \
             | tar -xz --directory "${JAVA_HOME}" --strip-components=1 --no-same-owner \
        && apt-get -y purge --auto-remove \
               curl \
        && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
#  Jira (https://www.atlassian.com/software/jira/core/update)
#-------------------------------------------------------------------------------

ARG JIRA_VERSION

ENV JIRA_HOME=/var/atlassian/application-data/jira
ENV JIRA_INSTALL=/opt/atlassian/jira
ENV RUN_USER=daemon
ENV RUN_GROUP=daemon

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && mkdir -p                           "${JIRA_INSTALL}" \
        && curl --location --retry 3 \
               https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-"${JIRA_VERSION}".tar.gz \
             | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
        && chmod -R u=rwx,go-rwx              "${JIRA_INSTALL}" \
        && chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_INSTALL}" \
        && mkdir -p                           "${JIRA_HOME}" \
        && chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_HOME}" \
        && chmod -R u=rwx,go-rwx              "${JIRA_HOME}" \
        && echo -e "\njira.home=${JIRA_HOME}" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
        && apt-get -y purge --auto-remove \
               curl \
        && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

VOLUME ["${JIRA_HOME}"]

WORKDIR ${JIRA_INSTALL}

CMD ["./bin/catalina.sh","run"]

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && apt-get update && apt-get -y install \
               gosu \
        && chmod +x /usr/local/bin/docker-entrypoint \
        && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint"]
