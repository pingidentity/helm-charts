## Release 0.3.0

* Consolidate deployment/stateful set templates to a single workload template.
* Changes to values.yaml
    * Created a workload map under global (see below)
    * Moved old deployment information under workload
    * Moved old statefulSet information under workload
    * Updated `pingfederate-admin` to reflect new workload
    * Updated `pingdirectory` to reflect new workload
    * Allows for any product to be run as a deployment or statefulSet

    !!! warning
    Using `workload.type=StatefulSet` will create `pvc` resources and allow for
    persistence on restarts of containers.  This is helpful during development.  Be aware
    that the `pvc` resources will need to be deleted to startup a fresh copy of the
    product images.

```yaml
global:
  workload:
    type: Deployment        # Can be Deployment or StatefulSet (see warning above)

    deployment:
      strategy:
        type: RollingUpdate # Can be RollingUpdate or Recreate
        rollingUpdate:
          maxSurge: 1
          maxUnavailable: 0

    statefulSet:
      partition: 0          # Used for canary testing if n>0

      persistentvolume:
        enabled: true
        ############################################################
        # For every volume defined in the volumes list, 3 items will be
        # created in the StatefulSet
        #   1. container.volumeMounts - name and mountPath
        #   2. template.spec.volume - name and persistentVolumeClaim.claimName
        #   3. spec.volumeClaimTemplates - persistentVolumeClaim
        #
        # https://kubernetes.io/docs/concepts/storage/persistent-volumes/
        ############################################################
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

* Renamed template files in pinglib from .yaml to .tpl
* Added `terminationGracePeriodSeconds` to container to support setting in values
* Added `serviceAccountName` to vault.hashicorp to specify to the continer what service
  account can be used to authenticate to the Hashicorp Vault Injector
