## start env
# todo remove this
#docker system prune -a --volumes -f;

docker-compose down -v;
sleep 10;
rm -rf ./keytabs/*keytab;

docker-compose build;
docker-compose up -d;
sleep 60;

## index ldap user
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=alice,ou=People,dc=example,dc=com alice"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=alice,ou=People,dc=example,dc=com bob"

#docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=httpalfresco,ou=People,dc=example,dc=com httpalfresco"
# Add principles for KeyCloak and generate keytab
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=httpalfresco,ou=People,dc=example,dc=com HTTP/example.com@EXAMPLE.COM"
docker exec -ti kerberos kadmin.local -q "ktadd -k alfresco.keytab HTTP/example.com@EXAMPLE.COM"

docker exec -ti kerberos kadmin.local -q "list_principals"

KERBEROS=$(docker-compose ps -q kerberos);
ALFRESCO=$(docker-compose ps -q alfresco);
docker cp ${KERBEROS}:/alfresco.keytab ./keytabs/
chmod 777 ./keytabs/alfresco.keytab
docker cp ./keytabs/alfresco.keytab ${ALFRESCO}:/etc/alfresco.keytab

docker-compose restart alfresco

docker logs -f alfresco
