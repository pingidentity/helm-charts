# Ingress Configuration

Provides values to define kubernetes ingress information to ingresses.

More information on Kuernetes ingress resources can be found [here](https://kubernetes.io/docs/concepts/services-networking/ingress/).

The example found in the `global:` section is:

```yaml
  ingress:
    enabled: true
    addReleaseNameToHost: subdomain
    defaultDomain: example.com
    defaultTlsSecret:
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      kubernetes.io/ingress.class: "nginx-public"
```

and a `product:` section (pingfederate-admin as example) is:

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

Translating to kubernetes manifest information (when `.Release.Name=acme`):

```yaml
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx-public
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
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
