{{- define "pinglib.test.postman" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $testName := index . 2 -}}
{{- $test := index $top.Values.testFramework $testName -}}
{{- $containerName := print "test-" $testName -}}
{{- $waitFor := $test.waitFor -}}
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
  initContainers: {{ include "pinglib.workload.init.waitfor" (list $top $v $waitFor) | nindent 4 }}
  containers:
  - name: {{ $containerName }}
    env: []

    {{/*--------------------- Image -------------------------*/}}
    image: "postman/newman:5-alpine"
    imagePullPolicy: IfNotPresent


    {{/*--------------------- Command -----------------------*/}}
    command:
      - newman
      - run
      - {{ $test.collection }}
      - --insecure
      - --ignore-redirects

    {{/*--------------------- Environment -----------------*/}}
    envFrom:
    - configMapRef:
        name: {{ $top.Release.Name }}-global-env-vars
        optional: true
    - configMapRef:
        name: {{ $top.Release.Name }}-{{ $testName }}-env-vars
        optional: true

    resources:
      limits:
        cpu: 500m
        memory: 128Mi
      requests:
        cpu: 250m
        memory: 64Mi
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
      runAsGroup: 1000
      runAsNonRoot: true
      runAsUser: 100
{{- end }}
