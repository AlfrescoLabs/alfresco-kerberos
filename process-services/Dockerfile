FROM alfresco/process-services:1.11.4

ARG TOMCAT_DIR=/usr/local/tomcat

USER root

#Uncomment the following lines for deploying extensions
#RUN rm -rf $TOMCAT_DIR/webapps/activiti-app
#COPY extensions/aps-extensions-jar-${project.version}.jar $TOMCAT_DIR/webapps/activiti-app/WEB-INF/lib
#COPY extensions/activiti-app.war $TOMCAT_DIR/webapps

COPY logback.xml $TOMCAT_DIR/lib

COPY properties/activiti-app.properties $TOMCAT_DIR/lib
COPY properties/activiti-ldap.properties $TOMCAT_DIR/lib

COPY license/*.* $TOMCAT_DIR/lib/


RUN yum install -y krb5-workstation

COPY kerberos_files/krb5.conf /etc
#COPY kerberos_files/process.keytab /etc
COPY kerberos_files/java.login.config ${JAVA_HOME}/conf/security

RUN chown -R root:root ${JAVA_HOME}/conf/security /etc/krb5.conf
RUN echo "login.config.url.1=file:${JAVA_HOME}/conf/security/java.login.config" >> ${JAVA_HOME}/conf/security/java.security
