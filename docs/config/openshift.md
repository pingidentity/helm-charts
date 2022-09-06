---
title: Openshift Configuration
---
# Openshift Configuration

Openshift is designed to set the security context for workloads using a randomly generated user ID and group ID (UID/GID).

By default, however, the security context in the chart is hard-coded to values corresponding to the user and group IDs under which the product runs.  A flag has been added to support toggling the security context off.

With this toggle in place, a corresponding setting in `values.yaml` removes the securityContext stanza from the rendered output, allowing OpenShift to set the context as expected.

## Disable the security context

In the global section of the values.yaml file, add the following stanza:

```shell
global:
  workload:
    securityContext: null
```

## initContainers

Some of the product deployments use initContainers for various operations, such as waiting for other services to be available or configuration actions.  These containers, while part of the workload, have the security context set at the container - not pod - level. Therefore, they will continue to have a security context set even with the above stanza in your `values.yaml` file.  To null the securityContext for any pingtoolkit initContainers so Openshift can take over, also add the following stanza:
```shell
global:
  externalImage:
    pingtoolkit:
      securityContext: null
```

For example, here is a complete block for configuring pingaccess-admin with a **waitFor** initContainer:
```shell
global:
  workload:
    securityContext: null
  externalImage:
    pingtoolkit:
      securityContext: null

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