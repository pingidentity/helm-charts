# VolumeMounts Configuration

Provides support for mounting secret or configMap volumes on a workload container.

## Global/Product Section

Adds ability to use **secret** and **configMap** data in a container via a VolumeMount.  A common use for this configuration is bringing product licenses or scripts into the container.

!!! note "Example of creating 2 volume mounts in container from secret and configMap"
    ```yaml
    pingfederate-admin:
        enabled: true
        volumes:
          - name: pf-props
            configMap:
              name: pingfederate-props
          - name: pf-license
            secret:
              secretName: pingfederate-license
        volumeMounts:
          - mountPath: /opt/in/etc/pingfederate.properties
            name: pf-props
          - mountPath: /opt/in/instance/server/default/conf/pingfederate.lic
            name: pf-license
    ```

> [Secrets](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl) and [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) must be created in the cluster prior to deploying the helm chart.

In this case, a secret (called `pingfederate-license`) and configMap (called `pingfederate-props`) will bring in a
couple of key values (license, hello) and (pf-props) into the container as specific files. The resulting object will look like:

!!! note "Example of kubectl describe of pingfederate-admin container"
    ```
    Containers:
      pingfederate-admin:
        Mounts:
          /opt/in/etc/pingfederate.properties from pingfederate-props (ro,path="pingfederate.properties")
          /opt/in/instance/server/default/conf/pingfederate.lic from pingfederate-license (ro,path="pingfederate.lic")
    Volumes:
      pingfederate-license:
        Type:        Secret (a volume populated by a Secret)
        SecretName:  pingfederate-license
        Optional:    false
      pingfederate-props:
        Type:      ConfigMap (a volume populated by a ConfigMap)
        Name:      pingfederate-props
        Optional:  false
    ```
