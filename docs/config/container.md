# Container Configuration

[Kubernetes Workload Controller](https://kubernetes.io/docs/concepts/workloads/controllers/) resources:

* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

are created depending on configuration values.

## Global Section

Default yaml defined in the global ingress section.

```yaml
global:
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
    affinity: {}
    terminationGracePeriodSeconds: 30
    securityContext: {}
```
