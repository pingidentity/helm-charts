# Release Notes
## Release 0.9.5 (September 01, 2022)
### Features ###
  - Updated default global image tag to `2208`.
  - Added support for setting container-level securityContext values for the main container of each workload. By default no container-level securityContext will be set. A container-level securityContext isn't necessary if the values from the Pod-level securityContext are sufficient.
  - Added support for setting the topologySpreadConstraints field on workloads.
  - Added support for setting the enableServiceLinks field on workloads.

### Documentation ###
  - Added an [example](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/vault-keystores.yaml) for mounting keystore secrets with Vault
  - Added an [example](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/csi-secrets-volume.yaml) for mounting secrets with CSI volumes (which can be used for various storage systems including AWS secrets manager)
  - Fixed Helm [RBAC example](https://raw.githubusercontent.com/pingidentity/pingidentity-devops-getting-started/master/30-helm/rbac.yaml) using an invalid serviceAccountName for pingauthorize
  - Added a [doc page](https://helm.pingidentity.com/howto/updatetags/) describing how to update product versions
  - Added example docs for deploying [PingDirectory](https://devops.pingidentity.com/deployment/deployPDMultiRegion/) and [PingFederate](https://devops.pingidentity.com/deployment/deployPFMultiRegion/) in a multi-region environment with Helm

### Resolved Defects ###
  - Removed support for apache-jmeter, since it is better suited to run as a Job than as a long-running workload.
