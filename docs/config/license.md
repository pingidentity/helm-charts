# License Configuration

Provides values to define an `envFrom` to a secret used for obtaining evaluation
licenses for Ping Identity products.

Assumes use of the [ping-devops command-line](https://pingidentity-devops.gitbook.io/devops/devopsutils/pingdevopsutil#installation) tool to create the devops-secret with your
[Ping Identity DevOps User & Key](https://pingidentity-devops.gitbook.io/devops/getstarted/devopsregistration).

```shell
ping-devops generate devops-secret | kubectl apply -f -
```

The example found in the `global:` section is:

```yaml
  license:
    secret:
      devOps: devops-secret
```

Translating to kubernetes manifest information:

```yaml
         envFrom:
         - secretRef:
             name: devops-secret
             optional: true
```
