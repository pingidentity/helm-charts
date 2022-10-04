# Release Notes
## Release 0.9.6 (October 04, 2022)
### Features ###
  - Updated default global image tag to `2209`.
  - Added support for deploying a HorizontalPodAutoscaler for pingaccess-engine, pingfederate-admin, pingdelegator, pingauthorize, pingauthorizepap, pingcentral, and pingdataconsole. Previously, deploying a HorizontalPodAutoscaler was only supported for pingfederate-engine.
  - Added support for setting the podManagementPolicy for StatefulSet workloads. The default policy is OrderedReady. The Parallel policy allows for starting up multiple Pods of the StatefulSet simultaneously, improving initial deployment times. Parallel startup is only supported with PingDirectory and PingDataSync, and only with images version `2209` and newer.
