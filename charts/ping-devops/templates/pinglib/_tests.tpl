{{- define "pinglib.test.job" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $testFramework := index . 2 -}}

{{- $containerName := $testFramework.name -}}
{{- $sharedMountPath := $testFramework.sharedMountPath -}}
{{- $configMaps := $testFramework.testConfigMaps -}}
{{- $cmMountLocation := $configMaps.volumeMountPath -}}
{{- $cmPrefix := $configMaps.prefix -}}

apiVersion: v1
kind: Pod
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
  annotations:
    "helm.sh/hook": test
  name: {{ include "pinglib.addreleasename" (list $top $v $containerName) }}
spec:
  restartPolicy: Never
  initContainers:


  {{- range $testFramework.testSteps }}
  {{- if .waitFor }}
    {{ include "pinglib.workload.init.waitfor" (list $top $v .waitFor .name) | nindent 2 }}
  {{- else }}
  - env: []
    {{- toYaml . | nindent 4 }}
  {{- end }}

    #--------------------- Environment -----------------
    envFrom:
    - configMapRef:
        name: {{ include "pinglib.addreleasename" (list $top $v "global-env-vars") }}
        optional: true
    - configMapRef:
        name: {{ include "pinglib.addreleasename" (list $top $v (print $containerName "-env-vars")) }}
        optional: true

    #--------------------- VolumeMounts -----------------
    volumeMounts:
    - name: shared-data
      mountPath: {{ $sharedMountPath }}

    {{- range $configMaps.files }}
    {{- $volumeName := print $cmPrefix (sha1sum .)  }}
    {{- $volumeMountPath := print $cmMountLocation . }}
    - name: {{ $volumeName }}
      mountPath: {{ $volumeMountPath }}
      subPath: {{ . }}
      readOnly: true

    {{- end }}
    {{- end }}
  containers:
  {{- with $testFramework.finalStep }}
  - imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: shared-data
      mountPath: {{ $sharedMountPath }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $testFramework.rbac.enabled }}
  serviceAccountName: {{ include "pinglib.addreleasename" (list $top $v "test-service-account") }}
  {{- end }}

  {{ toYaml $testFramework.pod | nindent 2 }}

  #--------------------- VolumeMounts -----------------
  # Setup a volume for each file in the configMaps.files
  volumes:
  # Use a shared volume between containers
  - name: shared-data
    emptyDir: {}

  # Setup a volume for each file in the configMaps.files
  {{- range $configMaps.files }}
  {{- $volumeName := print $cmPrefix (sha1sum .)  }}
  - name: {{ $volumeName }}
    configMap:
      name: {{ include "pinglib.addreleasename" (list $top $v .) }}
      items:
      - key: file
        path: {{ . }}
  {{- end }}
{{- end -}}

{{- define "pinglib.test.service-account" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $testFramework := index . 2 -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
  annotations:
    "helm.sh/hook": test
  name: {{ include "pinglib.addreleasename" (list $top $v "test-service-account") }}
{{- end -}}

{{- define "pinglib.test.role" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $testFramework := index . 2 -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
  annotations:
    "helm.sh/hook": test
  name: {{ include "pinglib.addreleasename" (list $top $v "test-role") }}
{{ toYaml $testFramework.rbac.role }}
{{- end -}}

{{- define "pinglib.test.role-binding" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $testFramework := index . 2 -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  {{ include "pinglib.metadata.labels" .  | nindent 2  }}
  {{ include "pinglib.metadata.annotations" .  | nindent 2  }}
  annotations:
    "helm.sh/hook": test
  name: {{ include "pinglib.addreleasename" (list $top $v "test-role-binding") }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ include "pinglib.addreleasename" (list $top $v "test-role") }}
subjects:
- kind: ServiceAccount
  name: {{ include "pinglib.addreleasename" (list $top $v "test-service-account") }}
  namespace: {{ $top.Release.Namespace}}
{{- end -}}