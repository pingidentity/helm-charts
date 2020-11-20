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
  envs:
    SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
    SERVER_PROFILE_PATH: baseline/pingfederate

pingfederate-engine:
  enabled: true
  envs:
    SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
    SERVER_PROFILE_PATH: baseline/pingfederate

ldap-sdk-tools:
  enabled: false

pd-replication-timing:
  enabled: false
```
