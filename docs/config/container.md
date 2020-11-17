# Container Configuration

Provides values to define kubernetes container information to workload resources, such as
deployments and statefulsets.

More information on Kuernetes workload resources can be found [here](https://kubernetes.io/docs/concepts/workloads/controllers/).

The example found in the `global:` section is:

```yaml
  container:
    replicaCount: 1
    resources:
      requests:
        cpu: 500m
        memory: 500Mi
      limits:
        cpu: 4
        memory: 8Gi
    nodeSelector: {}
    tolerations: []
```

Translating to applicable kubernetes manifest sections:

```yaml
---

spec:
  replicas: 1
  template:
    spec:
      containers:
        resources:
          limits:
            cpu: 4
            memory: 8Gi
          requests:
            cpu: 500m
            memory: 500Mi
      nodeSelector: {}
      tolerations: []
```
