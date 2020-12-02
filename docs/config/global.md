# global: values

There is a top level global value providing instructions on how to name all
kubernetes resources, so a deployer might deploy several releases under the same
namespace.

## addReleaseNameToResource

Provides global ability to add the Helm `.Release.Name` to kubernetes resources.

| Value   | Description                           | Example: (Release.Name=acme, resource=pingdirectory) |
| ------- | ------------------------------------- | ---------------------------------------------------- |
| prepend | Prepends the Release.Name **DEFAULT** | acme-pingdirectory                                   |
| append  | Appends the Release.Name              | pingdirectory-acme                                   |
| none    | No use of Release.Name                | pingdirectory                                        |
