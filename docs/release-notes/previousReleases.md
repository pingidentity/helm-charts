# Release Notes
## Release 0.9.20 (November 2, 2023)
### Features ###
  - Updated default global image tag to `2310`.
  - Added environment variables for PingDirectoryProxy to support enabling automatic server discovery.

### Defects ###
  - Updated the CronJob template to handle the switch from `batch/v1beta1` to `batch/v1` in Kubernetes `1.25`.

## Release 0.9.19 (September 6, 2023)
### Features ###
  - Updated default global image tag to `2308`.

## Release 0.9.18 (August 28, 2023)
### Resolved Defects ###
  - Fixed incorrect yaml formatting when setting `testFramework.rbac.serviceAccountImagePullSecrets`.

## Release 0.9.17 (August 25, 2023)
### Features ###
  - Added support for setting `imagePullSecrets` in workloads.
  - Added support for setting `testFramework.rbac.serviceAccountImagePullSecrets` to add secrets to the testFramework service account.

## Release 0.9.16 (August 2, 2023)
### Features ###
  - Updated default global image tag to `2307`.

## Release 0.9.15 (July 13, 2023)
### Features ###
  - Updated default global image tag to `2306`.

### Enhancements ###
  - Updated template to allow setting a custom workload type when using a HorizontalPodAutoscaler.

## Release 0.9.14 (June 02, 2023)
### Features ###
  - Updated default global image tag to `2305`.

## Release 0.9.13 (May 04, 2023)
### Features ###
  - Updated default global image tag to `2304`.

## Release 0.9.12 (April 03, 2023)
### Features ###
  - Updated default global image tag to `2303`.
  - Updated the workload `topologySpreadConstraints` field to automatically set `matchLabels` to match the workload labels.

## Release 0.9.11 (March 03, 2023)
### Features ###
  - Updated default global image tag to `2302`.
  - Added default environment variables to `pingdirectoryproxy` to support joining a PingDirectory topology.

## Release 0.9.10 (February 03, 2023)
### Features ###
  - Updated default global image tag to `2301`.
  - Updated the securityContext defaults for Pods and containers in the ping-devops Helm chart to satisfy the "restricted" Pod Security Standard in Kubernetes
  - Added support for running a separate LoadBalancer service for each PingDirectory pod. This may be useful when running across multiple regions when using VPC peering isn't possible.

### Resolved Defects
  - Updated the HorizontalPodAutoscaler API to use the correct value for Kubernetes versions greater than 1.23.

## Release 0.9.9 (January 03, 2023)
### Features ###
  - Updated default global image tag to `2212`.
  - Removed `pingdatagovernance` and `pingdatagovernancepap` from the chart. Use `pingauthorize` and `pingauthorizepap` instead.

## Release 0.9.8 (December 05, 2022)
### Features ###
  - Updated default global image tag to `2211`.
  - Custom annotations can now be specified for Services.

### Defects ###
  - Fixed HorizontalPodAutoscaler autoscalingMetricsTemplate being inserted in the wrong location in the generated yaml.
  - Fixed the documentation in values.yaml referring to `pingdirectory.cronjob.jobspec` rather than the correct value `pingdirectory.cronjob.jobTemplate`

## Release 0.9.7 (November 02, 2022)
### Features ###
  - Updated default global image tag to `2210`.

## Release 0.9.6 (October 04, 2022)
### Features ###
  - Updated default global image tag to `2209`.
  - Added support for deploying a HorizontalPodAutoscaler for pingaccess-engine, pingfederate-admin, pingdelegator, pingauthorize, pingauthorizepap, pingcentral, and pingdataconsole. Previously, deploying a HorizontalPodAutoscaler was only supported for pingfederate-engine.
  - Added support for setting the podManagementPolicy for StatefulSet workloads. The default policy is OrderedReady. The Parallel policy allows for starting up multiple Pods of the StatefulSet simultaneously, improving initial deployment times. Parallel startup is only supported with PingDirectory and PingDataSync, and only with images version `2209` and newer.

## Release 0.9.5 (September 01, 2022)
### Features ###
  - Updated default global image tag to `2208`.
  - Added support for setting container-level securityContext values for the main container of each workload. By default no container-level securityContext will be set. A container-level securityContext isn't necessary if the values from the Pod-level securityContext are sufficient.
  - Added support for setting the topologySpreadConstraints field on workloads.
  - Added support for setting the enableServiceLinks field on workloads.

