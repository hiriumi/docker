FROM centos:latest
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG CERT_DIR=/etc/pki/ca-trust/source/anchors
ARG JENKINS_WAR_SRC

ENV JENINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

RUN mkdir -p $JENKINS_HOME && chown ${uid}:${gid} $JENKINS_HOME \
	&& groupadd -g ${gid} ${group} && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN yum install -y epel-release
RUN yum install -y git curl ca-certificates java-11-openjdk-devel java-11-openjdk-headless
RUN yum update -y

# Use tini as subreaper in Docker contianer to adopt zombie processes
ARG TINI_VERSION=v0.18.0
ARG ARCHITECTURE=amd64

COPY tini_pub.gpg ${JENKINS_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${ARCHITECTURE} -o /sbin/tini \
	&& curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${ARCHITECTURE}.asc -o /sbin/tini.asc \
	&& gpg --import ${JENKINS_HOME}/tini_pub.gpg \
	&& gpg --verify /sbin/tini.asc \
	&& rm -rf /sbin/tini.asc /root/.gnupg \
	&& chmod +x /sbin/tini

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# Copy SSL certificate and register
# COPY ./certs/mycert.cer $CERT_DIR
RUN update-ca-trust

COPY ${JENKINS_WAR_SRC} /usr/share/jenkins/jenkins.war

RUN chown -R ${user} "${JENKINS_HOME}" /usr/share/jenkins/ref
COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY tini-shim.sh /bin/tini
RUN chown ${user} "/usr/local/bin/jenkins.sh"
RUN chown ${user} "/bin/tini"
RUN chmod 755 "/usr/local/bin/jenkins.sh"
RUN chmod 755 "/bin/tini"

EXPOSE ${http_port}
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

USER ${user}

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
