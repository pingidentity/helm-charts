# Helm Chart Example Configs

| Config       | Description                                    | .yaml                                  |
| ------------ | ---------------------------------------------- | -------------------------------------- |
| Everything   | Example with most products integrated together | [everything.yaml](everything.yaml)     |
| PingFederate | PingFederate Admin Console & Engine            | [pingfederate.yaml](pingfederate.yaml) |
| Simple Sync  | PingDataSync and PingDirectory                 | [simple-sync.yaml](simple-sync.yaml)   |

## To Deploy

```shell
helm upgrade --install my-release pingidentity/ping-devops \
     -f <HTTP link to yaml>
```

## Uninstall

```shell
helm uninstall my-release
```
