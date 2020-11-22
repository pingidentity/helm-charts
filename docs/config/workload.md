# Workload Configuration

Provides values to define kubernetes depoyment information to Deployments or StatefulSets.

More information on Kuernetes deployment resources:

* [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

The example found in the `global:` section is:

```yaml
  workload:
    # Can be Deployment or StatefulSet (see warning above)
    type: Deployment

    deployment:
      strategy:
        # Can be RollingUpdate or Recreate
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0

    statefulSet:
      # Used for canary testing if n>0
      partition: 0

      ############################################################
      # Persistent Volumes
      #
      # For every volume defined in the volumes list, 3 items will be
      # created in the StatefulSet
      #   1. container.volumeMounts - name and mountPath
      #   2. template.spec.volume - name and persistentVolumeClaim.claimName
      #   3. spec.volumeClaimTemplates - persistentVolumeClaim
      #
      # https://kubernetes.io/docs/concepts/storage/persistent-volumes/
      ############################################################
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
```
