# Probes Configuration

```
  ############################################################
  # Probes
  #
  # Probes have a number of fields that you can use to more precisely control the
  # behavior of liveness and readiness checks:
  #
  #  initialDelaySeconds: Number of seconds after the container has started before
  #                       liveness or readiness probes are initiated.
  #                           Defaults to 0 seconds.
  #                           Minimum value is 0.
  #
  #        periodSeconds: How often (in seconds) to perform the probe.
  #                           Default to 10 seconds.
  #                           Minimum value is 1.
  #
  #       timeoutSeconds: Number of seconds after which the probe times out.
  #                           Defaults to 1 second.
  #                           Minimum value is 1.
  #
  #     successThreshold: Minimum consecutive successes for the probe to be considered
  #                       successful after having failed.
  #                           Defaults to 1. Must be 1 for liveness.
  #                           Minimum value is 1.
  #
  #     failureThreshold: When a probe fails, Kubernetes will try failureThreshold times
  #                       before giving up. Giving up in case of liveness probe means
  #                       restarting the container. In case of readiness probe the
  #                       Pod will be marked Unready.
  #                           Defaults to 3.
  #                           Minimum value is 1.
  ############################################################
```

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