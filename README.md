# Alfresco Kerberos Test

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

### Accessing Keycloak

* URL: http://keycloak.127.0.0.1.nip.io:8080

* Username: `admin`

* Password: `password`

* OIDC Endpoint: `http://keycloak.127.0.0.1.nip.io:8080/auth/realms/{realm}/.well-known/openid-configuration`

* Authorization Endpoint: `http://keycloak.127.0.0.1.nip.io:8080/auth/realms/{realm}/protocol/openid-connect/auth`

* Account Management: `http://keycloak.127.0.0.1.nip.io:8080/auth/realms/{realm}/account`

### Kerberos Login Test

> Credentials: `alice@EXAMPLE.ORG` / `password`, `bob@EXAMPLE.ORG` / `password`


### Cleanup

```sh
# Cleanup
docker-compose rm -f
docker volume rm keycloak_vol-openldap-ldap keycloak_vol-openldap-slapd
```

## Creating new Users

Creating users is now a two-step process:

1. Create new user with ldapadd (if KeyCloak Kerberos configured to be backed by an LDAP server).

1. Create new KDC entry using `addprinc` (for Kerberos Authentication) and link it to the DN. E.g.:

   ```sh
   kadmin.local
   kadmin.local: addprinc -pw password -x dn=uid=charlie,ou=People,   dc=example,dc=org charlie
   ```

## Kerberos Setup Verification / Debugging

> Run the following commands in `keycloak-openldap` container: `docker exec -it keycloak-openldap bash`
> Default password for `ldapsearch` command is provided using `-w` flag. Use `-W` for interactive password prompt.

```sh
# Verify LDAP credentials
ldapwhoami -x -D "cn=admin,dc=example,dc=org" -w admin
ldapwhoami -x -D "uid=alice,ou=People,dc=example,dc=org" -w password

# Verify krbContainer container exists (numEntries: 1)
ldapsearch -L -x -D cn=admin,dc=example,dc=org -b dc=example,dc=org -w admin cn=krbContainer

# Verify ACL for kdc-service and kadmin-service (numEntries: 12)
ldapsearch -L -x -D uid=kdc-service,dc=example,dc=org -b cn=krbContainer,dc=example,dc=org -w password
ldapsearch -L -x -D uid=kadmin-service,dc=example,dc=org -b cn=krbContainer,dc=example,dc=org -w password

# Verify Kerberos services are started
service krb5-kdc status
service krb5-admin-server status

# Validate Kerberos token can be obtained using keytab file
kinit HTTP/keycloak.127.0.0.1.nip.io@EXAMPLE.ORG -k -t /etc/keytabs/keycloak.keytab
klist
kdestroy

# Login using SPNEGO
# 302 returned with access code: # http://js-console.127.0.0.1.nip.io:8000/?session_state=...&code=...
# To use existing ticket, use curl -I --negotiate -u : http://....
curl -I --negotiate -u alice@EXAMPLE.ORG:password "http://keycloak.127.0.0.1.nip.io:8080/auth/realms/dev/protocol/openid-connect/auth?client_id=js-console&redirect_uri=http%3A%2F%2Fjs-console.127.0.0.1.nip.io%3A8000%2F&response_type=code&scope=openid"
```

## Active Directory Setup

To generate a `keytab` file for Active Directory, create a service account / user e.g. `keycloak`.

```bat
REM Set service principal name
setspn -s HTTP/myapp.example.org keycloak

REM Generate keytab
ktpass -princ HTTP/myapp.example.org ^
  -mapuser keycloak@dev.pc8.dsta -crypto ALL ^
  -ptype KRB5_NT_PRINCIPAL -pass * -out C:\keycloak.keytab
```
