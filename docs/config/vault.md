# Vault Configuration

Provides values to define kubernetes deployments and statefulsets to use a Hashicorp vault to inject secrets as part of an init container.

More information on Hashicorp Vault annoations can be found [here](https://www.vaultproject.io/docs/platform/k8s/injector/annotations).

The example found in the `global:` section is:

```yaml
  vault:
    enabled: false
    hashicorp:
      role: k8s-default
      log-level: info
      preserve-secret-case: true
      secret-volume-path: /run/secrets
      pre-populate-only: true
      # secretPrefix: path/to/secrets
      # secrets:
      # - name: secret-name
      #   secret: secret-name
```

Assuming the comments were uncommented out, secrtes from the Vault at `path/to/secrets/secret-name` would be placed in the container under `/run/secrets`

Translating to applicable kubernetes manifest sections:

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
