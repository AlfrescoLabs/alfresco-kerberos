FROM osixia/openldap

# Add data for seeding
# ADD ldif/ldap-init.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/ldap-init.ldif

# Install krb5-admin-server
RUN apt-get -y update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       krb5-admin-server \
       runit \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sed \
    && sed -i "s/# Required-Start.*/& slapd/" /etc/init.d/krb5-kdc \
    && sed -i "s/# Required-Stop.*/& slapd/" /etc/init.d/krb5-kdc

RUN insserv /etc/init.d/krb5-kdc && insserv /etc/init.d/krb5-admin-server

# Add Kerberos schema (alternatively ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/kerberos.openldap.ldif)
# ADD bootstrap/schema/kerberos.ldif /container/service/slapd/assets/config/bootstrap/kerberos.ldif
ADD bootstrap/schema/kerberos.schema /container/service/slapd/assets/config/bootstrap/kerberos.schema

# Seed initial data
ADD bootstrap/custom /container/service/slapd/assets/config/bootstrap/ldif/custom

# Add Kerberos services
ADD service/z_krb5kdc /container/service/z_krb5kdc
ADD service/z_kadmind /container/service/z_kadmind
