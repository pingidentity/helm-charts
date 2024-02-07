# Workload Configuration

Kubernetes Workload resources:

* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

are created depending on configuration values.

## Global Section

Default yaml is defined in the global workload section.
Individual products override these defaults based on the needed workload.

```yaml
global:
  workload:
    type: Deployment

    deployment:
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0

    statefulSet:
      partition: 0

      persistentvolume:
        enabled: true
        volumes:
          out-dir:
            mountPath: /opt/out
            persistentVolumeClaim:
              accessModes:
              - ReadWriteOnce
              storageClassName:
              resources:
                requests:
                  storage: 4Gi

    securityContext:
      fsGroup: 9999
    securityContext: {}
```

| Workload Parameters               | Description                                                                                  |
| --------------------------------- | -------------------------------------------------------------------------------------------- |
| type                              | One of Deployment or StatefulSet                                                             |
| deployment.strategy.type          | One of RollingUpdate or ReCreate                                                             |
| deployment.strategy.rollingUpdate | If type=RollingUpdate                                                                        |
| statefulSet.partition             | Used for canary testing if n>0                                                               |
| statefulSet.persistentVolume      | Provides details around creation of PVC/Volumes (see below)                                  |
| securityContext                   | Provides security context details for starting container as different user/group (see below) |
| securityContext.fsGroup           | Sets the group id on fileSystem writes.  This is needed especially for mounted volumes (pvs) |

!!! note "Persistent Volumes"
    For every volume defined in the volumes list, 3 items will be
    created in the StatefulSet:

    * container.volumeMounts - name and mountPath
    * template.spec.volume - name and persistentVolumeClaim.claimName
    * spec.volumeClaimTemplates - persistentVolumeClaim

    More Info - <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>

!!! note "Security Context"
    To run the containers with a different user/group/fsgroup, use the following
    example to set those details on the deployment/statefulset:

    ```yaml
    global:
      workload:
        container:
          securityContext:
            runAsGroup: 9999
            runAsUser: 9031
            fsGroup: 9999
    ```

!!! note "WaitFor"
    For each product, you can provide a `waitFor` structure indicating the name, service
    and timeout (in seconds) for which the container should wait, (default `300`) before continuing.
    This setting will inject an initContainer using the PingToolkit wait-for utility that
    relies on `nc host:port` before continuing.

    Example: PingFederate Admin waiting on pingdirectory ldaps service to be available
    ```yaml
    pingfederate-admin:
      container:
        waitFor:
          pingdirectory:
            service: ldaps
            timeoutSeconds: 600
          pingauthorize:
            service: https
            timeoutSeconds: 300
    ```

    * By default, the `pingfederate-engine` will waitFor `pingfederate-admin` before it starts.
    * By default, the `pingaccess-engine` will waitFor `pingaccess-admin` before it starts.