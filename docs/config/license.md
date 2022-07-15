# License Configuration

Provides a secret used for obtaining evaluation licenses for Ping Identity products.

## Global Section

Default yaml defined in the global license section, followed by definitions for each parameter:

```yaml
global:
  license:
    secret:
      devOps: devops-secret
```

| License Parameters | Description                                             | Default Value |
| ------------------ | ------------------------------------------------------- | ------------- |
| secret.devops      | Secret containing PING_IDENTITY_DEVOPS_USER/KEY values. | devops-secret |

!!! note "Creating your devops-secret"
    Use the [pingctl command-line](https://devops.pingidentity.com/tools/pingctlUtil/) tool to create the `devops-secret` with your
    [Ping Identity DevOps User & Key](https://devops.pingidentity.com/how-to/devopsRegistration/).

    ```shell
    pingctl kubernetes generate devops-secret | kubectl apply -f -
    ```
