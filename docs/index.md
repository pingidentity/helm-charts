# Welcome

This is the documentation for using [Helm](https://helm.sh) to deploy the Ping Identity Docker Images.
This single chart can be used to deploy any of the available Ping Identity products in a Kubernetes
environment.

## Prerequisites

* Kubernetes 1.16+
* Helm 3
* Ping Identity DevOps User/Key

## Adding the Helm Repo

```shell
helm repo add pingidentity https://helm.pingidentity.com/
```

## Removing the Repo

```shell
helm repo rm pingidentity
```
