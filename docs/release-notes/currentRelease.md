# Release Notes
## Release 0.8.5 (Feb 7, 2022)
### Features ###
  - PingCentral now supported. Example values application found [here](../examples/pingcentral/pingcentral.yaml)
### Issues Resolved ###
  - [Issue #119](https://github.com/pingidentity/helm-charts/issues/119) Workload template not honoring false values from values.yaml. Previously, false did not overwrite true in the Ping Identity Helm Chart template. This fix in _merge-util.tpl will resolve multiple cases within the Ping Identity Helm Chart.
    ```
    {{- $globalValues := deepCopy $top.Values.global -}}
    {{- $prodValues := deepCopy (index $top.Values $prodName) -}}
    {{- $mergedValues := mergeOverwrite $globalValues $prodValues -}}
    ```
  - [Issue #264](https://github.com/pingidentity/helm-charts/issues/264) Update default global.image.tag to 2201