# PingFederate...admin and engine

This example values below deploys a PingFederate Admin Console and Engine.

## Deploy

```shell
helm upgrade --install pf pingidentity/ping-devops \
     -f https://helm.pingidentity.com/examples/pingfederate.yaml
```

## Uninstall

```shell
helm uninstall pf
```

## Config Yaml

```yaml
global:
  image:
    tag: "edge"  # Uses images with the "edge" tag

############################################################
# Ping DevOps Service Customizations
#
# This provides:
#  - PingFederate Administrative Console with native authentication
#  - PingFederate Engines clustered with console
############################################################
pingfederate-admin:
  enabled: true
  envs:
    SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
    SERVER_PROFILE_PATH: getting-started/pingfederate

pingfederate-engine:
  enabled: true
  envs:
    SERVER_PROFILE_URL: https://github.com/pingidentity/pingidentity-server-profiles.git
    SERVER_PROFILE_PATH: getting-started/pingfederate
```
