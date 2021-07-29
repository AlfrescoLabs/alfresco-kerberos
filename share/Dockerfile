FROM alfresco/alfresco-share:7.0.1.1
# Files to be included in container

USER root

RUN yum install -y krb5-workstation

COPY kerberos_files/krb5.conf /etc
#COPY kerberos_files/share.keytab /etc
COPY kerberos_files/java.login.config.share /usr/java/default/conf/security/java.login.config
COPY kerberos_files/share-config-custom.xml /usr/local/tomcat/shared/classes/alfresco/web-extension/

RUN chown -R root:root /usr/java/default/conf/security /etc/krb5.conf
RUN echo "login.config.url.1=file:/usr/java/default/conf/security/java.login.config" >> /usr/java/default/conf/security/java.security
