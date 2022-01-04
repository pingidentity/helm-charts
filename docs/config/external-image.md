# External Image Configuration

Defines an external image for initContainer utilities.

## Global Section

Default yaml defined in the global externalImage section:

```yaml
global:
  externalImage:
    pingtoolkit: pingidentity/pingtoolkit:latest
```

| External Image Parameters | Description                                                                                   |
| ------------------------- | --------------------------------------------------------------------------------------------- |
| pingtoolkit               | Registry, image and tag location for pingtoolkit.  Used for primarily during init containers. |

!!! note "Private Repository Location"
    If your kubernetes cluster doesn't have access to an external docker repository,
    you can download and save the `pingtoolkit` image to your local repo.  Setting this to your
    local repo will cause the charts to use that image.