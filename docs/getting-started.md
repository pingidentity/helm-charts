# Getting Started

Helm is a package deployment tool for Kubernetes. It can be used with PingDevops to deploy all the components of the Solution with a simple command.

## Pre-Requisites

* Kubernetes Cluster
* Helm 3
* Ping Identity DevOps User/Key

## Create Ping DevOps Secret

The charts use a secret called `devops-secret` to obtain an evaluation license for running images.

* Eval License - Use your `PING_IDENTITY_DEVOPS_USER/PING_IDENTITY_DEVOPS_KEY` credentials
  along with your `PING_IDENTITY_ACCEPT_EULA` setting.
  * For more information on obtaining credentials click [here](https://pingidentity-devops.gitbook.io/devops/getstarted/prod-license#obtaining-a-ping-identity-devops-user-and-key).
  * For more infomration on using `ping-devops` utility click [here](https://pingidentity-devops.gitbook.io/devops/devopsutils/pingdevopsutil).

        ```shell
        ping-devops generate devops-secret | kubectl apply -f -
        ```

## Install Helm 3

Ensure that you have Helm 3 installed.

* Installing on MacOS (or linux with brew)

```shell
brew install helm
```

* Installing on other OS - <https://helm.sh/docs/intro/install/>

## Add Helm Ping DevOps Repo

```shell
helm repo add pingidentity https://helm.pingidentity.com/
```

## List Ping DevOps Charts

```shell
helm search repo pingidentity
```

## Update local machine with latest charts

```shell
helm repo update
```

## Install the Ping DevOps Chart

Install the `ping-devops` chart using the example below.  In this case, it is installing a release called `pf`:

* PingFederate Admin instance
* PingFederate Engine instance

```shell
helm install pf pingidentity/ping-devops \
     --set pingfederate-admin.enabled=true \
     --set pingfederate-engine.enabled=true
```

or, if you have a `ping-devops-values.yaml`:

```yaml
# ping-devops-values.yaml
pingfederate-admin:
  enabled: true

pingfederate-engine:
  enabled: true
```

```shell
helm install pf pingidentity/ping-devops \
     -f ping-devops-values.yaml
```

## Accessing Deployments

Components of the release will be prefixed with `pf`.  Use `kubectl` to see the pods created.

View kubernetes resources installed:

```shell
# get just pods
kubectl get pods --selector=app.kubernetes.io/instance=pf

# or get even more
kubectl get all --selector=app.kubernetes.io/instance=pf
```

View Logs (from deployment):

```shell
kubectl logs deployment/pf-pingfederate-admin
```

## Uninstalling Release

To uninstall a release from helm, use the following `helm uninstall` command:

```shell
helm uninstall pf
```
