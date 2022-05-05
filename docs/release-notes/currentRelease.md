# Release Notes
## Release 0.9.1 (May 05, 2022)
### Features ###
  - Updated default global image tag to `2204`
  - Updated the PingDataSync env vars ConfigMap to include variables needed to enable failover between servers. Failover will be enabled when deploying two or more PingDataSync replicas
  - Reduced utilitySidecar resource requests
### Resolved Defects ###
  - Updated the image.repositoryFqn field to be consistent with the other fields under image.
    Previously, repositoryFqn was expected at the same level as the image: section, now it is expected within the image: section like other fields (tag, pullPolicy, etc.).
    The image tag must now be provided separately from the repositoryFqn. The repositoryFqn should only be the name of the repository, not the tag of the specific image.
  - Fixed a version check in the Helm chart for choosing the correct k8s API for Ingress. The version check was previously failing on EKS clusters due to the format EKS uses for the cluster version.
