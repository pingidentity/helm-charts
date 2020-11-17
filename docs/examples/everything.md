# Everything...and the kitchen sink

This example values below deploys all the product/images integrated with one another.

## Deploy

```shell
helm upgrade --install everything pingidentity/ping-devops \
     -f https://helm.pingidentity.com/examples/everything.yaml
```

## Uninstall

```shell
helm uninstall everything
```

## Everything Config Yaml

```yaml
global:
  enabled: true  # Enables ALL images
  image:
    tag: "edge"  # Uses images with the "edge" tag
```
