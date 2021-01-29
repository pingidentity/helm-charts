
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
vault.hashicorp.com/agent-init-first: "true"
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

{{/* Generate certificates */}}
{{- define "pinglib.gen-cert" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $subjectCN := include "pinglib.addreleasename" (append . $v.name) -}}
{{- $altIPs := list (  "127.0.0.1" ) -}}
{{- $altNames := list $subjectCN "localhost" -}}
{{- $cert := genSelfSignedCert $subjectCN $altIPs $altNames 365 -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}