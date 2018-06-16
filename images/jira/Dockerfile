FROM debian:9

#-------------------------------------------------------------------------------
#  Oracle Server JRE (http://www.oracle.com/technetwork/java/javase/downloads)
#-------------------------------------------------------------------------------

ARG JAVA_VERSION
ARG JAVA_UPDATE
ARG JAVA_BUILD
ARG JAVA_SIG

ENV JAVA_HOME="/usr/java/server-jre-${JAVA_VERSION}u${JAVA_UPDATE}"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && mkdir -p "${JAVA_HOME}" \
        && curl --location --retry 3 --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
               http://download.oracle.com/otn-pub/java/jdk/"${JAVA_VERSION}"u"${JAVA_UPDATE}"-b"${JAVA_BUILD}"/"${JAVA_SIG}"/server-jre-"${JAVA_VERSION}"u"${JAVA_UPDATE}"-linux-x64.tar.gz \
             | tar -xz --directory "${JAVA_HOME}" --strip-components=1 --no-same-owner \
        && apt-get -y purge --auto-remove \
               curl \
        && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
#  gosu (https://github.com/tianon/gosu)
#-------------------------------------------------------------------------------

ARG GOSU_VERSION

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && curl --location --retry 3 \
               --output /usr/local/bin/gosu \
               https://github.com/tianon/gosu/releases/download/"${GOSU_VERSION}"/gosu-"$(dpkg --print-architecture)" \
        && chmod +x /usr/local/bin/gosu \
        && gosu nobody true \
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
        && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
