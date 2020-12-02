# Release Notes

## Release 0.3.4

* Adding init container to PingFederate Admin to wait-for PingDirectory's LDAPs
  port if the pingdirectory.enabled=true.  This fixes an issue that keeps
  PingFederate Admin from starting when it's dependent on PingDirectory.  In
  the case that PingFederate isn't dependent on PingDirectory and it is still
  enabled, it will simply delay the start time of PingFederate admin.

## Release 0.3.3

* Adding the ability for a deployer to add a securityContext to the containers.
  Currently, there are warning messages in the images when an outside-in pattern is
  used (i.e. securityContext is set). Also, many of the default ports require privileged
  access, so care should be taken along with testing to ensure the containers start up
  fine. Additional, one should not change the security context when doing and upgrade
  or using a PCV from a previous deployment.

An example securityContext that can be used might look like:

```yaml
global:
  container:
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      runAsGroup: 1000
      runAsNonRoot: true
      runAsUser: 100
```

By default, the values.yaml in the chart will set the securityContext to empty:

```yaml
global:
  container:
    securityContext: {}
```

## Release 0.3.2

* Replaced init container on pingfederate-engine to use pingtoolkit rather than 3rd party
  curlimage.  Additionally added resource constraints and security context to this init
  container.
* Remove hardcoded SERVER_PROFILE_BRANCH set to master, relying on git repo default branch
* Cleanup pingdelegator values.  public hostnames for pingfederate and pingdirectory
  built based off of ingress hostnames, part of `{release-name}-global-env-vars` configmap.
* Remove default nginx annotations of ingress resources.  If an nginx controller is used
  for ingress, the following ingress annotations should be included:

    !!! warning
    By removing the following annotations from the default, use of current config values
    will result in no ingress being set.  You must add these in via your .yaml file or via
    separate --set settings.

```yaml
global:
  ingress:
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      kubernetes.io/ingress.class: "nginx-public"
```

## Release 0.3.1

* Add container envFrom for `{release-name}-env-vars` back as optional.
  Fixes breaking change from 0.2.8 to 0.2.9 for those that used this configmap.
* Added ability for deployer to add their own envFrom's via their values.yaml.
  An example (adding an optional configmap/secrets to all products).  Just change
  global to the name of the product to only have that product use the references.

```yaml
global:
  container:
    envFrom:
    - configMapRef:
        name: my-killer-configmap
        optional: true
    - secretRef:
        name: my-killer-secrets
        optional: true
```

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
* Added `serviceAccountName` to vault.hashicorp to specify to the container what service
  account can be used to authenticate to the Hashicorp Vault Injector
