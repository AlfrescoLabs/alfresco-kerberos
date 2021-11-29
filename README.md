# Alfresco Kerberos
   This project provides the simple [alfresco with kerberos](https://docs.alfresco.com/identity-service/latest/tutorial/sso/kerberos/) enabled env for testing purposes.
   ![kerberos env](https://docs.alfresco.com/identity-service/images/kerberos.png)
   
 ![auto-login](https://user-images.githubusercontent.com/14145706/143895176-4ab0b4b6-96a4-40c7-90f4-8a5f256fe27d.gif)


### Steps involved in the simple kerberos setup
1. [Run the environment](#how-to-start)
2. [Configure kerberos client against the environment](#configure-kerberos-client)
3. [Configure browser to support the kerberos authentication](#configure-kerberos-with-browser)
4. [Open the application url](#configure-kerberos-with-browser)

### How to start
To run the environment, use the start.sh shell script.
```shell
./start.sh # start the docker compose created env
```
Try to execute the startsh shell script to run the environment. [click here for example logs](#example-logs)


### License

* ACS - comes with 2 days free license 
* APS - keep the licence inside `process-services/license` folder

## configure kerberos client

- update the OS [hosts file](https://www.makeuseof.com/tag/modify-manage-hosts-file-linux/#:~:text=The%20hosts%20file%20is%20a,connect%20to%20the%20appropriate%20server.) `<docker machine ip> example.com` or dns for docker-compose to `example.com`
- install the kerberos client `sudo apt-get install krb5-user`
- update the configuration to reach the docker compose server ⬇️

Add/update the file `/etc/krb5.conf`

```shell script
[libdefaults]
    default_realm = EXAMPLE.COM
    ignore_acceptor_hostname = true

[realms]
    EXAMPLE.COM = {
          kdc = example.com:88
          admin_server = example.com:749
    }

[domain_realm]
    .example.com = EXAMPLE.COM
    example.com = EXAMPLE.COM

```
## commands to login

 - `kinit <optional username>` # login with system user or give user
 - `klist` # list the available session

## configure kerberos with browser 
Here is command for chrome with kerberos. [read here for other browser](https://www.adaxes.com/help/EnableKerberosNTLMAuthentication/)

```
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

## Example logs
```Creating network "alfresco-kerberos_alfresco-network" with driver "bridge"
Creating volume "alfresco-kerberos_vol-openldap-ldap" with default driver
Creating volume "alfresco-kerberos_vol-openldap-slapd" with default driver
Creating volume "alfresco-kerberos_shared-file-store-volume" with default driver
Creating alfresco-kerberos_elasticsearch_1      ... done
Creating workspace                              ... done
Creating alfresco-kerberos_postgres_1           ... done
Creating alfresco-kerberos_activemq_1          ... done
Creating alfresco-kerberos_shared-file-store_1 ... done
Creating alfresco-kerberos_postgres-process_1   ... done
Creating alfresco-kerberos_solr6_1              ... done
Creating openldap                              ... done
Creating alfresco                               ... done
Creating kerberos                               ... done
Creating alfresco-kerberos_transform-router_1   ... done
Creating alfresco-kerberos_transform-core-aio_1 ... done
Creating process                                ... done
Creating share                                  ... done
Creating proxy                                  ... done

======== wait for ldap and kerberos sync ========


======== indexing the LDAP user with Kerberos ========

Authenticating as principal root/admin@EXAMPLE.COM with password.
WARNING: no policy specified for alice@EXAMPLE.COM; defaulting to no policy
Principal "alice@EXAMPLE.COM" created.
Authenticating as principal root/admin@EXAMPLE.COM with password.
WARNING: no policy specified for bob@EXAMPLE.COM; defaulting to no policy
Principal "bob@EXAMPLE.COM" created.
Authenticating as principal root/admin@EXAMPLE.COM with password.
WARNING: no policy specified for dhrn@EXAMPLE.COM; defaulting to no policy
Principal "dhrn@EXAMPLE.COM" created.
Authenticating as principal root/admin@EXAMPLE.COM with password.
WARNING: no policy specified for administrator@EXAMPLE.COM; defaulting to no policy
Principal "administrator@EXAMPLE.COM" created.

======== create kerberos principles for server ========

Authenticating as principal root/admin@EXAMPLE.COM with password.
WARNING: no policy specified for HTTP/example.com@EXAMPLE.COM; defaulting to no policy
Principal "HTTP/example.com@EXAMPLE.COM" created.
Authenticating as principal root/admin@EXAMPLE.COM with password.
Entry for principal HTTP/example.com@EXAMPLE.COM with kvno 2, encryption type aes256-cts-hmac-sha1-96 added to keytab WRFILE:example.keytab.
Entry for principal HTTP/example.com@EXAMPLE.COM with kvno 2, encryption type aes128-cts-hmac-sha1-96 added to keytab WRFILE:example.keytab.

======== available principles in the kerberos ========

Authenticating as principal root/admin@EXAMPLE.COM with password.
alice@EXAMPLE.COM
bob@EXAMPLE.COM
dhrn@EXAMPLE.COM
administrator@EXAMPLE.COM
HTTP/example.com@EXAMPLE.COM
K/M@EXAMPLE.COM
krbtgt/EXAMPLE.COM@EXAMPLE.COM
kadmin/admin@EXAMPLE.COM
kadmin/af3a75f6db2e@EXAMPLE.COM
kiprop/af3a75f6db2e@EXAMPLE.COM
kadmin/changepw@EXAMPLE.COM
kadmin/history@EXAMPLE.COM

======== configure the Alfresco with Kerberos ========

Restarting alfresco ... done
Restarting process ... done

======== kerberos configuration is over ======== 

usefull commands :
 docker logs -f process 
 docker logs -f alfresco 
 docker exec -it process sh 
 docker exec -it alfresco sh 

======== completed ========
```

## DISCLIMER

If you are facing any issues with kerberos, just try to rerun the `./start.sh`
Sometime kerberos server fails to start becase of port issue, check it before retrying


## More info about environment

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

## Kerberos Setup Verification

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

## Cleanup

```sh
# Cleanup
docker-compose down -v
```
