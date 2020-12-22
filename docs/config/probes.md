# Probes Configuration

[Kubernetes Probes resources](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
to be added to workloads (i.e. Deployments/StatefulSets).

## Global Section

Default yaml defined in the global probes section.

```yaml
global:
  probes:
    liveness:
      command: /opt/liveness.sh
      initialDelaySeconds: 30
      periodSeconds: 30
      timeoutSeconds: 5
      successThreshold: 1
      failureThreshold: 4
    readiness:
      command: /opt/liveness.sh
      initialDelaySeconds: 30
      periodSeconds: 30
      timeoutSeconds: 5
      successThreshold: 1
      failureThreshold: 4
```

The definition of parameters can be found at
[probe definitions](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)
