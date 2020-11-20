# Image Configuration

Provides values to define kubernetes image information to deployments and statefulsets.

The example found in the `global:` section is:

```yaml
  image:
    repository: pingidentity
    name:                                 # Should be completed in product section
    tag: 2010
    pullPolicy: Always
```

Translating to kubernetes manifest information:

```yaml
    image: pingidentity/pingaccess:2010   # Example if image.name=pingaccess
    imagePullPolicy: Always
```
