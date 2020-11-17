# External Image Configuration

Provides values to define kubernetes external image information for use in deployments & statefulsets.

The example found in the `global:` section is:

```yaml
  ############################################################
  # External Images
  #
  # Provides ability to use external images for various purposes
  # such as using curl.
  ############################################################
    externalImage:
    curl: curlimages/curl:latest
```

Translating to kubernetes manifest information:

```yaml
  initContainers:
  - command:
    image: curlimages/url:latest
```
