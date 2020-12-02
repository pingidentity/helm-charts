# License Configuration

Provides a secret used for obtaining evaluation licenses for Ping Identity products.

## Global Section

Default yaml defined in the global license section, followed by definitions for each parameter.

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
    Assumes use of the [ping-devops command-line](https://pingidentity-devops.gitbook.io/devops/devopsutils/pingdevopsutil#installation) tool to create the `devops-secret` with your
    [Ping Identity DevOps User & Key](https://pingidentity-devops.gitbook.io/devops/getstarted/devopsregistration).

    ```shell
    ping-devops generate devops-secret | kubectl apply -f -
    ```