### Documentation ###
  - Added an [example](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/vault-keystores.yaml) for mounting keystore secrets with Vault
  - Added an [example](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/csi-secrets-volume.yaml) for mounting secrets with CSI volumes (which can be used for various storage systems including AWS secrets manager)
  - Fixed Helm [RBAC example](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/rbac.yaml) using an invalid serviceAccountName for pingauthorize
  - Added a [doc page](https://helm.pingidentity.com/howto/updatetags/) describing how to update product versions
  - Added example docs for deploying [PingDirectory](https://devops.pingidentity.com/deployment/deployPDMultiRegion/) and [PingFederate](https://devops.pingidentity.com/deployment/deployPFMultiRegion/) in a multi-region environment with Helm

### Resolved Defects ###
  - Removed support for apache-jmeter, since it is better suited to run as a Job than as a long-running workload.

## Release 0.9.4 (August 05, 2022)
### Features ###
  - Updated default global image tag to `2207`.
  - Added support for apache-jmeter

### Resolved Defects ###
  - Fixed an issue making it impossible to use an existing service account (an account not managed by the Helm chart) for a workload. An existing service account can now be used by specifying the `{product}.rbac.serviceAccountName` field while leaving `{product}.rbac.generateServiceAccount` set to the default `false` value. See the PingAuthorize section of the updated [RBAC example](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/30-helm/rbac.yaml)


## Release 0.9.3 (July 01, 2022)
### Features ###
  - Updated default global image tag to `2206`.
  - Added support for PingIntelligence.
  - Updated the Helm chart to support generating ServiceAccounts, Roles, and RoleBindings for a workload. These can be generated globally (one common to each workload) or individually for each workload. By default none will be generated.

    These can be controlled with the global.rbac (or {product}.rbac) section. To generate a common ServiceAccount usable by all workloads, use global.rbac.generateGlobalServiceAccount. Use rbac.generateServiceAccount to generate separate ServiceAccounts for individual workloads. Similarly, use global.rbac.generateGlobalRoleAndRoleBinding and rbac.generateRoleAndRoleBinding for creating a Role and RoleBinding.

    Set rbac.applyServiceAccountToWorkload to true to set the account on the Deployment or StatefulSet. The name of the ServiceAccount will be autogenerated unless the rbac.serviceAccountName field is set. The specific Role yaml can be provided in rbac.role.

    The Vault default has changed. The Vault serviceAccount will now default to the autogenerated account for the workload, instead of the previous default of "vault-auth". This can be overriden by setting the vault.hashicorp.annotations.serviceAccountName value.

    See the table with sample Helm chart value files found on the [Ping Identity Devops Portal](https://devops.pingidentity.com/deployment/deployHelm/) for an example.

  - Added a default empty global.labels section.

## Release 0.9.2 (June 02, 2022)
### Features ###
  - Updated default global image tag to `2205`.
  - Added support for providing a null securityContext for a workload, which is useful for OpenShift security context constraints.
  - Added support for enabling Ingress for pingdirectoryproxy and pingdatasync.
  - Updated pingdirectoryproxy to be a StatefulSet by default in the Helm charts, with the persistent volume disabled. This supports having consistent proxy pod names.
  - Added a new `privateCert.format` field, which can be set to `"pingaccess-fips-pem"` to generate a cert that can be used by PingAccess when running in FIPS mode. The cert is generated by a temporary PingAccess initContainer, as PingAccess requires a specific format for certs when in FIPS mode that must be generated from PingAccess itself. Leaving the field blank or setting it to any other value will generate a cert in the same manner as before - adding the key pair to a PKCS12 keystore file. 
  - Updated the externalImage values section to expect the same format for `image:` as the individual products (repository, image name, tag, etc. are provided separately). If no image values are specified for an externalImage, the corresponding defaults from the main product section will be used. For example, if `global.externalImage.pingtoolkit.image` is empty, then the values from the top-level `pingtoolkit.image` section will be used.

## Release 0.9.1 (May 05, 2022)
### Features ###
  - Updated default global image tag to `2204`
  - Updated the PingDataSync env vars ConfigMap to include variables needed to enable failover between servers. Failover will be enabled when deploying two or more PingDataSync replicas
  - Reduced utilitySidecar resource requests
### Resolved Defects ###
  - Updated the image.repositoryFqn field to be consistent with the other fields under image.
    Previously, repositoryFqn was expected at the same level as the image: section, now it is expected within the image: section like other fields (tag, pullPolicy, etc.).
    The image tag must now be provided separately from the repositoryFqn. The repositoryFqn should only be the name of the repository, not the tag of the specific image.
  - Fixed a version check in the Helm chart for choosing the correct k8s API for Ingress. The version check was previously failing on EKS clusters due to the format EKS uses for the cluster version.

## Release 0.9.0 (April 01, 2022)
### Features ###
  - Default global image tag updated to 2203
  - Customizability on Cronjob and Utility Sidecar
    -   Override jobTemplate in CronJob now available.
    -   Override image used in utilitySidecar now available.
  - Updated the default PingDataSync workload in the Ping devops Helm charts to use a StatefulSet rather than a Deployment. This ensures that the sync-state.ldif file is maintained between pod restarts.

## Release 0.8.9 (Mar 17, 2022)
### Features ###
  - Edit from 0.8.8 release. Previously the image fully qualified name also included the image tag, which was then duplicated upon deployment when "tag" value present.

## Release 0.8.8 (Mar 16, 2022)
### Features ###
  - Added support for fully qualified image location. For more information go to the image section in our [values.yaml](https://github.com/pingidentity/helm-charts/blob/18a8972cb10dcef0747c2a6b0dcf8350dded52f2/charts/ping-devops/values.yaml#L155)
  ```
    image:
      repository: pingidentity
      repositoryFqn:
      name:
      tag: "2202"
      pullPolicy: IfNotPresent
  ```

## Release 0.8.7 (Mar 11, 2022)
### Features ###
  - Corrected Default global image tag updated to 2202

## Release 0.8.6 (Mar 3, 2022)
### Features ###
  - Default global image tag updated to 2202

## Release 0.8.5 (Feb 7, 2022)
### Features ###
  - PingCentral now supported. Example values application found [here](../examples/pingcentral/pingcentral.yaml)
### Issues Resolved ###
  - [Issue #119](https://github.com/pingidentity/helm-charts/issues/119) Workload template not honoring false values from values.yaml. Previously, false did not overwrite true in the Ping Identity Helm Chart template. This fix in _merge-util.tpl will resolve multiple cases within the Ping Identity Helm Chart.
    ```
    {{- $globalValues := deepCopy $top.Values.global -}}
    {{- $prodValues := deepCopy (index $top.Values $prodName) -}}
    {{- $mergedValues := mergeOverwrite $globalValues $prodValues -}}
    ```
  - [Issue #264](https://github.com/pingidentity/helm-charts/issues/264) Update default global.image.tag to 2201

## Release 0.8.4 (Jan 7, 2022)

* Fix an issue that caused installation to fail when enabling `pingtoolkit`

## Release 0.8.3 (Jan 6, 2022)

### Features ###
- Document [supported values](https://helm.pingidentity.com/config/supported-values)
### Issues Resolved ###
* [Issue #233](https://github.com/pingidentity/helm-charts/issues/235) Ingress - semverCompare now retrieves correct K8 version for applying the correct apiVersion
  ```
  {{- if semverCompare ">=1.19.x" $top.Capabilities.KubeVersion.Version }}
  ```

* [Issue #254](https://github.com/pingidentity/helm-charts/issues/254) Update default global.image.tag to 2112
## Release 0.8.2 (Dec 17, 2021)

* [Issue #238](https://github.com/pingidentity/helm-charts/issues/238) Added support for running a utility sidecar alongside a product workload

  The `utilitySidecar` field under a given product can be used to run a sidecar container that will permanently alongside the product container. This sidecar can be used for utility command-line processes, such as running the collect-support-data tool or running a backup.

  An example can be found in the docs/examples/pingdirectory-backup directory for running a PingDirectory backup every 6 hours via a CronJob.

  ```
  pingdirectory:
    workload:
      shareProcessNamespace: true
    utilitySidecar:
      enabled: true
  ```

* [Issue #247](https://github.com/pingidentity/helm-charts/issues/247) Update default global.image.tag to 2111.1

## Release 0.8.1 (Dec 6, 2021)

* [Issue #240](https://github.com/pingidentity/helm-charts/issues/240) Fix failure on installation of 0.8.0 due to missing PingDirectory HTTP port value

## Release 0.8.0 (Dec 6, 2021)

* [Issue #229](https://github.com/pingidentity/helm-charts/issues/229) Support for [shareProcessNamespace in pod spec](https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/)

  A PingDirectory utility sidecar container needs to share the process namespace with the main PingDirectory container running in the same pod in order to get useful output out of tools like jps.
  ### More support to come on the utility sidecar in future Helm release.

* [Issue #232](https://github.com/pingidentity/helm-charts/issues/232) Update default global.image.tag to 2111

* [Issue #239](https://github.com/pingidentity/helm-charts/issues/239) Support for custom container arguments

  ```
  pingfederate-admin:
    enabled: true
    container:
      args: ["start-server","tail -f /dev/null"]
  ```

* [Issue #240](https://github.com/pingidentity/helm-charts/issues/240) Allow specifying PingDirectory HTTPS port in values

  ```
  pingdirectory:
    enabled: true
    services:
      https:
        containerPort: 8443
  ```

## Release 0.7.9 (Dec 1, 2021)

* [Issue #223](https://github.com/pingidentity/helm-charts/issues/223) Support for HPA Scaling Behavior

  ```
  clustering:
    autoscaling:
      enabled: true
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
          - type: Percent
            value: 100
            periodSeconds: 15
        scaleUp:
          stabilizationWindowSeconds: 0
          policies:
          - type: Percent
            value: 100
            periodSeconds: 15
          - type: Pods
            value: 4
            periodSeconds: 15
          selectPolicy: Max
  ```

* [Issue #231](https://github.com/pingidentity/helm-charts/issues/231) Helm test image pull policy no longer hard-coded in `helm-charts/charts/ping-devops/templates/pinglib/_tests/tpl`
  ```diff
  - imagePullPolicy: IfNotPresent
  ```

* [Issue #233](https://github.com/pingidentity/helm-charts/issues/233) Cluster service for pingaccess-admin in Multi-region
  Support for multi-region PingAccess deployment without using an ingress. The headless service is an effective way to share the pod id across clusters.
  ```
  pingaccess-admin:
  enabled: true
  privateCert:
    generate: true
  envs:
    SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
    SERVER_PROFILE_PATH: baseline/pingaccess
  container:
    replicaCount: 1
    waitFor:
      pingfederate-engine:
        service: https
  services:
    https:
      servicePort: 9000
      containerPort: 9000
      ingressPort: 443
      dataService: true
      clusterService: true
    clusterconfig:
      servicePort: 9090
      containerPort: 9090
      ingressPort: 443
      dataService: true
    clusterExternalDNSHostname: pingaccess-admin.usa.ping-multi-cluster.com
  ```

## Release 0.7.8 (Nov 2, 2021)

* [Issue #213](https://github.com/pingidentity/helm-charts/issues/213) Removed default SERVER_PROFILE variables from values.yaml

  ```diff
  envs:
  - SERVER_PROFILE_URL:
  - SERVER_PROFILE_PATH:
  ```

* [Issue #216](https://github.com/pingidentity/helm-charts/issues/216) Add option to generate a master password for ping services

    In the interest of better security practice, this enhancement provides the ability to generate this password via the `derivedPassword` function in helm.  With this, several items can be used by default and overridden by the deployer to generate a secure password.  When it generates the password:

    - A note will be added to the NOTES (see below)
    - The password will be set into the global configmap PING_IDENTITY_PASSWORD. (we may want to use a secret instead)

    NOTES (see the generated password as well as the WARNING)
    ```
    $ helm upgrade --install test-pw pingidentity/ping-devops  --set global.masterPassword.enabled=true
    NOTES:
    #-------------------------------------------------------------------------------------
    # Ping DevOps
    #
    # Description: Ping Identity helm charts - 09/18/21
    #-------------------------------------------------------------------------------------
    # WARNING: Master Password has been requested and generated.  This is intended to
    #          generate a password for DEVELOPMENT PURPOSES ONLY.  This password will be
    #          assigned to the PING_IDENTITY_PASSWORD unless overridden by the values.
    #
    #          PING_IDENTITY_PASSWORD: **************
    #-------------------------------------------------------------------------------------
    ```

    The values used to drive the creation of this password are:

    values.yaml
    ```
    global:
      ############################################################
      # Master Password Generation
      #
      # Uses Helm function derivePassword, which uses the master password
      # specification: https://masterpassword.app/masterpassword-algorithm.pdf
      #
      #      masterPassword.enabled: {true | false}
      #      masterPassword.strength: {master password template: long | maximum}
      #      masterPassword.name: {defaults to .Release.Name}
      #      masterPassword.site: {defaults to .Chart.Name}
      #      masterPassword.secret: {defaults to .Release.Namespace}
      ############################################################
      masterPassword:
        enabled: false
        strength: long
        name:   # default - .Release.Name
        site:   # default - .Chart.Name
        secret: # default - .Release.Namespace
    ```

    As shown in the example above, a deployer only needs to provide the `global.masterPassword.enabled=true` to have it generated.

* [Issue #221](https://github.com/pingidentity/helm-charts/issues/221) PingDirectory service.x.containerPort updates to LDAPS_PORT environment variable
* [Issue #222](https://github.com/pingidentity/helm-charts/issues/222) Update default global.image.tag to 2110
* [Issue #224](https://github.com/pingidentity/helm-charts/issues/224) External Hostname Annotations on PD data service

## Release 0.7.7 (Oct 7, 2021)

* [Issue #217](https://github.com/pingidentity/helm-charts/issues/217) Update default security context group id to root (0)

    ```
    global:
      workload:
        securityContext:
          fsGroup: 0
          runAsUser: 9031
          runAsGroup: 0
    ```

* [Issue #218](https://github.com/pingidentity/helm-charts/issues/218) Update default global.image.tag to 2109

## Release 0.7.6 (Sept 18, 2021)

* [Issue #209](https://github.com/pingidentity/helm-charts/issues/209) Fix incorrect default ldap-sdk-tools probe exec commands
* [Issue #210](https://github.com/pingidentity/helm-charts/issues/210) Add helm-chart product/image pingtoolkit
* [Issue #211](https://github.com/pingidentity/helm-charts/issues/211) Allow for schedulerName to be provide on workloads (pods)

## Release 0.7.5 (August 30, 2021)

* [Issue #206](https://github.com/pingidentity/helm-charts/issues/206) Bump default image tag to 2108

## Release 0.7.4 (August 26, 2021)

* [Issue #196](https://github.com/pingidentity/helm-charts/issues/196) Set initContainer settings from values.yaml instead of hard coded templates

    This issue was created since the initContainer resources were hard coded in the
    template, not allowing the implementor to provide their own values, causing issues
    when trying to deploy the pingfederate-engine in openshift.

    Moving a lot of the hard coded yaml out of the template files into the default values.yaml file.  This will give the implementor full control of how the initContainer runs.

    One breaking change with the values.yaml if anyone has overridden, is that the `{image name}` in the `global.externalImage.{name}: {image name}` value is moved into a map.  The default pingtoolkit externalImage looks like:

    ```
    global:
      externalImage:
        pingtoolkit:
          image: pingidentity/pingtoolkit:2107
          imagePullPolicy: IfNotPresent
          resources:
            limits:
              cpu: 1m
              memory: 128Mi
            requests:
              cpu: 500m
              memory: 64Mi
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 9031
            runAsGroup: 9999
    ```

* [Issue #203](https://github.com/pingidentity/helm-charts/issues/203) testFramework - Support multiple waitFor products in testSteps

    When there are 2 waitFor's together, allow for combining them to
    run them within same initContainer, with a definition like:

    ```
      testSteps:
        - name: 01-wait-for
          waitFor:
            pingfederate-admin:
              service: https
            pingfederate-engine:
              service: https
    ```

    creating a couple of initContainers of:

    ```
      initContainers:
        - name: 01-wait-for-pingfederate-admin
          ...
        - name: 01-wait-for-pingfederate-engine
          ...
    ```

## Release 0.7.3 (August 24, 2021)

* [Issue #194](https://github.com/pingidentity/helm-charts/issues/194) Change default envs for pingauthorize/pingauthorizepap

    The current envs for pingauthroize in the values.yaml file are:

    ```
      envs:
        SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
        SERVER_PROFILE_PATH: paz-pap-integration/pingauthorize
        SERVER_PROFILE_PARENT: PAZ
        SERVER_PROFILE_PAZ_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
        SERVER_PROFILE_PAZ_PATH: baseline/pingauthorize
    ```

    Just a side note here, the `baseline/pingauthorize` PATH includes a connection to pingdirectory, which will cause this to fail (pingauthorize https will return a 503).

    If someone wants to override these, they need to be sure to uset/override the `SERVER_PROFILE_PARENT` variable, so the parent profiles aren't brought in.

    The better default values.yaml should probably be:

    ```
      envs:
        SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
        SERVER_PROFILE_PATH: getting-started/pingauthorize
    ```

    For pingauthorizepap, it should have a default SERVER_PROFILE variables as empty, as no SERVER_PROFILE is needed by default.

* [Issue #198](https://github.com/pingidentity/helm-charts/issues/198) testFramework: Support full definition of initContainers attributes in testSteps and finalStep

    Update the testFramework to pull in all attributes of the testSteps and finalStep into the init containers and final container.  This allow for setting any resource, imagePullPolicy, ...

    This came about as there was no way to set resource or imagePullPolicy details.

    With this change, will be adding a couple of defaults into the value.yamls file for the finalStep:

    ```
      finalStep:
        name: 99-completion
        image: busybox
        imagePullPolicy: IfNotPresent
        command:
          ...
        resources:
          limits:
            cpu: 500m
            memory: 128Mi
          requests:
            cpu: 1m
            memory: 64Mi
    ```

## Release 0.7.2 (August 13, 2021)

* [Issue #191](https://github.com/pingidentity/helm-charts/issues/191) Change variable PF_ADMIN_BASEURL to PF_ADMIN_PUBLIC_BASEURL

    Release 0.7.2 created the new variable `PF_ADMIN_BASEURL`.  Due to the current user of the same variable with added `_PUBLIC_`,  the actual variable name needs to be `PF_ADMIN_PUBLIC_BASEURL`.

## Release 0.7.1 (August 13, 2021)

* [Issue #187](https://github.com/pingidentity/helm-charts/issues/187) Create the PUBLIC hostname/ports in the global env vars configmap all the time

    Currently, the PUBLIC hostname/ports in the global env vars configmap are created if and only if the ingress in enabled.

    Normally, this would be fine, except that some of the products (i.e PingFederate) use the PUBLIC environment variable to setup items like BASE URLs and redirects for the browser.  This is required for use cases when there is no ingress, but the user creates a port forward, as well as testing with no ingresses.

    So, if no ingress is created, then the PUBLIC_HOSTNAMES should be set to `localhost` and the PUBLIC_PORT_* should be set to the same port as the contianerPort.

    If ingress is used, then the functionality will not be changed, and the public hostname will be constructed as well as the public ingressPort.

* [Issue #188](https://github.com/pingidentity/helm-charts/issues/188) Add the PF_ADMIN_BASEURL environment variable to the pingfederate admin/engine configmaps

    With the 10.3 release of PingFederate, there is a variable used to provide redirect links called the PF_ADMIN_BASEURL.  This needs to be set by the helm chart, as it will either be a public host or localhost, depending on if the ingress is available.  The container has no idea which it should be as it doesn't have insight into the environment it's running.

    If ingress is enabled, an example for this variable is:

    ```
    PF_ADMIN_BAESURL=https://pingfederate-admin.example.com
    ```

    If ingress is not enable, an example for this variable:

    ```
    PF_ADMIN_BASEURL=https://localhost:9999
    ```

## Release 0.7.0 (August 09, 2021)

* [Issue #184](https://github.com/pingidentity/helm-charts/issues/184) Create default ServiceAccount/Role/RoleBinding for testFramework

    To allow for a role to be created during testing, an `rbac` section is added to the `testFramework` allowing for the definition of that Role.  If enabled, it will create a ServiceAccount, Role and RoleBinding using the same naming rules of resources and add that serviceAccount to the test pod.

    testFramework default rbac set to:

    ```
      #########################################################
      # If rbac is enabled, this will create:
      #   - serviceAccount
      #   - role
      #   - roleBinding (between serviceAccount and role)
      #
      # and apply the serviceAccount to the pod in the tests.
      # The names for these resources will be named using the
      # naming rules for all resources including the ReleaseName
      #########################################################
      rbac:
        enabled: true
        role:
          rules:
          - apiGroups:
            - '*'
            resources:
            - '*'
            verbs:
            - '*'
    ```

## Release 0.6.9 (August 06, 2021)

* [Issue #179](https://github.com/pingidentity/helm-charts/issues/179) Bump default image tag to 2107
* [Issue #182](https://github.com/pingidentity/helm-charts/issues/182) Set default startupProbe.timeoutSeconds to 5
* [Issue #180](https://github.com/pingidentity/helm-charts/issues/180) Enhance testFramework to support additional pod level configurations

    When using the testFramework there are additional pod level config items that need to be provided (i.e. serviceAccountName) along with the existing securityContext.

    To allow for any item to be configured, we should add a testFramework.pod that will pull in all items into the testFramework pod definition.

    Example:
    ```
    testFramework:
      #########################################################
      # Pod information to include
      #
      # Examples:
      #   securityContext for all containers
      #   serviceAccount for all containers
      #########################################################
      pod:
        securityContext:
          runAsUser: 1000
          runAsGroup: 2000
        serviceAccount: serviceaccount-name
    ```
    !!! note "Breaking changes"
        Note: that this will be a breaking change for anyone who has created a `testFramework.securityContext`.  If this is the case, they need to add `pod` in front of `securityContext`.

## Release 0.6.8 (July 29, 2021)

* [Issue #175](https://github.com/pingidentity/helm-charts/issues/175) Invalid ingress resources on Kubernetes clusters > 1.18

    During resoluton of issue #170 providing support for ingress apiVersion v1,
    the necessary ingress yaml fields wearn't updated to relfect that new version.
    This is a fix.  The backend definition of the Ingress will now reflect the proper
    definition based on a v1 or v1beta1 apiVersion.

    !!! note "Example: If KubeVersion > 1.18"
        ```
              service:
                name: https
                port:
                  number: 443
        ```

    !!! note "Example: If KubeVersion <= 1.18"
        ```
              serviceName: https
              servicePort: 443

        ```

    Additionally, adding the pathType for all versions as it is now required in
    ingress v1.


## Release 0.6.7 (July 28, 2021)

* [Issue #170](https://github.com/pingidentity/helm-charts/issues/170) Update Ingress resource kind

    If kubernetes vesion is >1.18, setting the ingress apiVersion to `v1`.  Otherwise, current
    default will be used `v1beta1`.

* [Issue #171](https://github.com/pingidentity/helm-charts/issues/171) Reevaluate Lifecycle probes

    Adding startupProble as well as re-organizing how the probes are defined, allowing the deployer to use standard k8s probe definitions out of the box.

    1. Moving the probes section under global.container
    2. Changing names: (liveness --> livenessProbe, readiness --> readinessProbe)
    3. Adding startupProbe

    The new default looks like:

    ```yaml
        ############################################################
        # Probes
        #
        # Probes have a number of fields that you can use to more precisely control the
        # behavior of liveness and readiness checks.
        #
        # https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
        ############################################################
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
            failureThreshold: 90
    ```

    !!! note "Breaking Changes"
        This is a breaking change if anyone has overriding probes in their own values file.  The fix is simply move their definition of their probes to live under global.container or the (productName).container, as well as adding "Probe" to the definition.

## Release 0.6.6 (July 7, 2021)

* [Issue #160](https://github.com/pingidentity/helm-charts/issues/160) Change default image tag to 2106
* [Issue #166](https://github.com/pingidentity/helm-charts/issues/166) Add securityContexts to testFramework containers
    * Adding ability to provide a securityContext at the following levels:
    * Changing the default finalStep image to busybox

        ```
        testFramework:
          ...
          #########################################################
          # SecurityContext for all containers
          #########################################################
          securityContext:
            runAsUser: 1000
            runAsGroup: 2000
            ...
            testSteps:
            - name: 01-init-example
              ...
              securityContext:
                runAsUser: ...
            ...
            finalStep:
              securityContext:
                runAsUser: ...
        ```

* [Issue #167](https://github.com/pingidentity/helm-charts/issues/167) Disable testFramework by default
    To enable, simply:

    ```yaml
    testFramework:
      enabled: true
      ...
    ```

## Release 0.6.5 (July 4, 2021)

* [Issue #163](https://github.com/pingidentity/helm-charts/issues/163) Add PingAuthorize and
    PingAuthorizePAP to helm charts.

    !!! note "Includes pre-release to PingAuthorize 8.3"
        This includes the necessary config for PingAuthorize and PingAuthorizePAP even though
        there isn't a release for 2105.  The current edge release is required to use the default
        server-profiles provided in the values.yaml.  Once the global tag is changed to 2106 (over next
        few days) PingAuthorize will be default for use over PingDataGoverance.  This will be tracked in
        a ticket released 2105.

    !!! note "Example yaml to test PingAuthoize/PAP"
        ```yaml
        pingdataconsole:
          enabled: true

        pingdirectory:
          enabled: true

        pingauthorize:
          image:
            tag: 8.3.0.0-edge
          enabled: true

        pingauthorizepap:
          enabled: true
        ```

## Release 0.6.4 (July 1, 2021)

* [Issue #158](https://github.com/pingidentity/helm-charts/issues/158) Increment default tag to 2105
    Sidecars and initContainers are valuable for a multitude of reasons - log forwarding, metric exporting, backup jobs. Because of this they can also have many ways of being configured.

    Allow for defining three top level maps to provide details for:

    * sidecars - Defines sidecar containers to be run alongside product containers.
    * initContainers - Defines initContainers to be run before product containers.
    * volumes - Defines volumes used by sidecars, initContainers and product containers.

    !!! note "Example definitions"
        ```yaml
        sidecars:
          pd-access-logger:
            name: pd-access-log-container
            image: pingidentity/pingtoolkit:2105
            volumeMounts:
              - mountPath: /tmp/pd-access-logs/
                name: pd-access-logs
                readOnly: false
          statsd-exporter:
            name: statsd-exporter
            image: prom/statsd-exporter:v0.14.1
            args:
            - "--statsd.mapping-config=/tmp/mapping/statsd-mapping.yml"
            - "--statsd.listen-udp=:8125"
            - "--web.listen-address=:9102"
            ports:
              - containerPort: 9102
                protocol: TCP
              - containerPort: 8125
                protocol: UDP

        initContainers:
          init-1:
            name: 01-init
            image: pingidentity/pingtoolkit:2105
            command: ['sh', '-c', 'echo "Initing 1" && touch /tmp/pd-access-logs/init-1']
            volumeMounts:
              - mountPath: /tmp/pd-access-logs/
                name: pd-access-logs
                readOnly: false

        volumes:
          pd-access-logs:
            emptyDir: {}
          statsd-mapping:
            configMap:
              name: statsd-config
              items:
                - key: config
                  path: statsd-mapping.yml
        ```

    And within the product (or global) definition, allow for inclusion of sidecars, initContainers and volumes.  These must be available in the top-level `sidecars:`, `initContainers:` and `volumes:`

    * includeSidecars
    * includeInitContainers - Run in order as listed in array
    * includeVolumes

    !!! note "Example usages"
        ```yaml
        pingdirectory:
          ...
          includeSidecars:
            - pd-access-logger
          includeInitContainers:
            - init-1
          includeVolumes:
            - pd-access-logs

          volumeMounts:
            - mountPath: /opt/access-logs/
              name: pd-access-logs
        ```

## Release 0.6.3 (June 21, 2021)

* [Issue #154](https://github.com/pingidentity/helm-charts/issues/154) Increment default tag to 2105
* [Issue #155](https://github.com/pingidentity/helm-charts/issues/155) Add clusterServiceName to product services with service clusters

## Release 0.6.2 (May 24, 2021)

* [Issue #151](https://github.com/pingidentity/helm-charts/issues/151) Add support for Container LifeCycle Event Hooks

    Adding following to values.yaml

    !!! note "Adding lifecycle hooks to container"
        ```yaml
        global:
          ############################################################
          # container life handlers, allowing for lifecycle events such
          # as postStart and preStop events
          #
          # https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event
          ############################################################
          lifecyle: {}
          # Example
          # lifecyle:
          #   postStart:
          #     exec:
          #       command: ["/bin/sh", "-c", "echo Start Complete > /tmp/message"]
        ```

* General cleanup of values.yaml comments

* Setting default `externalImages.pingtoolkit` tag to 2104, and removing `edge` tag from `ldap-sdk-tools` image
  which will now default to same `global.image.tag` setting (currently 2104)

## Release 0.6.1 (May 21, 2021)

* [Issue #148](https://github.com/pingidentity/helm-charts/issues/148) Calculate checksum of ConfigMaps based
  on the data rather than entire ConfigMap file

    This will only use the ConfigMap.data when creating checksums in workload rather than using the
    entire file.  It will result in no checksum change when labels/annotations are the only thing changing.
    A good example is the helm chart version, which changes the label, but not data.

## Release 0.6.0 (May 11, 2021)

* Changed default `global.image.pullPolicy` from `Always` to `IfNotPresent`.

    This is due to the fact that the `global.image.tag` is a non-floating tag. Once it is downloaded
    and present, it will not change.  This small change will increase performance at startup as images
    are typically present when installing/updating releases.

    Simply set `global.image.pullPolicy=Always` to pull every time if needed.

* BETA 2 - Testing Framework supporting `helm test` command and associated `testFramework` values.

    Cleaned up the generation of resources honoring the addReleaseNameToResource setting.

## Release 0.5.9 (May 10, 2021)

* BETA 1 - Testing Framework supporting `helm test` command and associated `testFramework` values.

    A testing framework is being created to allow for testing Ping Identity helm chart deployments using
    a `testFramework` set of values.  This is currently in beta, with documentation to available soon.
    Expect that changes will be made to this work, until it's fully released with documentation.

## Release 0.5.8 (May 6, 2021)

* [Issue #141](https://github.com/pingidentity/helm-charts/issues/141) Fix DNS_QUERY_LOCATION on pingfederate-engine configmap.yaml

    Resolves an issue with the DNS_QUERY_LOCATION when pingfederate clustering is used for >1 pingfederate-engines

## Release 0.5.7 (May 3, 2021)

* [Issue #136](https://github.com/pingidentity/helm-charts/issues/136) ClusterIP Services
  port/targetPort be set to the containerPort

    Since the ClusterIP Services (aka Headless services) only provide access to the underlying container
    IP and port.  The port, and by default targetPort, will be set to the containerPort value.  The helm
    charts will start requiring the containerPort for any service where clusterService:true is set, otherwise
    it will fail with an error message.

* [Issue #138](https://github.com/pingidentity/helm-charts/issues/138) Update image.tag to 2104 (April 2021)

## Release 0.5.5 (April 29, 2021)

* [Issue #133](https://github.com/pingidentity/helm-charts/issues/133) - Change default pingdirectory values
  (container.resources.requests.cpu=50m and container.replicaCount=1)

    Setting the cpu request to 50m, will provide at last some reservation of CPU, so that if there are multiple nodes,
    it will better even out the load.

    Additionally, setting the replicaCount to 1 by default, as many cases in development, there isn't a great need to
    have multiple replicas. If this is the case, simply set pingdirectory.container.replicaCount=2 or any number of replica's.

* [Issue #132](https://github.com/pingidentity/helm-charts/issues/132) - Adding PingDirectoryProxy to mix of products

## Release 0.5.5

* [Issue #126](https://github.com/pingidentity/helm-charts/issues/126) - Unable to mount secretVolume and configMapVolumes simultaneously

    This is one additional fix to the the same thing fixed in 0.5.4.  `volumeMounts:` had the same issue as `volumes:`.  This
    completes and resolves issue #126.

## Release 0.5.4

* [Issue #126](https://github.com/pingidentity/helm-charts/issues/126) - Unable to mount secretVolume and configMapVolumes simultaneously

    Due to the fact that volumes: is an array of items volumes: usage with secret or configMap volumes exosed
    the issue that multiple volumes: entries were used, and only kept the last one.  Fix included only using
    volumes: once.  Note that the template will end up with a `volumes: null` if none are
    set (i.e. deployment with no Secret/ConfigMap volumes), but that is ok.

## Release 0.5.3

* [Issue #121](https://github.com/pingidentity/helm-charts/issues/121) - Create global-env-vars hosts/ports
  for all products regardless if enabled

    The status of this config map is used to form the checksum for the products. This will ensure that a simple
    addition/deletion of a product from the deployed mix won't cause all products to be restarted.

* [Issue #122](https://github.com/pingidentity/helm-charts/issues/122) - Update image.tag to 2103 (March 2021)

    The image tag is modified to 2103. This includes:

    * Security Context on StatefulSets to include a fsGroup=9999 (same as gid)
    * Update the services ContainerPort to unprivileged ports (i..e. 636 --> 1636)

## Release 0.5.2

* [Issue #113](https://github.com/pingidentity/helm-charts/issues/113) - Default pingaccess-admin
  to StatefulSet

    In order to provide HA with a PingAccess cluster between admin/engine nodes, it is required that the
    PingAccess Admin deploy as a StatefulSet with persistence. Otherwise if the PingAccess Admin goes down,
    the engines would lose connectivity to that node and be unable to get further config updates and
    subsequently have to bounce and lose their web-session information.

    !!! note "The new default yaml"
        ```yaml
        pingaccess-admin:
          workload:
            type: StatefulSet
        ```

* [Issue #95](https://github.com/pingidentity/helm-charts/issues/95) - Fix default
  serviceAccount in workload for vault

    Fixed issue that was created in Issue 95 (using annotations to provide vault details) to pull serviceAccountName
    from the proper location in annotations.

    ```
      vault:
        hashicorp:
          annotations:
            serviceAccountName: vault-auth
    ```

* [Issue #116](https://github.com/pingidentity/helm-charts/issues/116) - Support Annotations
  at Workload Level.

    Support annotations at the workload level. For workloads, adding `.spec.template.metadata`.

    !!! note "Example telegraf annotation"
        ```
        pingfederate-engine:
          workload:
            annotations:
              telegraf.influxdata.com/class: app
        ```
        would lead to:
        ```
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          labels:
            app.kubernetes.io/instance: samir
            app.kubernetes.io/managed-by: Helm
            app.kubernetes.io/name: pingfederate-engine
            helm.sh/chart: ping-devops-0.5.1
          name: samir-pingfederate-engine
        spec:
          replicas: 1
          selector:
            matchLabels:
              app.kubernetes.io/instance: samir
              app.kubernetes.io/name: pingfederate-engine
          strategy:
            rollingUpdate:
              maxSurge: 1
              maxUnavailable: 0
            type: RollingUpdate
          template:
            metadata:
              annotations:
                telegraf.influxdata.com/class: app
        ```

* [Issue #117](https://github.com/pingidentity/helm-charts/issues/117) - Bug - cluster service
  shouldn't use image name for service name.

* [Issue #114](https://github.com/pingidentity/helm-charts/issues/114) - Revamp vault.hashicorp.secrets value .yaml and support per path secret
  Detailed documentation on this can be found the [Vault Config](config/vault.md) docs

## Release 0.5.1

* Added back in the service name by default to the private cert generation pulled out of the previous release by accident.

    If the product was `pingaccess-admin` and release was `acme`, then the service name might be `acme-ping-access-admin`.
    This name by default will be added to the alternative hosts of the private certificate generation by default.  Without this
    the pingaccess clustering will fail during setup.

## Release 0.5.0

* [Issue #103](https://github.com/pingidentity/helm-charts/issues/103) - Provide ability to add additional alt-names/alt-ips to private cert generation

    Allow for a privateCert structure to contain optional arrays `additionalHosts` and `additionalIPs`:

    ```
    pingaccess-admin:
      privateCert:
        generate: true
        additionalHosts:
        - pingaccess-admin.west-cluster.example.com
        - pa-admin.west-cluster.example.com
        additionalIPs:
        - 123.45.67.8
    ```

    In addition, if the ingress for the product is enabled, the host(s) created for that ingress will also be added to the alt-names.

    The above example (with an ingress) will create a cert used by pingaccess-admin containing:

    ```
    Certificate:
        Data:
            ...
        Signature Algorithm: sha256WithRSAEncryption
            Issuer: CN=pingaccess-admin
            ...
            X509v3 extensions:
                ...
                X509v3 Subject Alternative Name:
                    DNS:rel050-pa-pingaccess-admin.ping-devops.com. pingaccess-admin.west-cluster.example.com, DNS:pa-admin.west-cluster.example.com, IP Address:123.45.67.8
    ```
  
## Release 0.4.9

* [Issue #104](https://github.com/pingidentity/helm-charts/issues/104) - Update default global image tag to 2102 (Feb 2021)

    Update the default global image tag in base values.yaml and remove edge from example yamls.


## Release 0.4.8

* [Issue #100](https://github.com/pingidentity/helm-charts/issues/100) - Change pingfederate-engine HPA to a default of disabled

    Changing the default value `pingfederate-engine.clustering.autoscaling.enabled=false`, since the default
    CPU Request is set to 0.

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
