{{- define "pinglib.workload.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
apiVersion: apps/v1
{{/*--------------- Deployment | StatefulSet ---------------*/}}
kind: {{ $v.workload.type }}
metadata: {{ include "pinglib.metadata.labels" .  | nindent 2 }}
  name: {{ include "pinglib.fullname" . }}
spec:
  replicas: {{ $v.container.replicaCount }}
  selector:
    matchLabels: {{ include "pinglib.selector.labels" . | nindent 6 }}

  {{- if eq $v.workload.type "Deployment" }}
  {{/*--------------------- Deployment ---------------------*/}}
  strategy:
    {{- with $v.workload.deployment.strategy }}
    type: {{ .type}}
    {{- if (eq .type "RollingUpdate") }}
    rollingUpdate: {{ toYaml .rollingUpdate | nindent 6 }}
    {{- end }}
    {{- end }}

  {{- else if eq $v.workload.type "StatefulSet" }}
  {{/*--------------------- StatefulSet ---------------------*/}}
  serviceName: {{ include "pinglib.fullname" . }}-cluster
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: {{ $v.workload.statefulSet.partition }}
  podManagementPolicy: OrderedReady
  {{- end }}
  {{/*-------------------------------------------------------*/}}

  template:
    metadata:
      {{ include "pinglib.metadata.labels" .  | nindent 6  }}
        {{ include "pinglib.selector.labels" . | nindent 8 }}
        clusterIdentifier: {{ include "pinglib.fullimagename" . }}
      annotations: {{ include "pinglib.annotations.vault" $v.vault | nindent 8 }}
        {{ $prodChecksum := include (print $top.Template.BasePath "/" $v.name "/configmap.yaml") $top | sha256sum }}
        {{ $globChecksum := include (print $top.Template.BasePath "/global/configmap.yaml") $top | sha256sum }}
        checksum/config: {{ print $prodChecksum $globChecksum | sha256sum }}
    spec:
      terminationGracePeriodSeconds: {{ $v.container.terminationGracePeriodSeconds }}
      {{- if $v.vault.enabled }}
      serviceAccountName: {{ $v.vault.hashicorp.serviceAccountName }}
      {{- end }}
      nodeSelector: {{ toYaml $v.container.nodeSelector | nindent 8 }}
      tolerations: {{ toYaml $v.container.tolerations | nindent 8 }}
      initContainers: {{ include "pinglib.workload.init.waitfor" (append . $v.container.waitFor) | nindent 6 }}
      containers:
      - name: {{ $v.name }}
        env: []


        {{/*--------------------- Image -------------------------*/}}
        {{- with $v.image }}
        image: "{{ .repository }}/{{ .name }}:{{ .tag }}"
        imagePullPolicy: {{ .pullPolicy }}
        {{- end }}


        {{/*--------------------- Command -----------------------*/}}
        {{- with $v.container.command }}
        command:
          {{- range regexSplit " " ( default "" . ) -1 }}
            - {{ . | quote }}
          {{- end }}
        {{- end }}


        {{/*--------------------- Ports -----------------------*/}}
        {{- with $v.services }}
        ports:
        {{- range $serviceName, $val := . }}
        {{- if ne $serviceName "clusterExternalDNSHostname" }}
        - containerPort: {{ $val.containerPort }}
          name: {{ $serviceName }}
        {{- end }}
        {{- end }}
        {{- end }}


        {{/*--------------------- Environment -----------------*/}}
        envFrom:
        - configMapRef:
            name: {{ include "pinglib.addreleasename" (append . "global-env-vars") }}
            optional: true
        - configMapRef:
            name: {{ include "pinglib.addreleasename" (append . "env-vars") }}
            optional: true
        - configMapRef:
            name: {{ include "pinglib.fullname" . }}-env-vars
        - secretRef:
            name: {{ $v.license.secret.devOps }}
            optional: true
        - secretRef:
            name: {{ include "pinglib.fullname" . }}-git-secret
            optional: true
        {{- if $v.container.envFrom }}
        {{- toYaml $v.container.envFrom | nindent 8}}
        {{- end }}

        {{/*--------------------- Probes ---------------------*/}}
        {{- with $v.probes }}
        livenessProbe:
          exec:
            command: [ {{ .liveness.command }} ]
          initialDelaySeconds: {{ .liveness.initialDelaySeconds }}
          periodSeconds: {{ .liveness.periodSeconds }}
          timeoutSeconds: {{ .liveness.timeoutSeconds }}
          successThreshold: {{ .liveness.successThreshold }}
          failureThreshold: {{ .liveness.failureThreshold }}
        readinessProbe:
          exec:
            command: [ {{ .readiness.command }} ]
          initialDelaySeconds: {{ .readiness.initialDelaySeconds }}
          periodSeconds: {{ .readiness.periodSeconds }}
          timeoutSeconds: {{ .readiness.timeoutSeconds }}
          successThreshold: {{ .readiness.successThreshold }}
          failureThreshold: {{ .readiness.failureThreshold }}
        {{- end }}

        {{/*--------------------- Resources ------------------*/}}
        resources: {{ toYaml $v.container.resources | nindent 10 }}
        {{- if or (and (eq $v.workload.type "StatefulSet") $v.workload.statefulSet.persistentvolume.enabled) $v.internalCert.generate }}
        volumeMounts:
        {{- if eq $v.workload.type "StatefulSet" }}
        {{- range $volName, $val := $v.workload.statefulSet.persistentvolume.volumes }}
        - name: {{ $volName }}{{ if eq "none" $v.addReleaseNameToResource }}-{{ $top.Release.Name }}{{ end }}
          mountPath: {{ .mountPath }}
        {{- end }}
        {{- end }}
        {{- if $v.internalCert.generate }}
        - name: internal-cert
          mountPath: /run/secrets/internal-cert
          readOnly: true
        {{- end }}
        {{- end }}

        {{/*---------------- Security Context -------------*/}}
        {{/* Futures: Support for container securityContexts */}}
        {{/*securityContext: {{ toYaml $v.container.securityContext | nindent 10 }}*/}}


      {{/*---------------- Security Context -------------*/}}
      securityContext: {{ toYaml $v.workload.securityContext | nindent 8 }}

      {{/*--------------------- Volumes ------------------*/}}
      {{- if or (and (eq $v.workload.type "StatefulSet") $v.workload.statefulSet.persistentvolume.enabled) $v.internalCert.generate }}
      volumes:
      {{- if eq $v.workload.type "StatefulSet" }}
      {{- range $volName, $val := $v.workload.statefulSet.persistentvolume.volumes }}
      - name: {{ $volName }}{{ if eq "none" $v.addReleaseNameToResource }}-{{ $top.Release.Name }}{{ end }}
        persistentVolumeClaim:
          claimName: {{ $volName }}{{ if eq "none" $v.addReleaseNameToResource }}-{{ $top.Release.Name }}{{ end }}
      {{- end }}
      {{- end }}
      {{- if $v.internalCert.generate }}
      - name: internal-cert
        secret:
          secretName: {{ include "pinglib.fullname" . }}-secret-cert
      {{- end }}
      {{- end }}

  {{/*----------------- VolumeClameTemplates ------------------*/}}
  {{- if and (eq $v.workload.type "StatefulSet") $v.workload.statefulSet.persistentvolume.enabled }}
  volumeClaimTemplates:
  {{- range $volName, $val := $v.workload.statefulSet.persistentvolume.volumes }}
  - metadata:
      name: {{ $volName }}{{ if eq "none" $v.addReleaseNameToResource }}-{{ $top.Release.Name }}{{ end }}
    spec:
      {{ toYaml $val.persistentVolumeClaim | nindent 6 }}
  {{- end }}
  {{- end }}
{{- end -}}


{{- define "pinglib.workload" -}}
{{- include "pinglib.merge.templates" (append . "workload") -}}
{{- end -}}

{{- define "pinglib.workload.init.waitfor" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $waitFor := index . 2 -}}
{{- range $prod, $val := $waitFor }}
  {{- if (index $top.Values $prod).enabled }}
    {{- $host := include "pinglib.addreleasename" (list $top $v $prod) }}
    {{- $waitForServices := (index $top.Values $prod).services }}
    {{- $port := (index $waitForServices $val.service).servicePort | quote }}
    {{- $server := printf "%s:%s" $host $port }}
- name: wait-for-{{ $prod }}-init
  imagePullPolicy: {{ $v.image.pullPolicy }}
  image: {{ $v.externalImage.pingtoolkit }}
  command: ['sh', '-c', 'echo "Waiting for {{ $server }}..." && wait-for {{ $server }} -- echo "{{ $server }} running"']
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
  {{- end }}
{{- end -}}