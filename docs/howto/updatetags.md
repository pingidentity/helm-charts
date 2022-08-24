# Updating Product Image Tags

This page describes recommendations for updating products and image tags in a Helm installation. The focus is on what is needed to move from one docker image tag to another in the Helm chart, with some specific steps to follow for certain products. This page does *not* cover specifics on how to test upgrades or details on how to employ a blue-green update strategy. These processes will depend on the environment where the chart is deployed.

!!! warning
    Always test upgrades in a non-production environment first.

Before updating tags, be sure that you have exported any configuration from your servers and stored it in a server profile. This ensures no configuration is lost when pods are restarted. Information on how to save configuration into a server profile can be found in the [How To section of the DevOps documentation](https://devops.pingidentity.com/how-to/profiles/).

The upgrade process depends on the specific product within the Helm chart that is being upgraded.

## Blue-green update

A simple way to handle version updates is via a blue-green deployment. In this strategy, a full second deployment of the workloads being updated is deployed on the new version, and then traffic is switched from the original deployment to the new one. When following this strategy, be sure that any necessary configuration is captured in a server profile, so that it is maintained in the fresh deployment.

This strategy is particularly suited for stateless applications. Stateful applications like PingDirectory and PingDataSync would require further steps to ensure any data in the current deployment is maintained in the newer deployment.

## In-place update

Tags and product versions can also be updated in-place. The required process depends on the product being updated.

### Simple tag update

For some products, simply updating the tag is all that is needed. For example, updating from PingDirectory `8.3.0.5-latest` to PingDirectory `9.0.0.0-latest` can be done by updating the tag in values.yaml.
```
pingdirectory:
  enabled: true
  image:
    tag: 8.3.0.5-latest
```
becomes

```
pingdirectory:
  enabled: true
  image:
    tag: 9.0.0.0-latest
```
The active Helm release can be updated after setting the new image tag.

`helm upgrade --install <releasename> pingidentity/ping-devops -f <updated values.yaml>`

Update logic will be automatically handled by hook scripts on container startup. This is true for PingDirectory, PingDirectoryProxy, PingDataSync, and PingAuthorize.

For products that are not run as a StatefulSet, generally the tags can be updated without any additional update steps, after the server profile is updated and saved. If the server profile is not up to date with the configuration on the running pod(s), then configuration could be lost on a tag update.

### Product updates requiring manual steps

Some products have more specific upgrade processes that needs to be followed when the product version is being updated, such as updating from PingFederate 10.3.7 to PingFederate 11.0.3.

#### PingFederate
See [the DevOps documentation instructions on upgrading PingFederate](https://devops.pingidentity.com/how-to/upgradePingfederate/).

By default pingfederate-admin and pingfederate-engine each run as Deployments in the chart. If you are running a maintenance upgrade (from PingFederate version x.x.1 to x.x.2 for example) it may be sufficient to export the configuration from the previous version and pull that same configuration via server profile when starting up the new version.

!!! warning
    When upgrading a major or minor version, the upgrade steps at the above link should be followed.

#### PingAccess
PingAccess will follow a similar process to the above instructions for PingFederate.

By default pingaccess-admin runs as a StatefulSet in the chart, so the upgrade utility must be run to update the files in the persistent volume. Once the admin is updated, the engines (which run as Deployments by default) can be restarted with the new tag. See the [PingAccess docs](https://docs.pingidentity.com/csh?Product=pa-latest&Page=home) for more information.

#### PingAuthorizePAP
Ensure your policies are backed up along with your server profile before updating the tag.
