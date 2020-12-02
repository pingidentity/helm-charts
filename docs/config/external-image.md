# External Image Configuration

Provides a secret used for obtaining evaluation licenses for Ping Identity products.

## Global Section

Default yaml defined in the global license section, followed by definitions for each parameter.

```yaml
global:
  externalImage:
    pingtoolkit: pingidentity/pingtoolkit:latest
```

| External Image Parameters | Description                                                                                   |
| ------------------------- | --------------------------------------------------------------------------------------------- |
| pingtoolkit               | Registry, image and tag location for pingtoolkit.  Used for primarily during init containers. |

!!! note "Private Repository Location"
    Often, if your kubernetes cluster doesn't have access to an external docker repository,
    you can download and save the `pingtoolkit` image to your local repo.  Setting this to your
    local location will force the charts to use that image.