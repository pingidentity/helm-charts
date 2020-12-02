# Vault Configuration

Based on use of Hashicorp Vault.
More information on Hashicorp Vault annotations can be found [here](https://www.vaultproject.io/docs/platform/k8s/injector/annotations).

## Global Section

Default yaml defined in the product vault section.

```yaml
global:
  vault:
    enabled: false
    hashicorp:
      role: k8s-default
      log-level: info
      preserve-secret-case: true
      secret-volume-path: /run/secrets
      pre-populate-only: true
      serviceAccountName: vault-auth
      # secretPrefix: path/to/secrets
      # secrets:
      # - name: secret-name
      #   secret: secret-name
```

The definition of parameters can be found at
[vault definitions](https://www.vaultproject.io/docs/platform/k8s/injector/annotations)

!!! note "The example above would translate to a workload manifest of"
    ```yaml
          annotations:
            vault.hashicorp.com/agent-inject: "true"
            vault.hashicorp.com/agent-inject-secret-secret-name.json: path/to/secrets/secret-name
            vault.hashicorp.com/agent-inject-template-secret-name.json: |
              {{ with secret "path/to/secrets/secret-name/secret-name" -}}
              {{ .Data.data | toJSONPretty }}
              {{- end }}
            vault.hashicorp.com/agent-pre-populate-only: "true"
            vault.hashicorp.com/log-level: info
            vault.hashicorp.com/preserve-secret-case: "true"
            vault.hashicorp.com/role: k8s-default
            vault.hashicorp.com/secret-volume-path: /run/secrets
    ```
