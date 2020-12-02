# Service Configuration

[Kuernetes Service resources](https://kubernetes.io/docs/concepts/services-networking/service/)
are created depending on configuration values.

## Product Section

Default yaml defined in the product services section.
The example found in the `pingfederate-admin` section is:

```yaml
pingfederate-admin:
  services:
    admin:
      port: 9999
      targetPort: 9999
      dataService: true
    clusterbind:
      port: 7600
      targetPort: 7600
      clusterService: true
    clusterfail:
      port: 7700
      targetPort: 7700
      clusterService: true
    clusterExternalDNSHostname:
```

| Service Parameters                  | Description                                                   |
| ----------------------------------- | ------------------------------------------------------------- |
| services                            | Array of services                                             |
| services[].{name}                   | Service Name. (i.e. https, ldap, admin, api)                  |
| services[].{name}.port              | External port of service                                      |
| services[].{name}.targetPort        | Port on target container                                      |
| services[].{name}.dataService       | Adds to a ClusterIP service with single DNS/IP                |
| services[].{name}.clusterService    | Adds to a headless service with DNS request returning all IPs |
| services.clusterExternalDNSHostname |                                                               |
