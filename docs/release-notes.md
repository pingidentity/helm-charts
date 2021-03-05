# Release Notes


## Release 0.4.7


* [Issue #95](https://github.com/pingidentity/helm-charts/issues/97) - Unable to set numerous Vault configuration options

    Updated ability to add any hashicorp.vault annotation to the workload.  As part of this effort, the ***existing
    name/values have been deprecated***, however will continue to work for a period of time.

    Updated details can be found in the [Vault Config](config/vault.md) docs.


* [Issue #97](https://github.com/pingidentity/helm-charts/issues/97) - Add the ability to add annotations to all resources generated
  similar to current support for Labels.  This will allow deployers to specify additional annotations at either the global and/or product level.
  An example of the values yaml would look like:

    ```
    global:
      annotations:
        app.ping-devops.com/test: test-name

    pingaccess-admin:
      annotations:
        app.pingaccess/version: v1234
    ```

* Additional cleanup of Notes.txt outputting detail of deployment.

## Release 0.4.6

* Minor follow on update to cpu/memory request/limit sizes for init containers.


## Release 0.4.5

* [Issue #89](https://github.com/pingidentity/helm-charts/issues/89) - Update default workload resource cpu/memory request sizes.

    Updating defaults to create a usage better reflecting actual memory usage by product. And minimizing amount of CPU needed
    as testing generally utilizes very little.  Of course, it is definitely recommended that production deployments specify amount of
    cpu and memory required and limited to.

    Current defaults are set to:

    ```
    #-------------------------------------------------------------------------------------
    # Ping DevOps
    #
    # Description: All Ping Identity product images with integration
    #-------------------------------------------------------------------------------------
    #
    #           Product         Workload   cpu-R cpu-L mem-R mem-L  Ing
    #    --------------------- ----------- ----- ----- ----- ----- -----
    #  √ pingaccess-admin      deployment  0     2     1Gi   4Gi   false
    #  √ pingaccess-engine     deployment  0     2     1Gi   4Gi   false
    #  √ pingdataconsole       deployment  0     2     .5Gi  2Gi   false
    #  √ pingdatagovernance    deployment  0     2     1.5Gi 4Gi   false
    #  √ pingdatagovernancepap deployment  0     2     .75Gi 2Gi   false
    #  √ pingdatasync          deployment  0     2     .75Gi 2Gi   false
    #  √ pingdelegator         deployment  0     500m  32Mi  64Mi  false
    #  √ pingdirectory         statefulset 0     2     2Gi   8Gi   false
    #  √ pingfederate-admin    deployment  0     2     1Gi   4Gi   false
    #  √ pingfederate-engine   deployment  0     2     1Gi   4Gi   false
    #
    #  √ ldap-sdk-tools        deployment  0     0     0     0     false
    #  √ pd-replication-timing deployment  0     0     0     0     false
    #
    #-------------------------------------------------------------------------------------
    ```
## Release 0.4.4

* [Issue #80](https://github.com/pingidentity/helm-charts/issues/80) - Add support for importing a secret containing license into the container.
  Adds ability to add secret and configMap data to a container via a VolumeMount.  A good use of this practice - bringing product
  licenses into the container.

    !!! note "Example of creating 3 volume mounts in container from secret and configMap"
        ```yaml
        pingfederate-admin
          secretVolumes:
            pingfederate-license:
              items:
                license: /opt/in/instance/server/default/conf/pingfederate.lic
                hello: /opt/in/instance/server/default/hello.txt

          configMapVolumes:
            pingfederate-props:
                items:
                  pf-props: /opt/in/etc/pingfederate.properties
        ```
  In this case, a secret (called pingfederate-license) and configMap (called pingfederate-props) will bring in a
  couple of key values (license, hello) and (pf-props) into the container as specific files. The results will looks like:

    !!! note "Example of kubectl describe of pingfederate-admin container"
        ```
        Containers:
          pingfederate-admin:
            Mounts:
              /opt/in/etc/pingfederate.properties from pingfederate-props (ro,path="pingfederate.properties")
              /opt/in/instance/server/default/conf/pingfederate.lic from pingfederate-license (ro,path="pingfederate.lic")
              /opt/in/instance/server/default/hello.txt from pingfederate-license (ro,path="hello.txt")
        Volumes:
          pingfederate-license:
            Type:        Secret (a volume populated by a Secret)
            SecretName:  pingfederate-license
            Optional:    false
          pingfederate-props:
            Type:      ConfigMap (a volume populated by a ConfigMap)
            Name:      pingfederate-props
            Optional:  false
        ```
## Release 0.4.3

* [Issue #83](https://github.com/pingidentity/helm-charts/issues/83) - Remove old pingdirectory tag check when creating service-cluster.
  This caused issues when creating a pingdirectory deployment with most recent tags (tags other than edge or 2012).

## Release 0.4.2

* [Issue #79](https://github.com/pingidentity/helm-charts/issues/79) - Adding support for product PingDataGovernance PAP
* [Issue #78](https://github.com/pingidentity/helm-charts/issues/78) - Adding support to provide affinity definition to the workload of a product.

    !!! note "Example values.yaml to add podAntiAffinity to pingdirectory"
        ```yaml
        pingdirectory:
          container:
            affinity:
              podAntiAffinity:
                # Add a hard requirement for each PD pod to be deployed to a different node
                requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchExpressions:
                    - key: app.kubernetes.io/name
                      operator: In
                      values:
                      - pingdirectory
                  topologyKey: "kubernetes.io/hostname"
                # Add a soft requirement for each PD pod to be deployed to a different AZ
                preferredDuringSchedulingIgnoredDuringExecution:
                - weight: 1
                  podAffinityTerm:
                    labelSelector:
                      matchExpressions:
                      - key: app.kubernetes.io/name
                        operator: In
                        values:
                        - pingdirectory
                    topologyKey: "failure-domain.beta.kubernetes.io/zone"
        ```

## Release 0.4.1

* Change default image tag to `2101` (January 2021).
* Create private certs and keystore for use by images, only if the value
  `{product-name}.privateCert.generate=true`.  Defaults are false.
    * Helm will generate the a `tls.crt` and `tls.key`, place it into a kubernetes
      secret called `{release-productname}-private-cert`.
    * Mount the secret into the image under `/run/secrets/private-cert`
    * An init container will pull the `tls.crt` and `tls.key` into a pkcs12
      keystore and place it into a file `/run/secrets/private-keystore/keystore.env`
      that will be mounted into the running container.
    * When the container's hooks are running, it will source the environment variables
      in this `keystore.env`.  The default variables set are:
          * `PRIVATE_KEYSTORE_PIN={base64 random pin}`
          * `PRIVATE_KEYSTORE_TYPE=pkcs12`
          * `PRIVATE_KEYSTORE={pkcs12 keystore}`

    !!! note "yaml to generate a private cert/keystore for pingaccess-admin"
        ```yaml
        pingaccess-admin:
          privateCert:
            generate: true
        ```

    !!! note "Example of created /run/secrets/private-keystore/keystore.env"
        ```properties
        PRIVATE_KEYSTORE_PIN=nrZmV4XdfK....
        PRIVATE_KEYSTORE_TYPE=pkcs12
        PRIVATE_KEYSTORE=MIIJgQIBAzCCCUcGC....
        ```

* Added support for PingAccess clustering between pingaccess-admin and multiple
  pingaccess-engine containers.
      * See [everything.yaml](examples/everything.yaml) for example of deploying
        a PingAccess cluster using PingFederate/PingDirectory to authenticate
      * It is *required* to either:
          * generate the private cert (see above)
            with the value of `pingaccess-admin.privateCert.generate=true` or
          * provide your own cert secret called `{release-productname}-private-cert`
            containing a valid `tls.crt` and `tls.key`.
      * Enable both the `pingaccess-admin` and `pingaccess-engine` helm chart products


    !!! note "Example values to create a clustered pingaccess"
        ```yaml
        pingaccess-admin:
          enabled: true
          privateCert:
            generate: true
          envs:
            SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
            SERVER_PROFILE_PATH: baseline/pingaccess

        pingaccess-engine:
          enabled: true
          envs:
            SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
            SERVER_PROFILE_PATH: baseline/pingaccess

        pingfederate-admin:
          enabled: true
          envs:
            SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
            SERVER_PROFILE_PATH: baseline/pingfederate
          container:
            waitFor:
              pingdirectory:
                service: ldaps

        pingfederate-engine:
          enabled: true
          envs:
            SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
            SERVER_PROFILE_PATH: baseline/pingfederate

        pingdirectory:
          enabled: true
          envs:
            SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
            SERVER_PROFILE_PATH: baseline/pingdirectory
        ```

## Release 0.4.0

* Support availability of PingDirectory pods through the cluster headless kubernetes service.
  Allows for PingDirectory nodes to find one another during the replication enable/init process.

    !!! note "Adds following to pingdirectory-cluster"
        ```yaml
        metadata:
          annotations:
            service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
        spec:
          publishNotReadyAddresses: true
        ```

## Release 0.3.9

* Fixed the default wait-for service name on pingfederate-engine (admin --> https).
* Changed default on readiness command to check for readiness every 5 seconds rather than 30.
  This allows for availability on some services, such as PingFederate which is normally ready in 30 sec.

## Release 0.3.8

* [Issue #56](https://github.com/pingidentity/helm-charts/issues/56) - Improved Default Naming on Global vars - PORTs

* [Issue #56](https://github.com/pingidentity/helm-charts/issues/56) - Improved Default Naming on Global vars - PORTs

    In release 0.3.6, global-env-vars were created for PORTS.  The naming structure used was
    complex and difficult, primarily because a product can have several ports open on a particular
    private and public host.  The format will be more consistent as defined by the following:

    `{product-short-code with type}_{public or private}_{hostname or port}{_service if port}`

    An example with PD might look like (note the service names of `https` and `data-api`):

    ```yaml
    PD_ENGINE_PUBLIC_PORT_HTTPS: 443
    PD_ENGINE_PUBLIC_PORT_DATA_API: 1443

    PD_ENGINE_PRIVATE_PORT_HTTPS: 443
    PD_ENGINE_PRIVATE_PORT_DATA_API: 8443
    ```

* [Issue #62](https://github.com/pingidentity/helm-charts/issues/62) -
  When creating configMapRef's, take into account the proper release name to include

    ConfigMapRef names in workloads were not consistent with the ConfigMaps created by default
    when taking into account the `addReleaseNameToResource` setting of prepend, append or none.
    This fixes that issue ensuring that config maps are consistent.

* Added global-env private/public host/port for PingDataConsole, which was missing.
* Changed the default pingfederate-admin `admin` service name to `https` to reduce confusion.
* Changed the default pingfederate-engine `engine` service name to `https` to reduce confusion.


## Release 0.3.7

* Fixes issue with service -vs- ingress name on creation of ingress to service mapping.  Resolves issue #57.

## Release 0.3.6

* Cleaning up and making services/ingresses easier to use together.  Incorporating all the ports
  used in both a service and ingress into the same location of the [services structure](config/service.md).

    The example below shows a container/service/ingress and how to specify the ports at each
    level.

    * `containerPort` - Replaces `targetPort`
    * `servicePort` - Replaces `port`
    * `ingressPort` - New entry

    ```yaml
      services:
        api:
          containerPort: 8443 <--- changed from targetPort
          servicePort: 1443   <--- changed from port
          ingressPort: 443    <--- new.  moved from ingress
          dataService: true
        data-api:
          containerPort: 9443 <--- changed from targetPort
          servicePort: 2443   <--- changed from port
          ingressPort: 2443   <--- new.  moved from ingress
          dataService: true
      ingress:
        hosts:
          - host: pingdirectory.example.com
            paths:
            - path: /api
              backend:
                serviceName: api        <--- changed from servicePort
            - path: /directory/v1
              backend:
                serviceName: data-api   <--- changed from servicePort
    ```

    Additionally, `global-env-vars` will be created for each of these ports.  If the name
    of the product is `PROD`, the the following ports would be created:

    ```properties
      PROD_API_PRIVATE_PORT="1443"          # This is the servicePort
      PROD_API_PUBLIC_PORT="443"            # This is the ingressPort
      PROD_DATA_API_PRIVATE_PORT="2443"
      PROD_DATA_API_PUBLIC_PORT="2443"
    ```

* Fixed missing `USER_BASE_DN` setting in simple-sync.yaml example.

## Release 0.3.5

* Allowing config values to determine use of init containers to wait-for other chart products.
  For each product, you can now provide a `waitFor` structure providing the name
  and service that should be waited on before the running container con continue.  This
  will basically inject an initContainer using the PingToolkit wait-for utility until it
  can `nc host:port` before continuing.

    !!! example "PingFederate Admin waiting on pingdirectory ldaps service to be available"
        ```yaml
        pingfederate-admin:
          container:
            waitFor:
              pingdirectory:
                service: ldaps
              pingdatagovernance:
                service: https
        ```

* By default, the `pingfederate-engine` will waitFor `pingfederate-admin` before it
  starts.

## Release 0.3.4

* Adding init container to PingFederate Admin to wait-for PingDirectory's LDAPs
  port if the pingdirectory.enabled=true.  This fixes an issue that keeps
  PingFederate Admin from starting when it's dependent on PingDirectory.  In
  the case that PingFederate isn't dependent on PingDirectory and it is still
  enabled, it will simply delay the start time of PingFederate admin.  A future
  version will allow for specifying a list of services to wait-for so this can
  be turned off/on by deployer.
* Moved the securityContext settings added to release 0.3.3 from the container
  to the workload, as that is the proper place to use them.  Required for use of
  `fsGroup` setting.

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
