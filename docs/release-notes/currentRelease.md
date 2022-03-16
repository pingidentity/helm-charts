# Release Notes
## Release 0.8.8 (Mar 16, 2022)
### Features ###
  - Added support for fully qualified image location. For more information go to the image section in our [values.yaml](https://github.com/pingidentity/helm-charts/blob/18a8972cb10dcef0747c2a6b0dcf8350dded52f2/charts/ping-devops/values.yaml#L155)
  ```
    image:
    repository: pingidentity
    repositoryFqn:
    name:
    tag: "2202"
    pullPolicy: IfNotPresent
  ```