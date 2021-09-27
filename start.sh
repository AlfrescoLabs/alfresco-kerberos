printf "\n======== stop the running env ========\n\n"

docker-compose down -v;
sleep 10;
rm -rf .keytabs && mkdir .keytabs;

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
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=dhrn,ou=People,dc=example,dc=com dhrn"

printf "\n======== create kerberos principles for server ========\n\n"
# Add principles for Alfresco and generate keytab
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=httpalfresco,ou=People,dc=example,dc=com HTTP/example.com@EXAMPLE.COM"
docker exec -ti kerberos kadmin.local -q "ktadd -k alfresco.keytab HTTP/example.com@EXAMPLE.COM"
# Add principles for Process and generate keytab
#docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=httpprocess,ou=People,dc=example,dc=com HTTP/process.example.com@EXAMPLE.COM"
#docker exec -ti kerberos kadmin.local -q "ktadd -k process.keytab HTTP/process.example.com@EXAMPLE.COM"

printf "\n======== Available principles in the kerberos ========\n\n"
docker exec -ti kerberos kadmin.local -q "list_principals"

printf "\n======== configure the Alfresco with Kerberos ========\n\n"
KERBEROS=$(docker-compose ps -q kerberos);
ALFRESCO=$(docker-compose ps -q alfresco);
SHARE=$(docker-compose ps -q share);
PROCESS=$(docker-compose ps -q process);

docker cp ${KERBEROS}:/alfresco.keytab .keytabs/
#docker cp ${KERBEROS}:/process.keytab .keytabs/
chmod 777 .keytabs/alfresco.keytab
#chmod 777 .keytabs/process.keytab

docker cp .keytabs/alfresco.keytab ${ALFRESCO}:/etc/alfresco.keytab
docker cp .keytabs/alfresco.keytab ${SHARE}:/etc/share.keytab
docker cp .keytabs/alfresco.keytab ${PROCES}:/etc/process.keytab
#docker cp .keytabs/process.keytab ${PROCES}:/etc/process.keytab

docker-compose restart alfresco
docker-compose restart share
docker-compose restart process

printf "\n======== kerberos configuration is over. Here is the tail ========\n\n"
#docker logs -f alfresco &
#docker logs -f share &
