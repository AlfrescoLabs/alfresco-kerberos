printf "\n======== stop the running env ========\n"

docker-compose down -v;
sleep 10;
rm -rf ./keytabs/*keytab;

printf "\n======== build and run docker images ========\n"
docker-compose build;
docker-compose up -d;
sleep 60;

printf "\n======== indexing the LDAP user with Kerberos ========\n"

## index ldap user
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=alice,ou=People,dc=example,dc=com alice"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=bob,ou=People,dc=example,dc=com bob"

printf "\n======== kerberos principles for server ========\n"
# Add principles for KeyCloak and generate keytab
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=httpalfresco,ou=People,dc=example,dc=com HTTP/example.com@EXAMPLE.COM"
docker exec -ti kerberos kadmin.local -q "ktadd -k alfresco.keytab HTTP/example.com@EXAMPLE.COM"

printf "\n======== Available principles in the kerberos ========\n"
docker exec -ti kerberos kadmin.local -q "list_principals"

printf "\n======== configuring the Alfresco with Kerberos ========\n"
KERBEROS=$(docker-compose ps -q kerberos);
ALFRESCO=$(docker-compose ps -q alfresco);
docker cp ${KERBEROS}:/alfresco.keytab ./keytabs/
chmod 777 ./keytabs/alfresco.keytab
docker cp ./keytabs/alfresco.keytab ${ALFRESCO}:/etc/alfresco.keytab

docker-compose restart alfresco

printf "\n======== kerberos configuration is over. Here is the tail ========\n"
docker logs -f alfresco
