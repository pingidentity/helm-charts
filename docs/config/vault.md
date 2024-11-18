# Vault Configuration

The current helm chart support is provided for Hashicorp Vault annotations and use of the
Hashicorp injector.
More information on Hashicorp Vault annotations can be found [here](https://www.vaultproject.io/docs/platform/k8s/injector/annotations).

> Note: the PingIdentity DevOps images and Helm chart only support version 2 of the KV secrets engine API for Vault secrets. PingDirectory itself currently only supports KV version 1 for password storage schemes. Learn more in the [Vault KV secrets engine documentation](https://developer.hashicorp.com/vault/api-docs/secret/kv).

## Vault Secret Values

An example vault values section looks like:

```
  vault:
    enabled: true
    hashicorp:
      annotations:
        role: {hashicorp-vault-role}
      secretPrefix: {path to secret}
      secrets:
        {secret-name}:
          {secret-key | to-json}:
            path: /opt/in/some/location/secrets
            file: devops-secret.env
```

The `vault.hashicorp.secrets` is a map that specifies each `secret` to pull from the
vault.  And for each secret, a map specifies the `key` to pull with instructions of where
to place the secret based on `path` and `file`

| License Parameters          | Description                                                                   | Default Value     |
| --------------------------- | ----------------------------------------------------------------------------- | ----------------- |
| secrets.{secret}            | map of secret                                                                 | devops-secret     |
| secrets.{secret}.{key}      | map of key                                                                    | pingaccess.lic    |
| secrets.{secret}.{key}.path | optional: location of secret. Defaults to vault.annotation.secret-volume-path | /opt/in/some/path |
| secrets.{secret}.{key}.file | required: file name secrets placed into                                       | pingaccess.lic    |

## Special key name (`to-json`)

There is a special key name that can be provided that will drop the raw secret into the
container as it's json representation with all the secret key names/values.

If dropped into the `SECRETS_DIR` (defaults to `/run/secrets`) directory, these files will
be processed as:

* PROPERTY_FILE if the file ends in `.env` or
* Separate files will be created for each key=value pair.

See the example below in this document for the
transformation that occurs with the `devops-secret.env`.

## Vault Annotations

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
```

The serviceAccount used by Vault will match the default serviceAccount for the workload.

## Example

The following includes an example Hashicorp Vault secrets as well as a value values .yaml that
make use of the secrets and an example of where secrets will be placed into container.

!!! note "Example: Hashicorp Vault secrets"
    SECRET:secrets/jsmith@example.com/jsmith-namespace/licenses

    ```
    {
      "pingaccess-6.2": "Product=PingAccess\nVersion=6.2...",
      "pingdirectory-8.2": "Product=PingDirectory\nVersion=8.2...",
      "pingfederate-10.2": "Product=PingFederate\nVersion=10.2..."
    }
    ```

    SECRET: secrets/jsmith@example.com/jsmith-namespace/devops-secrets.env
    ```
    {
      "PING_IDENTITY_ACCEPT_EULA": "YES",
      "PING_IDENTITY_DEVOPS_KEY": "d254....-....-...-...-............",
      "PING_IDENTITY_DEVOPS_USER": "jsmith@example.com"
    }
    ```

    SECRET: secrets/jsmith@example.com/jsmith-namespace/certs
    ```
    {
      "tls.crt": "LS0tLS1CRUdJ...a9dk",
      "tls.key": "LS0tLS1CRUdJ...38sj"
    }
    ```

!!! note "Example: Vault secrets .yaml"
    ```yaml
    pingfederate-admin:
      vault:
        hashicorp:
          secrets:
            devops-secret.env:
              to-json:
                file: devops-secret.env
            licenses:
              pingaccess-6.2:
                file: pingaccess.lic
                path: /opt/in/some/location/licenses
            test-certs:
              to-json:
                file: test-certs
    ```

    Places the following files into the container:

!!! note "Example: Container files"
    FILE: /run/secrets/devops-secret.env
    ```
    PING_IDENTITY_ACCEPT_EULA="YES"
    PING_IDENTITY_DEVOPS_KEY="d254....-....-...-...-............"
    PING_IDENTITY_DEVOPS_USER="jsmith@example.com"
    ```

    FILE: /opt/in/some/location/licenses/pingaccess.lic
    ```
    Product=PingAccess
    Version=6.2
    ...
    ```

    FILE: /run/secrets/tls.crt
    ```
    LS0tLS1CRUdJ...a9dk
    ```

    FILE: /run/secrets/tls.key
    ```
    LS0tLS1CRUdJ...38sj
    ```

## Using Vault secrets to mount base64-encoded keystore files

To pull keystore files from a Vault cluster, create a secret with separate keys for each individual keystore file. The value of each key should be the base64 representation of the file that needs to be mounted. The names of the keys as well as the name of the secret will be used in the Helm values yaml when mounting the keystore files.

Environment variables or other configuration for the product being deployed will need to be set to point to the location where the keystores are being mounted. For example, for PingDirectory:

```
KEYSTORE_FILE=/run/secrets/mykeystore.jks
KEYSTORE_PIN_FILE=/run/secrets/mykeystore.pin
```

Ensure the Vault cluster is accessible to the Kubernetes cluster where your Helm release is being deployed. You can then use the Vault annotations to mount the keystore files in the desired location. For an example, see the "Vault Keystores" example on the [Helm examples page](https://devops.pingidentity.com/deployment/deployHelm/).


