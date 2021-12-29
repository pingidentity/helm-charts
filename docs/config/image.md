# Image Configuration

Provides values to define kubernetes image information to deployments and statefulsets.

## Global Section

Default image yaml defined in the global section:

```yaml
global:
  image:
    repository: pingidentity
    name:                                 # Set in product section
    tag: 2111
    pullPolicy: Always
```

## Product Section

Each product section specifies the name by default

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
