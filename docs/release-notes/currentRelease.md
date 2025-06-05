# Release Notes
## Release 0.11.8 (June 4, 2025)
### Features ###
  - Updated default global image tag to `2505`.
  - Support creation of CronJob resources for PingFederate, similar to the existing support available for PingDirectory (PDI-2218).

### Enhancements ###
  - Allow setting securityContext for CronJob and utility sidecar (PDI-2208).

### Bug fixes ###
  - Fix incorrect indentation of global configMap name when setting global annotations (PDI-2215).
