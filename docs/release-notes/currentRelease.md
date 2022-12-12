# Release Notes
## Release 0.9.8 (December 05, 2022)
### Features ###
  - Updated default global image tag to `2211`.
  - Custom annotations can now be specified for Services.

### Defects ###
  - Fixed HorizontalPodAutoscaler autoscalingMetricsTemplate being inserted in the wrong location in the generated yaml.
  - Fixed the documentation in values.yaml referring to `pingdirectory.cronjob.jobspec` rather than the correct value `pingdirectory.cronjob.jobTemplate`
