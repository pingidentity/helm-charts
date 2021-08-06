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
        cpu: 0
        memory: 0
      limits:
        cpu: 0
        memory: 0
    nodeSelector: {}
    tolerations: []
    affinity: {}
    terminationGracePeriodSeconds: 30
    envFrom: []
    lifecyle: {}
    probes:
      livenessProbe:
        exec:
          command:
            - /opt/liveness.sh
        initialDelaySeconds: 30
        periodSeconds: 30
        timeoutSeconds: 5
        successThreshold: 1
        failureThreshold: 4
      readinessProbe:
        exec:
          command:
            - /opt/readiness.sh
        initialDelaySeconds: 30
        periodSeconds: 5
        timeoutSeconds: 5
        successThreshold: 1
        failureThreshold: 4
      startupProbe:
        exec:
          command:
            - /opt/liveness.sh
        periodSeconds: 10
        timeoutSeconds: 5
        failureThreshold: 90

```

## Probes Configuration

[Kubernetes Probes resources](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
to be added to workloads (i.e. Deployments/StatefulSets).

The definition of parameters can be found at
[probe definitions](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)