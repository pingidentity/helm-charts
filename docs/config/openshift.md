---
title: Openshift Configuration
---
# Openshift Configuration

Openshift is designed to use a randomly generated user ID and group ID (UID/GID) for the `runAsUser` and `fsGroup` fields of the Pod- and container-level security contexts.

By default, the security contexts in the chart use values corresponding to the user and group IDs under which the product runs. You can unset the `fsGroup` and `runAsUser` securityContext fields in your custom values, allowing OpenShift to set them as expected.

## Unset fsGroup and runAsUser at the Pod level

In the global section of the values.yaml file, add the following stanza:

```shell
global:
  workload:
    securityContext:
      fsGroup: null
      runAsUser: null
```

This will unset `fsGroup` and `runAsUser` in the Pod-level security context. Pods that require initContainers will have to also unset `runAsUser` in the container-level security context.

## initContainers: unset runAsUser at the container level

Some of the product deployments use initContainers for various operations, such as waiting for other services to be available or configuration actions.  These containers, while part of the workload, have the security context set at the container - not pod - level.  The values listed above apply only to the Pod-level security context.  To unset `runAsUser` for any pingtoolkit initContainers so Openshift can take over, also add the following stanza:
```shell
global:
  externalImage:
    pingtoolkit:
      securityContext:
        runAsUser: null
```

For example, here is a complete block for configuring pingaccess-admin with a **waitFor** initContainer:
```shell
global:
  workload:
    securityContext:
      fsGroup: null
      runAsUser: null
  externalImage:
    pingtoolkit:
      securityContext:
        runAsUser: null

pingaccess-admin:
  enabled: true
  privateCert:
    generate: true
  envs:
    SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
    SERVER_PROFILE_PATH: baseline/pingaccess
  container:
    waitFor:
      pingfederate-engine:
        service: https
        timeoutSeconds: 300
```