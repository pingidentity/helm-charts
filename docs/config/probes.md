# Probes Configuration

Provides values to define kubernetes probe detail to deployments and statefulsets.

More information on Kuernetes probes can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).

The example found in the `global:` section is:

```yaml
global:
  probes:
    liveness:
      command: /opt/liveness.sh
      initialDelaySeconds: 30
      periodSeconds: 30
      timeoutSeconds: 1
      successThreshold: 1
      failureThreshold: 4
    readiness:
      command: /opt/liveness.sh
      initialDelaySeconds: 30
      periodSeconds: 30
      timeoutSeconds: 1
      successThreshold: 1
      failureThreshold: 4
```

Translating to applicable kubernetes manifest sections:

```yaml
        readinessProbe:
          exec:
            command:
            - /opt/liveness.sh
          failureThreshold: 4
          initialDelaySeconds: 30
          periodSeconds: 30
          successThreshold: 1
          timeoutSeconds: 1

        livenessProbe:
          exec:
            command:
            - /opt/liveness.sh
          failureThreshold: 4
          initialDelaySeconds: 30
          periodSeconds: 30
          successThreshold: 1
          timeoutSeconds: 1
```
