FROM alfresco/process-services:1.11.0

ARG TOMCAT_DIR=/usr/local/tomcat

USER root

#Uncomment the following lines for deploying extensions
#RUN rm -rf $TOMCAT_DIR/webapps/activiti-app
#COPY extensions/aps-extensions-jar-${project.version}.jar $TOMCAT_DIR/webapps/activiti-app/WEB-INF/lib
#COPY extensions/activiti-app.war $TOMCAT_DIR/webapps

#COPY logging/logback.xml $TOMCAT_DIR/lib

COPY properties/activiti-app.properties $TOMCAT_DIR/lib
COPY properties/activiti-ldap.properties $TOMCAT_DIR/lib

COPY activiti-license/*.* $TOMCAT_DIR/lib/


RUN yum install -y krb5-workstation

COPY kerberos_files/krb5.conf /etc
COPY kerberos_files/alfresco.keytab /etc
COPY kerberos_files/java.login.config /usr/java/default/conf/security

RUN chown -R root:root /usr/java/default/conf/security /etc/krb5.conf
RUN echo "login.config.url.1=file:/usr/java/default/conf/security/java.login.config" >> /usr/java/default/conf/security/java.security
