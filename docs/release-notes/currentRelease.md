# Release Notes
## Release 0.9.4 (August 05, 2022)
### Features ###
  - Updated default global image tag to `2207`.
  - Added support for apache-jmeter

### Resolved Defects ###
  - Fixed an issue making it impossible to use an existing service account (an account not managed by the Helm chart) for a workload. An existing service account can now be used by specifying the `{product}.rbac.serviceAccountName` field while leaving `{product}.rbac.generateServiceAccount` set to the default `false` value. See the PingAuthorize section of the updated [RBAC example](https://github.com/pingidentity/pingidentity-devops-getting-started/blob/master/30-helm/rbac.yaml)
