# Vault Configuration

Provides values to define kubernetes image information to deployments and statefulsets.

## Global Section

Default yaml defined in the product vault section.

```yaml
image:
  image:
    repository: pingidentity
    name:                                 # Should be completed in product section
    tag: 2010
    pullPolicy: Always
```

## Product Section

An example product section specifies the name.

```yaml
pingaccess-admin:
  image:
    name: pingaccess
```

!!! note "To have images use a different repository and tag"
    ```yaml
    global:
      image:
        tag: edge
        repository: my.company.docker-repo.com
    ```

    This would result in pulling a pingaccess image: `my.company.docker-repo.com/pingaccess:edge`
