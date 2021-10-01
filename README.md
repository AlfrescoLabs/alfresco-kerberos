# Alfresco Kerberos
   This project provides the simple [alfresco with kerberos](https://docs.alfresco.com/identity-service/latest/tutorial/sso/kerberos/) enabled env for testing purposes.
   ![kerberos env](https://docs.alfresco.com/identity-service/images/kerberos.png)
   

### Steps to start with

```shell
    ./start.sh # start the docker compose created env
    # update the machine ip in the dns or host file to example.com
    kinit #authendicate with user (update krb5.conf with above domain name)
    klist # display the available session
    google-chrome  --auth-server-whitelist="http://example.com" --auth-negotiate-delegate-whitelist="http://example.com" http://example.com/workspace
```

### Users
Below table provide info about scaffold users

| Username  | Password |
| ------------- | ------------- |
| alice  | password  |
| bob  | password  |
| dhrn  | password  |
| administrator  | password  |

### License

* ACS - comes with 2 days free license 
* APS - keep the licence inside `process-services/license` folder

## More Info about environment


### LDAP

```text
BaseDn: cn=admin,dc=example,dc=com
Password: admin
```

### Kerberos

> Review permissions of volume mounts to ensure file permissions are at least 644.

```sh
# Start services using Docker Compose
docker-compose up

# Verify valid keytab file generated
docker exec kerberos kinit HTTP/example.com@EXAMPLE.ORG -k -t /etc/keytabs/alfresco.keytab
# List and destroy Kerberos ticket
docker exec kerberos klist
docker exec kerberos kdestroy

# Verify permissions of shared keytab file to ensure it can be read by Keycloak
docker exec --user root alfresco chmod 644 /etc/keytabs/alfresco.keytab
```

## Creating new Users

Creating users is now a two-step process:

1. Create new user with ldapadd.

1. Create new KDC entry using `addprinc` (for Kerberos Authentication) and link it to the DN. E.g.:

   ```sh
   docker exec -ti kerberos kadmin.local -q "addprinc -pw password -x dn=uid=alice,ou=People,dc=example,dc=com alice"
   docker exec -ti kerberos kadmin.local -q "addprinc -pw password  -x dn=uid=alice,ou=People,dc=example,dc=com bob"
   ```

## Kerberos Setup Verification / Debugging

> Run the following commands in `kerberos` container: `docker exec -it kerberos bash`
> Default password for `ldapsearch` command is provided using `-w` flag. Use `-W` for interactive password prompt.

```sh
# Verify LDAP credentials
ldapwhoami -x -D "cn=admin,dc=example,dc=com" -w admin
ldapwhoami -x -D "uid=alice,ou=People,dc=example,dc=com" -w password

# Verify krbContainer container exists (numEntries: 1)
ldapsearch -L -x -D cn=admin,dc=example,dc=com -b dc=example,dc=com -w admin cn=krbContainer

# Verify ACL for kdc-service and kadmin-service (numEntries: 12)
ldapsearch -L -x -D uid=kdc-service,dc=example,dc=com -b cn=krbContainer,dc=example,dc=com -w password
ldapsearch -L -x -D uid=kadmin-service,dc=example,dc=com -b cn=krbContainer,dc=example,dc=com -w password

# Verify Kerberos services are started
service krb5-kdc status
service krb5-admin-server status

# Validate Kerberos token can be obtained using keytab file
kinit HTTP/alfresco@EXAMPLE.ORG -k -t /etc/keytabs/alfresco.keytab
klist
kdestroy
```

### Cleanup

```sh
# Cleanup
docker-compose down -v
```
