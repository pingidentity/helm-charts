# Release Notes
## Release 0.11.0 (November 20, 2024)
### Features ###
  - Updated default global image tag to `2410`.

### Enhancements ###
  - Added supported values for specifying more fine-grained annotations and labels for workloads, workload pod templates, services, HPA, and RBAC objects. Annotations can now be specified for these resources individually, rather than relying on global annotations that apply to all resources. Here is an example showing the new values that can be set for annotations (analagous values are available to control labels):
```
global:
  annotations:
    globalAnnotation: val
  
  workload:
    annotations:
      globalWorkloadAnnotation: val
    statefulSet:
      annotations:
        globalSSAnnotation: val
    deployment:
      annotations:
        globalDepAnnotation: val
  
  rbac:
    generateGlobalServiceAccount: true
    generateGlobalRoleAndRoleBinding: true
    serviceAccountAnnotations:
      globalServiceAccountAnnotation: val
    roleAnnotations:
      globalRoleAnnotation: val
    roleBindingAnnotations:
      globalRoleBindingAnnotation: val

  services:
    annotations:
      globalServiceAnnotation: val
    clusterServiceAnnotations:
      globalClusterServiceAnnotation: val

pingdirectory:
  enabled: true
  annotations:
    pdAnnotation: val
  workload:
    annotations:
      pdWorkloadAnnotation: val
    statefulSet:
      annotations:
        pdSSAnnotation: val
  rbac:
    generateServiceAccount: true
    generateRoleAndRoleBinding: true
    role:
      rules:
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "list"]
    serviceAccountAnnotations:
      pdServiceAccountAnnotation: val
    roleAnnotations:
      pdRoleAnnotation: val
    roleBindingAnnotations:
      pdRoleBindingAnnotation: val
  services:
    annotations:
      pdServiceAnnotation: val
    clusterServiceAnnotations:
      pdClusterServiceAnnotation: val
```

### Bug fixes ###
  - Fixed global annotations not applying for RBAC objects.
