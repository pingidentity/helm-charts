# PrivateCert Configuration

Generates a private certificate (.crt and .key) based on the internal hostname of the service.

## Global Section

!!! Note
    privateCert is currently only supported by PingAccess.

Default yaml defined in the global privateCert section.  By default certificates will not be
generated.  It is advised to *NOT* generate internal certs at the global level, as many
services don't need a private cert on the internal service.

```yaml
global:
  ############################################################
  # Internal Certificates
  #
  # If set to true, then an internal certificate secret will
  # be created along with mount of the certificate in
  # /run/secrets/internal-cert (creates a tls.crt and tls.key)
  #
  # By default the Issuer of the cert will be the service name
  # created by the Helm Chart.  Additionally, the ingress hosts,
  # if enabled, will be added to the list of X509v3 Subject Alternative Name
  #
  # Use the additionalHosts and additionalIPs if additional custom
  # names and ips are needed.
  #
  #      privateCert.generate: {true | false}
  #      privateCert.additionalHosts: {optional array of hosts}
  #      privateCert.additionalIPs: {optional array of IP Addresses}
  ############################################################
  privateCert:
    generate: false
    additionalHosts: []
    additioanlIPs: []
```

## Product Section

Generating an internal certificate is as simple setting the `privateCert.generate` to `true`.

!!! note "Example of generating an internal certificate for pingaccess-engine"
    ```yaml
    pingaccess-admin:
      privateCert:
        generate:true
    ```

This will ultimately create a secret named `{release-productname}-private-cert`
containing a valid `tls.crt` and `tls.key`.

By default the Issuer of the cert will be the service name
created by the Helm Chart.  Additionally, the ingress hosts,
if enabled, will be added to the list of `X509v3 Subject Alternative Name`.

The product image will then create an init container to generate a pkcs12 file that will
be placed in `/run/secrets/private-keystore/keystore.env` that will be mounted into the
running container.

When the container's hooks are running, it will source the environment variables in this
keystore.env. The default variables set are:

* `PRIVATE_KEYSTORE_PIN={base64 random pin}`
* `PRIVATE_KEYSTORE_TYPE=pkcs12`
* `PRIVATE_KEYSTORE={pkcs12 keystore}`

These environment variables are required in the `data.json.subst` file in-order to use the generated privateCert. They can be 
used in any server-profile artifacts to be replaced when the images are started.