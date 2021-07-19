# Alfresco Kerberos Test
### How to run 
```shell
    ./start.sh
    # assuming the docker compose created env correctly
    kinit #authendicate with user
    google-chrome  --auth-server-whitelist="http://example.com" --auth-negotiate-delegate-whitelist="http://example.com"
```

### LDAP Details

* BaseDn: `cn=admin,dc=example,dc=com`

* Password: `admin`


## QuickStart

### Kerberos Setup

> Review permissions of volume mounts to ensure file permissions are at least 644.

```sh
# Start services using Docker Compose
docker-compose up

# Verify valid keytab file generated
docker exec keycloak-openldap kinit HTTP/keycloak.127.0.0.1.nip.io@EXAMPLE.ORG -k -t /etc/keytabs/keycloak.keytab
# List and destroy Kerberos ticket
docker exec keycloak-openldap klist
docker exec keycloak-openldap kdestroy

# Verify permissions of shared keytab file to ensure it can be read by Keycloak
docker exec --user root keycloak chmod 644 /tmp/keytabs/keycloak.keytab
```

### Kerberos Login Test

> Credentials: `alice@EXAMPLE.ORG` / `password`, `bob@EXAMPLE.ORG` / `password`


### Cleanup

```sh
# Cleanup
docker-compose rm -f
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

> Run the following commands in `openldap` container: `docker exec -it openldap bash`
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
