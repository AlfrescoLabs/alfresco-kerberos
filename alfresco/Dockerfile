FROM alfresco/alfresco-content-repository:6.2.2.3

# Customize container: Single Sign On via Kerberos

USER root

RUN yum install -y krb5-workstation

COPY kerberos_files/krb5.conf /etc
#COPY kerberos_files/alfresco.keytab /etc
COPY kerberos_files/java.login.config ${JAVA_HOME}/conf/security

RUN chown -R root:root ${JAVA_HOME}/conf/security /etc/krb5.conf
RUN echo "login.config.url.1=file:${JAVA_HOME}/conf/security/java.login.config" >> ${JAVA_HOME}/conf/security/java.security
    
USER alfresco
