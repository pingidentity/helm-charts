# Welcome 

This is the documentation for using [Helm](https://helm.sh) to deploy the Ping Identity Docker Images.  
This single chart can be used to deploy any of the available Ping Identity products in a Kubernetes
environment.

## Prerequisites

* Kubernetes 1.16+
* Helm 3
* Ping Identity DevOps User/Key

## Adding the Helm Repo

To add the PingIdentity Helm repoository:

    $ helm repo add pingidentity https://helm.pingidentity.com/

## Listing the Charts

To list the charts in the pingidentity repository:

    $ helm search repo pingidentity

## Removing the Repo

Should you need to remove the repo:

    $ helm repo rm pingidentity
