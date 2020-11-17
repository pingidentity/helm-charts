# Deployment Configuration

Provides values to define kubernetes depoyment information to deployments.

More information on Kuernetes deployment resources can be found [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

The example found in the `global:` section is:

```yaml
  deployment:
    strategy:
      type: RollingUpdate
  #   type: Recreate
      rollingUpdate:
        maxSurge: 1
        maxUnavailable: 0
```

Translating to kubernetes manifest information:

```yaml
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
```
