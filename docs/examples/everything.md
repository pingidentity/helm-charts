# Everything...and the kitchen sink

This example values below deploys all the product/images integrated with one another.

## Deploy

```shell
helm upgrade --install everything pingidentity/ping-devops \
     -f https://helm.pingidentity.com/examples/everything.yaml
```

## Uninstall

```shell
helm uninstall everything
```

## Everything Config Yaml

```yaml
global:
  image:
    tag: "edge"  # Uses images with the "edge" tag

pingaccess:
  enabled: true

pingdataconsole:
  enabled: true

pingdatagovernance:
  enabled: true

pingdatasync:
  enabled: true

pingdelegator:
  enabled: true

pingdirectory:
  enabled: true

pingfederate-admin:
  enabled: true

pingfederate-engine:
  enabled: true

ldap-sdk-tools:
  enabled: false

pd-replication-timing:
  enabled: false
```
