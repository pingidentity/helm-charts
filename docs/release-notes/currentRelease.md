# Release Notes
## Release 0.9.21 (December 4, 2023)
### Features ###
  - Updated default global image tag to `2311`.

### Defects ###
  - Updated the workload template to avoid setting `replicas` when autoscaling is enabled.
  - Improved capabilities checks for `apiVersion` field to avoid issues with prerelease Kubernetes versions.
