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
