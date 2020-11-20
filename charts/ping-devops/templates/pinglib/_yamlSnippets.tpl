{{/**********************************************************************
** images snippet
**********************************************************************/}}
{{- define "pinglib.imagetags" -}}
image: "{{ .repository }}/{{ .name }}:{{ .tag }}"
imagePullPolicy: {{ .pullPolicy }}
{{- end -}}

{{/**********************************************************************
** replicas snippet
**********************************************************************/}}
{{- define "pinglib.replicas" -}}
replicas: {{ .replicaCount }}
{{- end -}}

{{/**********************************************************************
** envfrom snippet
**********************************************************************/}}
{{- define "pinglib.envfrom" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
envFrom:
- configMapRef:
    name: {{ include "pinglib.fullname" . }}-env-vars
- configMapRef:
    name: {{ $top.Release.Name }}-global-env-vars
    optional: true
- secretRef:
    name: {{ $v.license.secret.devOps }}
    optional: true
- secretRef:
    name: {{ include "pinglib.fullname" . }}-git-secret
    optional: true
{{- end -}}

{{/**********************************************************************
** metadata.labels snippet
**********************************************************************/}}
{{- define "pinglib.metadata.labels" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
labels:
  {{- include "pinglib.selector.labels" . | nindent 2 }}
  helm.sh/chart: {{ include "pinglib.chart" . }}
  app.kubernetes.io/managed-by: {{ $top.Release.Service }}
  {{- if $v.labels }}
    {{- toYaml $v.labels | nindent 2 }}
  {{- end }}
{{- end -}}

{{/**********************************************************************
** selector.label snippet
**********************************************************************/}}
{{- define "pinglib.selector.labels" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
app.kubernetes.io/name: {{ include "pinglib.name" . }}
app.kubernetes.io/instance: {{ $top.Release.Name }}
{{- end -}}

{{/**********************************************************************
** probes snippets
**********************************************************************/}}
{{- define "pinglib.probes" -}}
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
{{- end -}}

{{/**********************************************************************
** confgmap env snippets
**********************************************************************/}}
{{- define "pinglib.configMapEnvs" -}}
#####
# .envs values
#####
{{ toYaml .Values.envs }}
{{- if .Values.global }}
{{- if .Values.global.envs }}
#####
# global.envs values
#####
{{ toYaml .Values.global.envs }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/**********************************************************************
** deployment/statefulset licenseSecret snippets
**********************************************************************/}}
{{- define "pinglib.licenseSecretVolume" -}}
- name: license
  secret:
    secretName: {{ .Values.licenseSecretName }}
{{- end -}}

{{/**********************************************************************
** service/ports snippets
**
**   ports:
**     - port: 9999
**       targetPort: 9999
**       name: pf-admin
**       protocol: TCP
**********************************************************************/}}
{{- define "pinglib.service.ports" -}}
{{- range .ports }}
{{ if .clusterService }}
- port: {{ .port }}
  targetPort: {{ .targetPort }}
  name: {{ .name }}
  protocol: {{ default "TCP" .protocol }}
{{ end }}
{{- end -}}
{{- end -}}

{{/**********************************************************************
** service/ports snippets
**
**   ports:
**     - port: 9999
**       name: pf-admin
**********************************************************************/}}
{{- define "pinglib.container.ports" -}}
ports:
{{- range $serviceName, $val := . }}
{{- if ne $serviceName "clusterExternalDNSHostname" }}
- containerPort: {{ $val.port }}
  name: {{ $serviceName }}
{{- end }}
{{- end }}
{{- end -}}

{{/**********************************************************************
** container startupcommand
**
**   container:
**     - name: ...
        command: ['sh', '-c', 'until curl --connect-timeout 1 --silent -k https://{{ include "pinglib.fullname" . | replace "-engine" "-admin" }}:{{ .Values.envs.PF_ADMIN_PORT }}/pingfederate/app ; do echo waiting for https://{{ include "pinglib.fullname" . | replace "-engine" "-admin" }}:{{ .Values.envs.PF_ADMIN_PORT }}/pingfederate/app ; sleep 2 ; done']
**********************************************************************/}}
{{- define "pinglib.container.command" -}}
{{- if . }}
command:
  {{- range regexSplit " " ( default "" . ) -1 }}
    - {{ . | quote }}
  {{- end }}
{{- end }}
{{- end -}}



{{/**********************************************************************
** metadata.vault.headers snippet
**********************************************************************/}}
{{- define "pinglib.annotations.vault" -}}
{{- if .enabled }}
{{- with .hashicorp -}}
#----------------------------------------------------
# Annotation secretes prepared for hashicorp vault secrets
# for use in Deployment, StatefulSet, Pod resources.
#
# https://www.vaultproject.io/docs/platform/k8s/injector/annotations
#
vault.hashicorp.com/agent-pre-populate-only: {{ ( index . "pre-populate-only" ) | quote }}
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/role: {{ ( index . "role" ) | quote }}
vault.hashicorp.com/log-level:  {{ ( index . "log-level" ) | quote }}
vault.hashicorp.com/preserve-secret-case:  {{ ( index . "preserve-secret-case" ) | quote }}
vault.hashicorp.com/secret-volume-path:  {{ ( index . "secret-volume-path" ) | quote }}
#----------------------------------------------------
{{- $secretPrefix := .secretPrefix }}
{{- range .secrets }}
{{- $fullSecret := printf "%s%s" $secretPrefix .secret }}
#------------ secret: {{ .name }}
vault.hashicorp.com/agent-inject-secret-{{ .name }}.json: {{ $fullSecret | quote }}
vault.hashicorp.com/agent-inject-template-{{ .name }}.json: |
  {{ printf "{{ with secret %s -}}" ($fullSecret | quote) }}
  {{ printf "{{ .Data.data | toJSONPretty }}" }}
  {{ printf "{{- end }}" }}
#------------------------------------------------
{{- end -}}
{{- end }}
{{- end -}}
{{- end -}}
