# PrivateCert Configuration

Generates a private certificate (.crt and .key) based on the internal hostname of the service

## Global Section

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
  ############################################################
  privateCert:
    generate: false
```

## Product Section

Generating an internal certificate is as simple setting the `privateCert.generate` to `true`.


!!! note "Example of generating an internal certificate for pingaccess-engine"
```yaml
pingaccess-admin:
  privateCert:
    generate:false
```

This will ultimately create a secret named `{release-productname}-private-cert`
containing a valid `tls.crt` and `tls.key`.

The product image will then create an init container to generate a pkcs12 file that will
be placed in `/run/secrets/private-keystore/keystore.env` that will be mounted into the
running container.

When the container's hooks are running, it will source the environment variables in this
keystore.env. The default variables set are:

* `PRIVATE_KEYSTORE_PIN={base64 random pin}`
* `PRIVATE_KEYSTORE_TYPE=pkcs12`
* `PRIVATE_KEYSTORE={pkcs12 keystore}`

These environment variables can then be used in any server-profile artifacts to be replaced
when the images are started.