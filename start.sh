## start env
docker-compose up -d;
sleep 60;

## index ldap user
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=alice,ou=People,dc=example,dc=com alice"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=alice,ou=People,dc=example,dc=com bob"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=httpalfresco,ou=People,dc=example,dc=com httpalfresco"


