# Vault Configuration

Based on use of Hashicorp Vault.
More information on Hashicorp Vault annotations can be found [here](https://www.vaultproject.io/docs/platform/k8s/injector/annotations).

## Global Section

Default yaml defined in the global vault section.  The options of annotation names/values
can be found at
[vault definitions](https://www.vaultproject.io/docs/platform/k8s/injector/annotations)

For each of the annotations, the helm chart will automatically pre-pend the annotation with the
hashicorp annotation prefix of `vault.hashicorp.com`.  See example below.

```yaml
global:
  vault:
    enabled: false
    hashicorp:
      annotations:
        agent-inject: true
        agent-init-first: true
        agent-pre-populate-only: true
        log-level: info
        preserve-secret-case: true
        role: k8s-default
        secret-volume-path: /run/secrets
        serviceAccountName: vault-auth
      # secretPrefix: path/to/secrets
      # secrets:
      # - name: secret-name
      #   secret: secret-name
```

!!! warning "Versions prior to 0.4.7"
    Previous helm-chart versions (< 0.4.7) used specific names for passing annotations.  These
    have been depreciated with new annotations, along with proper names.  The included:
    ```yaml
        hashicorp:
          role: k8s-default
          log-level: info
          preserve-secret-case: true
          secret-volume-path: /run/secrets
          agent-pre-populate-only: true
          serviceAccountName: vault-auth
    ```


!!! note "Example: A vault.yaml values file create workload manifest annotations of"
    Example vault.yaml

    ```yaml
    pingfederate-admin:
      vault:
        enabled: true
        hashicorp:
          # secretPrefix: path/to/secrets
          # secrets:
          # - name: secret-name
          #   secret: secret-name
          annotations:
            log-level: debug
            tls-secret: vault-tls
    ```

    Creates following workload manifest annotations

    ```yaml
    annotations:
      vault.hashicorp.com/agent-init-first: "true"
      vault.hashicorp.com/agent-inject: "true"
      vault.hashicorp.com/agent-inject-secret-secret-name.json: path/to/secrets/secret-name
      vault.hashicorp.com/agent-inject-template-secret-name.json: |
        {{ with secret "path/to/secrets/secret-name/secret-name" -}}
        {{ .Data.data | toJSONPretty }}
        {{- end }}
      vault.hashicorp.com/agent-pre-populate-only: "true"
      vault.hashicorp.com/log-level: debug
      vault.hashicorp.com/preserve-secret-case: "true"
      vault.hashicorp.com/role: k8s-default
      vault.hashicorp.com/secret-volume-path: /run/secrets
      vault.hashicorp.com/serviceAccountName: vault-auth
      vault.hashicorp.com/tls-secret: vault-tls
    ```
