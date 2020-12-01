# Ingress Configuration

[Kuernetes Ingress resources](https://kubernetes.io/docs/concepts/services-networking/ingress/) can be craeted depending on configuration values.

## Global Section

Default yaml defined in the global ingress section, followed by definitions for each parameter.

```yaml
  ingress:
    enabled: true
    addReleaseNameToHost: subdomain
    defaultDomain: example.com
    defaultTlsSecret:
    annotations: {}
```

| Ingress Parameters   | Description                                                                                  | Options                                | Default Value |
| -------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------- | ------------- |
| enabled              | Enables ingress definition.                                                                  |                                        | false         |
| addReleaseNameToHost | How helm `release-name` should be added to host.                                             | prepend<br>append<br>subdomain<br>none | subdomain     |
| defaultDomain        | Default DNS domain to use.  Replaces the string "\_defaultDomain\_".                         |                                        | example.com   |
| defaultTlsSecret     | Default TLS Secret to use.  Replaces the string "\_defaultTlsSecret\_".                      |                                        |               |
| annotations          | Annotations are used to provide configuaration details to specific ingress controller types. | * see option for nginx ingress         | {}            |

!!! note "Annotations example for nginx ingress"
    ```yaml
        annotations:
          nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
          kubernetes.io/ingress.class: "nginx-public"
    ```

## Product Section

Default yaml defined in the product ingress section, followed by definitions for each parameter.

```yaml
  ingress:
    hosts:
      - host: pingfederate-admin._defaultDomain_
        paths:
        - path: /
          backend:
            servicePort: 9999
    tls:
      - secretName: _defaultTlsSecret_
        hosts:
```

| Ingress Parameters                  | Description                                                                                              | Default Value                    |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------- |
| hosts                               | Array of hosts definitions                                                                               |                                  |
| hosts[].host                        | Full DNS name of host to use for external name. "\_defaultDomain\_" will be replaced with .defaultDomain | {product-name}.\_defaultDomain\_ |
| hosts[].paths                       | Array of paths to define for host                                                                        |                                  |
| hosts[].paths[].path                | Path on external ingress                                                                                 | /                                |
| hosts[].paths[].backend.servicePort | Port on the product service to map to                                                                    | 9999 (for PingFederate)          |
| tls                                 | Array of tls definitions                                                                                 |                                  |
| tls[].secretName                    | Certificate secret to use                                                                                | \_defaultTlsSecret\_             |
| tls[].hosts                         | Array of specific hosts                                                                                  |                                  |

!!! note "Example Use of \_defaultDomain\_ and addReleaseNameToHost"
    ```
        helm ReleaseName = acme
            defaultDomain = example.com
     addReleaseNameToHost = subdomain
    ingress.hosts[0].host = pingfed-admin._defaultDomain_

    Resulting host will be:  pingfed-admin.acme.example.com
                                             ^    ^^^^^^^
                                             |       |
                                    ReleseName    defaultDomain
    ```

## Example Ingress Manifest

Example product ingress for pingfedeate-admin when deployed by helm with a release-name of acme.  Includes an ingress for port 9999 using the default domain and tls secret, defined in the global section, if set.

```yaml
kind: Ingress
metadata:
  annotations:
    ....
spec:
  rules:
  - host: pingfederate-admin.acme.example.com
    http:
      paths:
      - backend:
          serviceName: acme-pingfederate-admin
          servicePort: 9999
        path: /
  tls:
  - hosts:
    - pingfederate-admin.acme.example.com
    secretName: ""
```
