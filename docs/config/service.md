# Service Configuration

Provides values to define kubernetes service detail.

More information on Kuernetes services can be found [here](https://kubernetes.io/docs/concepts/services-networking/service/).

The example found in the `product.pingfederate-admin:` section is:

```yaml
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

This will create a regular data service (i.e. 9999) and cluster, aka "headless" service (i.e. 7600, 7700), depending on the settings of the `dataService` and `clusterService` booleans.

Translating to applicable kubernetes manifest sections:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: acme-pingfederate-admin
spec:
  ports:
  - name: admin
    port: 9999
    protocol: TCP
    targetPort: 9999
  selector:
    app.kubernetes.io/instance: pf
    app.kubernetes.io/name: pingfederate-admin
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
  name: acme-pingfederate-admin-cluster
spec:
  clusterIP: None
  ports:
  - name: clusterbind
    port: 7600
    protocol: TCP
    targetPort: 7600
  - name: clusterfail
    port: 7700
    protocol: TCP
    targetPort: 7700
  publishNotReadyAddresses: true
  selector:
    clusterIdentifier: acme-pingfederate-admin
  type: ClusterIP
```
