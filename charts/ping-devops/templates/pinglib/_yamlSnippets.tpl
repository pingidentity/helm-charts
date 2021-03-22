
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
   ** metadata.annotations snippet
   **********************************************************************/}}
{{- define "pinglib.metadata.annotations" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
  {{- if $v.annotations }}
annotations:
  {{- toYaml $v.annotations | nindent 2 }}
  {{- end }}
{{- end -}}

{{/**********************************************************************
   ** metadata.vault.headers snippet
   **********************************************************************/}}
{{- define "pinglib.annotations.vault" -}}
{{- if .enabled }}
{{- with .hashicorp -}}
#----------------------------------------------------
# Annotation secrets prepared for hashicorp vault secrets
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
# Additional Vault configuration annotations
{{- range $annotation, $val := .annotations }}
vault.hashicorp.com/{{ $annotation }}: {{ $val | quote }}
{{- end -}}
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
{{- end }}
{{- end }}
{{- toYaml .annotations }}
{{- end }}
{{- end -}}

{{/* Generate certificates */}}
{{- define "pinglib.gen-cert" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $subjectCN := include "pinglib.addreleasename" (append . $v.name) -}}
{{- $alt := dict "ips" (list) "names" (list $subjectCN ) -}}
{{- if $v.ingress.enabled }}
    {{- range $v.ingress.hosts }}
        {{- $noop := concat $alt.names (list (include "pinglib.ingress.hostname" (list $top $v .host))) | set $alt "names" }}
    {{- end }}
{{- end }}
{{- if $v.privateCert.additionalIPs }}
    {{- $noop := set $alt "ips" $v.privateCert.additionalIPs  }}
{{- end }}
{{- if $v.privateCert.additionalHosts }}
    {{- $noop := concat $alt.names $v.privateCert.additionalHosts | set $alt "names" }}
{{- end }}
{{- $cert := genSelfSignedCert $subjectCN $alt.ips $alt.names 365 -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}