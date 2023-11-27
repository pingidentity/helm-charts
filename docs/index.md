# Welcome

This is the documentation for using [Helm](https://helm.sh) to deploy the Ping Identity Docker Images.
This single chart can be used to deploy any of the available Ping Identity products in a Kubernetes
environment. 

## DevOps Resources

<div class="banner" onclick="window.open('https://devops.pingidentity.com','');">
    <img class="assets" src="img/logos/devops.png"/>
    <span class="caption">
        <a class="assetlinks" href="https://devops.pingidentity.com" target=”_blank”>Ping DevOps</a>
    </span>
</div>
<div class="banner" onclick="window.open('https://hub.docker.com/u/pingidentity','');">
    <img class="assets" src="img/logos/docker.png" />
    <span class="caption">
        <a class="assetlinks" href="https://hub.docker.com/u/pingidentity" target=”_blank”>Docker Images</a>
    </span>
</div>
<div class="banner" onclick="window.open('https://github.com/topics/ping-devops','');">
    <img class="assets" src="img/logos/github.png"/>
    <span class="caption">
        <a class="assetlinks" href="https://github.com/topics/ping-devops" target=”_blank”>Github Repos</a>
    </span>
</div>
<div class="banner" onclick="window.open('https://support.pingidentity.com/s/topic/0TO1W000000IF30WAG/cloud-devops','');">
    <img class="assets" src="img/logos/ping.png"/>
    <span class="caption">
        <a class="assetlinks" href="https://support.pingidentity.com/s/topic/0TO1W000000IF30WAG/cloud-devops" target=”_blank”>Community</a>
    </span>
</div>

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
