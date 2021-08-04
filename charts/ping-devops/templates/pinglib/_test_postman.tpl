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
  {{- $stepName := .name }}
  {{- if .waitFor }}
    {{ include "pinglib.workload.init.waitfor" (list $top $v .waitFor $stepName) | nindent 2 }}
  {{- else }}


  - name: {{ $stepName }}
    env: []
    #--------------------- Image -------------------------
    image: {{ default .image (index $v.externalImage .image) }}
    imagePullPolicy: IfNotPresent
    #--------------------- Command -----------------------
    command:
      {{ toYaml .command | nindent 6 }}
    securityContext: {{ toYaml .securityContext | nindent 6 }}
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
  - name: {{ .name }}
    image: {{ default .image (index $v.externalImage .image) }}
    command:
      {{ toYaml .command | nindent 6 }}
    securityContext: {{ toYaml .securityContext | nindent 6 }}
    volumeMounts:
    - name: shared-data
      mountPath: {{ $sharedMountPath }}
    resources:
      limits:
        cpu: 500m
        memory: 128Mi
      requests:
        cpu: 0m
        memory: 64Mi
  {{ toYaml $testFramework.pod | nindent 2 }}
  {{- end }}

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
