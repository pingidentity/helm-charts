# Service Configuration

[Kubernetes Service resources](https://kubernetes.io/docs/concepts/services-networking/service/)
are created depending on configuration values.

## Product Section

Default yaml defined in the product services section.
The example found in the `pingfederate-admin` section is:

```yaml
services:
  admin:
    servicePort: 9999
    containerPort: 9999
    ingressPort: 443
    dataService: true
  clusterbind:
    servicePort: 7600
    containerPort: 7600
    clusterService: true
  clusterfail:
    servicePort: 7700
    containerPort: 7700
    clusterService: true
  clusterExternalDNSHostname:
```

| Service Parameters                  | Description                                                   |
| ----------------------------------- | ------------------------------------------------------------- |
| services                            | Array of services                                             |
| services[].{name}                   | Service Name. (i.e. https, ldap, admin, api)                  |
| services[].{name}.servicePort       | External port of service                                      |
| services[].{name}.containerPort     | Port on target container                                      |
| services[].{name}.ingressPort       | Port on ingress container (if ingress is used)                |
| services[].{name}.dataService       | Adds to a ClusterIP service with single DNS/IP                |
| services[].{name}.clusterService    | Adds to a headless service with DNS request returning all IPs |
| services.clusterExternalDNSHostname |                                                               |

The example above will create a container/service/ingress that looks like:

```
  +-------------+               +-----------+              +-----------+
  |  Container  |--(9999)-------|  Service  |-(9999)-------|  Ingress  |-(443)---
  +-------------+               +-----------+              +-----------+


  +-------------+  (7600)       +-----------+ (7600)
  |  Container  |--(7700)-------|  Service  |-(7700)
  +-------------+               +-----------+
```