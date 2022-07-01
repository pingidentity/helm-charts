# Helm Chart Example Configs

The following contains example configs and examples of how to run and configure Ping products
using the Ping Devops Helm Chart. Please review the [Getting Started Page](../getting-started.md) before trying them.

| Config                           | Description                                    | .yaml                                                                                                                                                                                           |
| ---------------------------------| -----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Everything                       | Example with most products integrated together | [everything.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/everything.yaml)                                                            |
| PingAccess                       | PingAccess Admin Console & Engine              | [pingaccess-cluster.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingaccess-cluster.yaml)                                            |
| PingCentral                      | PingCentral                                    | [pingcentral.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingcentral.yaml)                                                          |
| PingFederate                     | PingFederate Admin Console & Engine            | [pingfederate-cluster.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingfederate-cluster.yaml)                                        |
| PingFederate                     | Upgrade PingFederate                           | See .yaml files in [pingfederate-upgrade](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/30-helm/pingfederate-upgrade)                                         |
| PingDirectory                    | PingDirectory Cluster                          | [pingdirectory.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingdirectory.yaml)                                                      |
| Simple Sync                      | PingDataSync and PingDirectory                 | [simple-sync.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/simple-sync.yaml)                                                          |
| PingDirectory Backup and Sidecar | PingDirectory with periodic backup and sidecar | [pingdirectory-periodic-backup.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/pingdirectory-backup/pingdirectory-periodic-backup.yaml) |
| Ingress                          | Expose an application outside of the cluster   | [ingress.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/ingress.yaml)                                                                  |
| Vault                            | Example vault values section                   | [vault.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/vault.yaml)                                                                      |
| Cluster Metrics                  | Example values using various open source tools | See .yaml files in [cluster-metrics](https://github.com/pingidentity/pingidentity-devops-getting-started/tree/master/30-helm/cluster-metrics)                                               |
| RBAC                             | Enable RBAC for workloads                      | [rbac.yaml](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/rbac.yaml)                                               |

## To Deploy

```shell
helm upgrade --install my-release pingidentity/ping-devops \
     -f <HTTP link to yaml>
```

## Uninstall

```shell
helm uninstall my-release
```
