FROM alfresco/alfresco-share:6.2.2.4
# Files to be included in container

USER root

RUN yum install -y krb5-workstation

COPY kerberos_files/krb5.conf /etc
#COPY kerberos_files/share.keytab /etc
COPY kerberos_files/java.login.config ${JAVA_HOME}/conf/security
COPY kerberos_files/share-config-custom.xml /usr/local/tomcat/shared/classes/alfresco/web-extension/

RUN chown -R root:root ${JAVA_HOME}/conf/security /etc/krb5.conf
RUN echo "login.config.url.1=file:${JAVA_HOME}/conf/security/java.login.config" >> ${JAVA_HOME}/conf/security/java.security
