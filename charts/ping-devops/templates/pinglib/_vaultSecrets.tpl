{{/**********************************************************************
   ** pinglib.annotations.vault snippet
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
vault.hashicorp.com/secret-volume-path:  {{ index . "secret-volume-path" | quote }}
#----------------------------------------------------
# Additional Vault configuration annotations
{{- range $annotation, $val := (omit .annotations "serviceAccountName") }}
vault.hashicorp.com/{{ $annotation }}: {{ $val | quote }}
{{- end -}}
#----------------------------------------------------
{{- $defaultSecretVolumePath := index .annotations "secret-volume-path" }}
{{- $secretPrefix := .secretPrefix }}
{{- range $secretName, $secretVal := .secrets }}
#------------ Processing Secret
  {{- $fullSecret := printf "%s%s" $secretPrefix $secretName }}
  {{- range $keyName, $keyVal := $secretVal }}
    {{- $keyPath := default $defaultSecretVolumePath $keyVal.path }}
    {{- $keyFile := default $keyName (required "A 'vault.hashicorp.secrets.{secret-name}.file' is required for each secret" $keyVal.file) }}
    {{- $keyFile := ternary (printf "%s.json" $keyFile) $keyFile (eq $keyName "to-json") }}
vault.hashicorp.com/secret-volume-path-{{ $keyFile }}: {{ $keyPath }}
vault.hashicorp.com/agent-inject-secret-{{ $keyFile }}: {{ $fullSecret | quote }}
    {{- if eq $keyName "to-json" }}
vault.hashicorp.com/agent-inject-template-{{ $keyFile}}: |
  {{ printf "{{- with secret %s }}" ($fullSecret | quote) }}
  {{ printf "{{ .Data.data | toJSONPretty }}"             }}
  {{ printf "{{- end }}"                                  }}
    {{- else }}
vault.hashicorp.com/agent-inject-template-{{ $keyFile }}: |
  {{ printf "{{- with secret %s }}" ($fullSecret | quote) }}
  {{ printf "{{- index .Data.data %s }}" ($keyName | quote)  }}
  {{ printf "{{- end }}"                                  }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
