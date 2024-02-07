# Ingress Configuration

[Kubernetes Ingress resources](https://kubernetes.io/docs/concepts/services-networking/ingress/) are created depending on configuration values.

## Global Section

Default yaml defined in the global ingress section, followed by definitions for each parameter:

```yaml
global:
  ingress:
    enabled: false
    addReleaseNameToHost: subdomain
    defaultDomain: example.com
    defaultTlsSecret:
    annotations: {}
    spec: {}
```

| Ingress Parameters   | Description                                                                                 | Options                                | Default Value |
| -------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------- | ------------- |
| enabled              | Enables ingress definition.                                                                 |                                        | false         |
| addReleaseNameToHost | How helm `release-name` should be added to host.                                            | prepend<br>append<br>subdomain<br>none | subdomain     |
| defaultDomain        | Default DNS domain to use.  Replaces the string "\_defaultDomain\_".                        |                                        | example.com   |
| defaultTlsSecret     | Default TLS Secret to use.  Replaces the string "\_defaultTlsSecret\_".                     |                                        |               |
| annotations          | Annotations are used to provide configuration details to specific ingress controller types. | * see option for nginx ingress         | {}            |
| spec.ingressClassName   | This value is replacing the `kubernetes.io/ingress.class` annotation.  See [this page](https://kubernetes.github.io/ingress-nginx/user-guide/k8s-122-migration/#what-is-the-flag-watch-ingress-without-class) for details. | name of the IngressClass resource         | {}             |


!!! note "Annotations example for nginx ingress"
    ```yaml
        annotations:
          nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    ```

!!! note "ingressClassName specification example for nginx ingress"
    ```yaml
        spec:
          # Must match the name of the IngressClass resource
          ingressClassName: nginx-public
    ```

## Product Section

Default yaml defined in the product ingress section, followed by definitions for each parameter:

```yaml
  ingress:
    hosts:
      - host: pingfederate-admin._defaultDomain_
        paths:
        - path: /
          backend:
            serviceName: admin
    tls:
      - secretName: _defaultTlsSecret_
        hosts:
```

| Ingress Parameters                  | Description                                                                                              | Default Value                    |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------- |
| hosts                               | Array of hosts definitions                                                                               |                                  |
| hosts[].host                        | Full DNS name of host to use for external name. "\_defaultDomain\_" will be replaced with .defaultDomain | {product-name}.\_defaultDomain\_ |
| hosts[].paths                       | Array of paths to define for host                                                                        |                                  |
| hosts[].paths[].path                | Path on external ingress                                                                                 |                                  |
| hosts[].paths[].backend.serviceName | Name of the service to map to.  This will result in the ingressPort on the server to be used.            |                                  |
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
                                   ReleaseName    defaultDomain
    ```

## Example Ingress Manifest

Example product ingress for `pingfederate-admin` when deployed by helm with a release-name of `acme`.
Includes an ingress for the admin service (9999) using the default domain and tls secret, defined
in the global section (if set).

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
          serviceName: admin
        path: /
  tls:
  - hosts:
    - pingfederate-admin.acme.example.com
    secretName: ""
```
