printf "\n======== stop the running env ========\n\n"

docker-compose down -v;
sleep 10;
rm -rf ./keytabs/*keytab;

printf "\n======== build and run docker images ========\n\n"
docker-compose build;
docker-compose up -d;

printf "\n======== wait for ldap and kerberos sync ========\n\n"
# increase the time out if ldap and kerberos are getting connected in 1 min
sleep 60;

printf "\n======== indexing the LDAP user with Kerberos ========\n\n"

## index ldap user
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=alice,ou=People,dc=example,dc=com alice"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=bob,ou=People,dc=example,dc=com bob"

printf "\n======== create kerberos principles for server ========\n\n"
# Add principles for Alfresco and generate keytab
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=httpalfresco,ou=People,dc=example,dc=com HTTP/example.com@EXAMPLE.COM"
docker exec -ti kerberos kadmin.local -q "ktadd -k alfresco.keytab HTTP/example.com@EXAMPLE.COM"

printf "\n======== Available principles in the kerberos ========\n\n"
docker exec -ti kerberos kadmin.local -q "list_principals"

printf "\n======== configure the Alfresco with Kerberos ========\n\n"
KERBEROS=$(docker-compose ps -q kerberos);
ALFRESCO=$(docker-compose ps -q alfresco);
SHARE=$(docker-compose ps -q share);

docker cp ${KERBEROS}:/alfresco.keytab ./keytabs/
chmod 777 ./keytabs/alfresco.keytab
docker cp ./keytabs/alfresco.keytab ${ALFRESCO}:/etc/alfresco.keytab
docker cp ./keytabs/alfresco.keytab ${SHARE}:/etc/share.keytab

docker-compose restart alfresco
docker-compose restart share

printf "\n======== kerberos configuration is over. Here is the tail ========\n\n"
#docker logs -f alfresco &
#docker logs -f share &
