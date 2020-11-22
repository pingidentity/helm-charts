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

* [pingfederate.yaml](pingfederate.yaml)
