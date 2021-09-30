#!/bin/sh

printf "\n======== stop the running env ========\n\n"

rm -rf .keytabs && mkdir .keytabs;
docker-compose down -v;
sleep 20;

printf "\n======== build and run docker images ========\n\n"
docker-compose build;
docker-compose up -d;

printf "\n======== wait for ldap and kerberos sync ========\n\n"
# increase the time out if ldap and kerberos are getting connected in 1 min
sleep 60;

printf "\n======== indexing the LDAP user with Kerberos ========\n\n"

## index ldap user
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=alice,ou=People,dc=example,dc=com alice"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=bob,ou=People,dc=example,dc=com bob"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=dhrn,ou=People,dc=example,dc=com dhrn"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=administrator,ou=People,dc=example,dc=com administrator"

printf "\n======== create kerberos principles for server ========\n\n"
# Add principles for Alfresco and generate keytab
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=httpalfresco,ou=People,dc=example,dc=com HTTP/example.com@EXAMPLE.COM"
docker exec -ti kerberos kadmin.local -q "ktadd -k example.keytab HTTP/example.com@EXAMPLE.COM"

printf "\n======== Available principles in the kerberos ========\n\n"
docker exec -ti kerberos kadmin.local -q "list_principals"

printf "\n======== configure the Alfresco with Kerberos ========\n\n"
KERBEROS=$(docker-compose ps -q kerberos);
ALFRESCO=$(docker-compose ps -q alfresco);
SHARE=$(docker-compose ps -q share);
PROCESS=$(docker-compose ps -q process);

docker cp ${KERBEROS}:/example.keytab .keytabs
chmod 777 .keytabs/example.keytab

docker cp .keytabs/example.keytab ${ALFRESCO}:/etc/alfresco.keytab
docker cp .keytabs/example.keytab ${SHARE}:/etc/share.keytab
docker cp .keytabs/example.keytab ${PROCESS}:/etc/process.keytab

docker-compose restart alfresco
docker-compose restart share
docker-compose restart process

printf "\n======== kerberos configuration is over. Here is the tail ========\n\n"

