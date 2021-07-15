## start env
// todo remove this
docker system prune -a --volumes -f;

docker-compose up -d;
sleep 60;

## index ldap user
docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=alice,ou=People,dc=example,dc=com alice"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=alice,ou=People,dc=example,dc=com bob"
docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=httpalfresco,ou=People,dc=example,dc=com httpalfresco"

#docker exec -ti kerberos mkdir -p /opt/
#docker exec -ti kerberos printf "%b" "add_entry -password -p httpalfresco@EXAMPLE.COM -k 1 -e aes256-cts-hmac-sha1-96\npassword\nwrite_kt alfresco.keytab" | ktutil