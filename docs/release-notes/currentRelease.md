# Release Notes
## Release 0.9.0 (April 01, 2022)
### Features ###
  - Default global image tag updated to 2203
  - Customizability on Cronjob and Utility Sidecar
    -   Override jobTemplate in CronJob now available.
    -   Override image used in utilitySidecar now available.
  - Updated the default PingDataSync workload in the Ping devops Helm charts to use a StatefulSet rather than a Deployment. This ensures that the sync-state.ldif file is maintained between pod restarts.