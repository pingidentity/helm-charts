# Release Notes
## Release 0.9.10 (February 03, 2023)
### Features ###
  - Updated default global image tag to `2301`.
  - Updated the securityContext defaults for Pods and containers in the ping-devops Helm chart to satisfy the "restricted" Pod Security Standard in Kubernetes
  - Added support for running a separate LoadBalancer service for each PingDirectory pod. This may be useful when running across multiple regions when using VPC peering isn't possible.

### Resolved Defects
  - Updated the HorizontalPodAutoscaler API to use the correct value for Kubernetes versions greater than 1.23.
